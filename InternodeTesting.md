## Internode Testing

Each DPN node runs a demo or staging server, and from time to time, as
we roll out new features, we will perform internode tests to ensure
that we can still sync our registries, replicate bags, etc.

We already have a set of test data fixtures in the
test/fixtures/integration directory. When you run a [local DPN
cluster](Custer.md), the nodes in the cluster load data from those
fixtures. The fixtures also include a set of six DPN bags in the form
of tar files.

You can load those same fixtures into your demo/staging node whenever
you want using this rake command:

```
bundle exec rake integration:reset
```

That command does the following:

1. Deletes all data from the tables underling Bag, FixityCheck,
ReplicationTransfer, RestoreTransfer and VersionFamily.

2. Loads fixture data back into those tables from the directory
test/fixtures/integration/<your_node>

3. If your node has defined a custom method for setting transfer link
URLs and copying or symlinking files in a staging directory, the reset
task will execute that as well.

You can run the `reset` task on your own local dev node at any
time. It's safe, and it will leave you with a small clean dataset.

You can also run the reset steps separately using the tasks
`delete_test_data` and `load_fixtures`, though note that these will
not perform step 3 above.

### Notes on Data Reset

1. The `reset` task does not touch any tables other than those underlying
underling Bag, FixityCheck, ReplicationTransfer, RestoreTransfer and
VersionFamily. This means that all of your records for Member, Node,
FixityAlg, Protocol etc. remain intact after a reset.

2. The `reset` and `load_fixtures` tasks will create the following
records in your database if they don't already exist:
   * A Protocol called rsync
   * A FixityAlg called sha256
   * A member called "Integration Test University" with a fixed UUID,
     defined in the constant FixtureHelper::TEST_MEMBER_UUID

3. To simplify testing, all of the Bags and Transfer requests will
have created_at and updated_at set to April 1, 2016 00:00:00 UTC.
