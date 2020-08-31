#!/usr/bin/env bash

# Works with PostgreSQL 12 on macOS Catalina 10.15+
brew services start postgresql
postgres -V
createuser -P -L -d dbdev
psql postgres
