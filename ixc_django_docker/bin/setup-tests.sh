#!/bin/bash

# Configure environment, create and restore test database, apply Django
# migrations, and execute a command.

cat <<EOF
# `whoami`@`hostname`:$PWD$ setup-tests.sh $@
EOF

set -e

export BASE_SETTINGS_MODULE=test
export REUSE_DB=1
export SRC_PGDATABASE="${SRC_PGDATABASE:-$PROJECT_DIR/test_initial_data.sql}"

# Only drop existing database when QUICK is not set.
[[ -z "$QUICK" ]] && export SETUP_POSTGRES_FORCE=1

PGDATABASE="test_$PGDATABASE" setup-postgres.sh
if [[ $(python -c 'import django; print(django.get_version());') < 1.7 ]]; then
	echo 'Always sync database, because Django version is less than 1.7.'
	manage.py syncdb --noinput
fi
[[ -z "$QUICK" ]] && manage.py migrate --noinput

# Execute command.
exec "$@"