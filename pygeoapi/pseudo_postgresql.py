import os
import json
import time
import logging
from copy import deepcopy

from sqlalchemy import text, func
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError

from pygeoapi.provider.sql import PostgreSQLProvider
from pygeoapi.provider.base import ProviderQueryError, ProviderItemNotFoundError
from pygeoapi.crs import get_transform_from_spec

PSUEDO_COUNT_LIMIT = int(os.getenv('PSUEDO_COUNT_LIMIT', 5000000))
LOGGER = logging.getLogger(__name__)

class PseudoPostgreSQLProvider(PostgreSQLProvider):
    """
    A diagnostic provider extending PostgreSQLProvider. 
    It estimates large counts using EXPLAIN (FORMAT JSON) and logs execution times 
    for query construction, counting, fetching, and serialization to identify bottlenecks.
    """

    def __init__(self, provider_def: dict):
        super().__init__(provider_def)
        LOGGER.info('Initialising PseudoPostgreSQLProvider with Performance Logging.')

    def query(self, offset=0, limit=10, resulttype='results', bbox=[], datetime_=None,
              properties=[], sortby=[], select_properties=[], skip_geometry=False,
              q=None, filterq=None, crs_transform_spec=None, **kwargs):
              
        t_start = time.perf_counter()
        LOGGER.debug(f"Query parameters: offset={offset}, limit={limit}, resulttype={resulttype}")

        # 1. TIME FILTER CONSTRUCTION
        t_filter_start = time.perf_counter()
        property_filters = self._get_property_filters(properties)
        cql_filters = self._get_cql_filters(filterq)
        bbox_filter = self._get_bbox_filter(bbox)
        time_filter = self._get_datetime_filter(datetime_)
        order_by_clauses = self._get_order_by_clauses(sortby, self.table_model)
        selected_columns = self._get_selected_columns(select_properties, skip_geometry)
        LOGGER.info(f"[PERF] Filter construction took {time.perf_counter() - t_filter_start:.4f}s")

        with Session(self._engine) as session:
            results = (
                session.query(self.table_model)
                .with_entities(*selected_columns)
                .filter(property_filters)
                .filter(cql_filters)
                .filter(bbox_filter)
                .filter(time_filter)
            )

            response = {
                'type': 'FeatureCollection',
                'features': [],
                'numberReturned': 0
            }

            # 2. TIME COUNTING
            if self.count or resulttype == 'hits':
                t_count_start = time.perf_counter()
                try:
                    if filterq:
                        LOGGER.debug("CQL filter detected, skipping pseudo-count.")
                        raise ProviderQueryError('No Pseudo-count during CQL')
                    
                    matched = self._get_pseudo_count(results)
                except Exception as err:
                    LOGGER.warning(f'Pseudo-count failed, falling back to precise count. Reason: {err}')
                    t_fallback_start = time.perf_counter()
                    matched = results.count()
                    LOGGER.info(f"[PERF] Precise fallback count took {time.perf_counter() - t_fallback_start:.4f}s")
                
                response['numberMatched'] = matched
                LOGGER.info(f"[PERF] Total Counting step took {time.perf_counter() - t_count_start:.4f}s (Matched: {matched})")
            else:
                LOGGER.debug('Count disabled')

            if resulttype == 'hits' or not results:
                return response

            crs_transform_out = get_transform_from_spec(crs_transform_spec)

            # 3. TIME FETCHING & SERIALIZING
            t_fetch_start = time.perf_counter()
            for item in results.order_by(*order_by_clauses).offset(offset).limit(limit):
                response['numberReturned'] += 1
                try:
                    feature = self._sqlalchemy_to_feature(item, crs_transform_out, select_properties)
                except TypeError:
                    feature = self._sqlalchemy_to_feature(item, crs_transform_out)
                response['features'].append(feature)
            
            LOGGER.info(f"[PERF] Fetching & GeoJSON Serialization of {response['numberReturned']} rows took {time.perf_counter() - t_fetch_start:.4f}s")

        LOGGER.info(f"[PERF] ---> TOTAL query() execution time: {time.perf_counter() - t_start:.4f}s\n")
        return response

    def _get_pseudo_count(self, results):
        """Internal helper to time and execute the EXPLAIN query"""
        t_start = time.perf_counter()
        try:
            compiled = results.statement.compile(self._engine, compile_kwargs={'literal_binds': True})
            explain_query = text(f"EXPLAIN (FORMAT JSON) {compiled}")
            
            with Session(self._engine) as s:
                t_db_start = time.perf_counter()
                explain_result = s.execute(explain_query).scalar()
                LOGGER.info(f"[PERF] EXPLAIN DB query roundtrip took {time.perf_counter() - t_db_start:.4f}s")

            if isinstance(explain_result, str):
                explain_result = json.loads(explain_result)

            if isinstance(explain_result, list) and len(explain_result) > 0:
                matched = int(explain_result[0].get("Plan", {}).get("Plan Rows", 0))
            else:
                matched = None

            if matched is None or matched == 0:
                return 0
                
            # If the estimate is lower than our limit, fetch the real count
            if matched < PSUEDO_COUNT_LIMIT:
                LOGGER.info(f"[PERF] Estimate {matched} < limit {PSUEDO_COUNT_LIMIT}. Triggering precise count.")
                t_precise = time.perf_counter()
                matched = results.count()
                LOGGER.info(f"[PERF] Precise count for small dataset took {time.perf_counter() - t_precise:.4f}s")
            
            return matched
            
        except Exception as e:
            LOGGER.error(f"Error in _get_pseudo_count: {e}")
            raise
        finally:
            LOGGER.info(f"[PERF] _get_pseudo_count function total time: {time.perf_counter() - t_start:.4f}s")

    def get(self, identifier, crs_transform_spec=None, **kwargs):
        """Overrides get() to time the primary fetch and the prev/next calculations."""
        t_start = time.perf_counter()
        LOGGER.debug(f'Get item by ID: {identifier}')

        with Session(self._engine) as session:
            try:
                t_primary_get = time.perf_counter()
                selected_columns = self._get_selected_columns([], False)
                id_col = getattr(self.table_model, self.id_field)
                item = (session.query(self.table_model)
                        .with_entities(*selected_columns)
                        .filter(id_col == identifier)
                        .first())

                if item is None:
                    raise ProviderItemNotFoundError(f'No such item: {self.id_field}={identifier}.')

                feature_id = getattr(item, self.id_field)
                assert str(feature_id) == identifier
                LOGGER.info(f"[PERF] Query for primary item took {time.perf_counter() - t_primary_get:.4f}s")
            except (AssertionError, SQLAlchemyError, ProviderItemNotFoundError) as e:
                LOGGER.debug(e, exc_info=True)
                if isinstance(e, ProviderItemNotFoundError):
                    raise
                raise ProviderItemNotFoundError(f'No such item: {self.id_field}={identifier}.')
                
            crs_transform_out = get_transform_from_spec(crs_transform_spec)
            feature = self._sqlalchemy_to_feature(item, crs_transform_out)

            if self.properties:
                props = feature['properties']
                dropping_keys = deepcopy(props).keys()
                for item_key in dropping_keys:
                    if item_key not in self.properties:
                        props.pop(item_key)

            # Frequently a huge bottleneck: fetching previous and next items
            id_field = getattr(self.table_model, self.id_field)
            
            t_prev = time.perf_counter()
            prev_item = (session.query(self.table_model)
                        .order_by(id_field.desc())
                        .filter(id_field < feature_id)
                        .first())
            LOGGER.info(f"[PERF] Fetching 'prev' item took {time.perf_counter() - t_prev:.4f}s")

            t_next = time.perf_counter()
            next_item = (session.query(self.table_model)
                        .order_by(id_field.asc())
                        .filter(id_field > feature_id)
                        .first())
            LOGGER.info(f"[PERF] Fetching 'next' item took {time.perf_counter() - t_next:.4f}s")

            feature['prev'] = getattr(prev_item, self.id_field) if prev_item is not None else feature_id
            feature['next'] = getattr(next_item, self.id_field) if next_item is not None else feature_id

        LOGGER.info(f"[PERF] ---> TOTAL get() execution time: {time.perf_counter() - t_start:.4f}s\n")
        return feature

    def _get_selected_columns(self, select_properties, skip_geometry):
        # List the column names that we want
        if select_properties:
            column_names = list(dict.fromkeys(select_properties))
        else:
            # get_fields() doesn't include geometry column
            column_names = list(self.fields.keys())

        if self.properties:  # optional subset of properties defined in config
            column_names = [c for c in column_names if c in self.properties]

        # Convert names to SQL Alchemy clause
        selected_columns = []
        
        # Ensure ID field is included for feature construction
        if self.id_field not in column_names:
            selected_columns.append(getattr(self.table_model, self.id_field))

        for column_name in column_names:
            try:
                column = getattr(self.table_model, column_name)
                selected_columns.append(column)
            except AttributeError:
                pass  # Ignore non-existent columns

        if not skip_geometry:
            geom_col = getattr(self.table_model, self.geom)
            selected_columns.append(func.ST_SnapToGrid(geom_col, 0.0001).label(self.geom))

        return selected_columns