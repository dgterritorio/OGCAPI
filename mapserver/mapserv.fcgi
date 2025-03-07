#!/bin/sh
# Wrapper FastCGI per MapServer
exec /usr/bin/mapserv "$@"
