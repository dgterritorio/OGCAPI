import logging
import os
from sqlalchemy import text
from sqlalchemy.orm import Session

from pygeoapi.provider.sql import PostgreSQLProvider
from pygeoapi.provider.base import ProviderQueryError
from pygeoapi.crs import get_transform_from_spec

PSUEDO_COUNT_LIMIT = int(os.getenv('PSUEDO_COUNT_LIMIT', 5000000))
COUNT_FUNCTION = """
CREATE OR REPLACE FUNCTION count_estimate(query text)
  RETURNS integer
  LANGUAGE plpgsql AS
$func$
DECLARE
    rec   record;
    rows  integer;
BEGIN
    FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
        rows := substring(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
        EXIT WHEN rows IS NOT NULL;
    END LOOP;

    RETURN rows;
END
$func$;
"""

LOGGER = logging.getLogger(__name__)

class PseudoPostgreSQLProvider(PostgreSQLProvider):
    def __init__(self, provider_def):
        super().__init__(provider_def)
        LOGGER.info('Initialising Fixed Pseudo-count PostgreSQL provider.')
        try:
            with Session(self._engine) as session:
                session.execute(text(COUNT_FUNCTION))
                session.commit()
                LOGGER.info("Successfully created/verified count_estimate function.")
        except Exception as e:
            LOGGER.error(f"CRITICAL: Could not create count_estimate function: {e}", exc_info=True)

    def query(self, offset=0, limit=10, resulttype='results', bbox=[], datetime_=None,
              properties=[], sortby=[], select_properties=[], skip_geometry=False,
              q=None, filterq=None, crs_transform_spec=None, **kwargs):

        LOGGER.debug(f"Query parameters: offset={offset}, limit={limit}, resulttype={resulttype}, bbox={bbox}")
        
        property_filters = self._get_property_filters(properties)
        cql_filters = self._get_cql_filters(filterq)
        bbox_filter = self._get_bbox_filter(bbox)
        time_filter = self._get_datetime_filter(datetime_)
        order_by_clauses = self._get_order_by_clauses(sortby, self.table_model)
        selected_properties = self._select_properties_clause(select_properties, skip_geometry)

        with Session(self._engine) as session:
            results = (
                session.query(self.table_model)
                .filter(property_filters)
                .filter(cql_filters)
                .filter(bbox_filter)
                .filter(time_filter)
                .options(selected_properties)
            )

            try:
                if filterq:
                    LOGGER.debug("CQL filter detected, skipping pseudo-count.")
                    raise ProviderQueryError('No Pseudo-count during CQL')
                
                matched = self._get_pseudo_count(results)
            except Exception as err:
                LOGGER.warning(f'Pseudo-count failed, falling back to precise count. Reason: {err}')
                matched = results.count()

            LOGGER.debug(f'Total matched records: {matched}')

            response = {
                'type': 'FeatureCollection',
                'features': [],
                'numberMatched': matched,
                'numberReturned': 0,
            }

            if resulttype == 'hits':
                return response

            crs_transform_out = get_transform_from_spec(crs_transform_spec)

            try:
                for item in results.order_by(*order_by_clauses).offset(offset).limit(limit):
                    response['numberReturned'] += 1
                    try:
                        feature = self._sqlalchemy_to_feature(item, crs_transform_out, select_properties)
                    except TypeError:
                        feature = self._sqlalchemy_to_feature(item, crs_transform_out)
                    response['features'].append(feature)
            except Exception as e:
                LOGGER.error(f"Error iterating results: {e}", exc_info=True)
                raise

        return response

    def _get_pseudo_count(self, results):
        try:
            compiled = results.statement.compile(
                self._engine, compile_kwargs={'literal_binds': True}
            )
            LOGGER.debug(f"Compiled SQL for estimate: {compiled}")
            
            with Session(self._engine) as s:
                query = text("SELECT count_estimate(:sql)")
                matched = s.execute(query, {"sql": str(compiled)}).scalar()
                LOGGER.debug(f"Pseudo-count result: {matched}")

            if matched is None:
                LOGGER.warning("count_estimate returned NULL, using 0.")
                return 0
                
            if matched < PSUEDO_COUNT_LIMIT:
                LOGGER.debug(f"Count {matched} is below limit {PSUEDO_COUNT_LIMIT}, using precise count.")
                matched = results.count()
            
            return matched
        except Exception as e:
            LOGGER.error(f"Error in _get_pseudo_count: {e}")
            raise
