#!/bin/bash
psql -h pg -d studs -f show_columns.sql 2>&1 |sed 's|.*NOTICE:  ||g'