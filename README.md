[![Stories in Ready](https://badge.waffle.io/dpn-admin/dpn-server.png?label=ready&title=Ready)](https://waffle.io/dpn-admin/dpn-server)
# DPN::Server

[![Build Status](https://travis-ci.org/dpn-admin/dpn-server.svg?branch=master)](https://travis-ci.org/dpn-admin/dpn-server)
[![Code Climate](https://codeclimate.com/github/dpn-admin/dpn-server/badges/gpa.svg)](https://codeclimate.com/github/dpn-admin/dpn-server)
[![Test Coverage](https://codeclimate.com/github/dpn-admin/dpn-server/badges/coverage.svg)](https://codeclimate.com/github/dpn-admin/dpn-server/coverage)

A Rails implementation of the DPN RESTful communication layer. The current
maintainer is [Bryan Hockey](https://github.com/malakai97).


# Development and Test

The project is built and tested with ruby 2.2.1.  Bundler is required.
All other dependencies are described in the gemfile.

```
git clone git@github.com:dpn-admin/dpn-server.git
bundle install --path .bundle
bundle exec rake config
bundle exec rake db:setup
```

Then, if you wish to run the tests:

``` bundle exec rspec ```

Or if you want to poke around the admin interface:

```
bundle exec rake db:admin_user # this will display the login credentials.
bundle exec rails server
```

Then visit http://localhost:3000/admin.


# Running a Local DPN Cluster
It is possible to run a local DPN cluster.  This can be quite useful
for debugging and development.  More information can be found in
[Cluster.md](Cluster.md).

# Production

## Dependencies

The project is built and tested with ruby 2.2.1.  Bundler is required.
All other dependencies are described in the gemfile.

## Getting the Files

```
git clone git@github.com:dpn-admin/dpn-server.git
bundle install --path .bundle
```

## Configuration

Configuration is set in config/database.yml and
config/secrets.yml.  These two files are excluded from git.  You
may also wish to include additional gems specific to your
deployment, e.g. "mysql2".  This can be done by creating a file
Gemfile.local with your gems.  See Gemfile.local.example for
more information.

A generator exists to build these basic files, but it only
includes development and test configurations.  You may wish
to use it to get started, but the example files are the best
source of information.  The generator is ```bundle exec rake config```

### Changes from Previous Versions
Previously, we used [dotenv](https://github.com/bkeepers/dotenv) for
configuration.  This usage is now deprecated, in favor of editing
the above yaml files, which are excluded from git.  You may wish to
continue using the old functionality at this time.  To facilitate this,
a set of generators are provided for you.  Simply run
```bundle exec rake config:deprecated```, which will generate the
above described configuration files configured to read the same environment
variables as before.

### Assets

You will need to precompile the assets. This will create a ```public/assets/``` directory.

```
bundle exec rake assets:precompile
```

## Database

You should create a database for your environment.  To date, the project
has been tested with MySQL and PostgreSQL.

Define your database in config/database.yml.  See the configuration section
for more information.

You should not have to create or populate the tables.  Rails will do this
for you, assuming you have populated the configuration variables.

```
bundle exec rake db:setup
```

## Storage

Separate staging and repository directories are required
(and specified in config/secrets.yml). Pruning of old files
in the staging directory is considered environment-specific and
therefore out of scope for this project.  (We use find. You may
want something more robust if your bandwidth isn't "free.")


## Administration

In order to use the administration interface, you must create an admin user.
You will need to do this in the rails console in order for the user's password
to be correctly encrypted.

```
RAILS_ENV=production bundle exec rails console
```

```ruby
User.create!(
  email: "you@domain.org",
  admin: true,
  password: "unencrypted_passoword")
```

The admin interface can be reached at /admin/.  The admin interface is not
necessarily easier to use than the rails console for all tasks.

## Firewall

Each other node will need incoming https and ssh (for rsync) access to your instance.

## RSync

To allow rsync over ssh, you will need to install each other node's public keys
in the rsync user's authorized keys.  Since this grants ssh access for a real
user, we recommend using a chroot environment and restricting the shell using
[rssh](http://www.pizzashack.org/rssh/).

In order to get bags from other nodes, you'll need to mint an ssh keypair.  The
private key should be installed locally, and the public key issued to each other
node.

## Jobs

Various jobs power some of the facilities of the application.  They use
[ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html), which allows
you to substitute the job runner of your choice.  The default job runner is
[Delayed Job](https://github.com/collectiveidea/delayed_job), which makes use of
the "delayed_jobs" database table that was generated for you.

## Node Configuration

Nodes must be configured once via either the rails console
or the admin interface.  E.g.:

```ruby
Node.create!(
  namespace: "hathi",
  api_root: "https://dpn.hathitrust.org/",
  private_auth_token: "unencrypted_token",
  auth_credential: "unencrypted_credential")
```

Do to the secret nature of some of these credentials, no script has yet been
created to automate this task.  See below for more information.

### Identification

At minimum, you will need to know each node's namespace string and api root.  The
rest will be obtained when the project queries the node.

### Authentication

Authentication is handled via authentication tokens, which must be generated on a
per-node basis.

Authentication of incoming requests is allowed via Node.private_auth_token.
You should mint these tokens for each node.  You will not need them again
after storing them. A one-way hash function is applied to the token, so if the
authenticated node loses the token a new one will need to be minted.

Likewise, the corresponding token used to make requests against other nodes is stored as
Node.auth_credential.  These are subject to two-way encryption.  These must be obtained
from each other node.

Note that for the local node, the auth_credential and private_auth_token should be the
same (before encryption).


# Contributing

1. Fork it ( https://github.com/dpn-admin/dpn-server/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

# License

Copyright (c) 2015 The Regents of the University of Michigan.
All Rights Reserved.
Licensed according to the terms of the Revised BSD License.
See LICENSE.md for details.
