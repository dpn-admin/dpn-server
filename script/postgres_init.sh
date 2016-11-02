#!/bin/bash

echo 'SELECT rolname FROM pg_roles;' | psql | grep -q 'dpnAdmin'
if [[ $? -ne 0 ]]; then
  echo
  echo "Creating postgres user 'dpnAdmin'"
  echo "Enter 'dpnPass' as the password"
  createuser dpnAdmin --createdb --login --pwprompt
fi

echo
echo "Creating postgres databases for 'dpn_development' and 'dpn_test'"
dropdb dpn_development
dropdb dpn_test
createdb -T template0 --owner=dpnAdmin dpn_development
createdb -T template0 --owner=dpnAdmin dpn_test

echo
echo "Creating postgres databases for local DPN cluster"
dropdb dpn_cluster_aptrust
dropdb dpn_cluster_chron
dropdb dpn_cluster_hathi
dropdb dpn_cluster_sdr
dropdb dpn_cluster_tdr

createdb -T template0 --owner=dpnAdmin dpn_cluster_aptrust
createdb -T template0 --owner=dpnAdmin dpn_cluster_chron
createdb -T template0 --owner=dpnAdmin dpn_cluster_hathi
createdb -T template0 --owner=dpnAdmin dpn_cluster_sdr
createdb -T template0 --owner=dpnAdmin dpn_cluster_tdr

echo
echo "To test access for dpnAdmin to the dpn_development db,"
echo "run this command and enter 'dpnPass' as the password:"
echo "psql -U dpnAdmin -h localhost -d dpn_development"
