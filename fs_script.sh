#!/bin/bash
psql -h pg -d studs -f find_schemas.sql 2>&1 |sed 's|.*NOTICE:  ||g'