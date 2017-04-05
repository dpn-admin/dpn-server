[![Stories in Ready](https://badge.waffle.io/dpn-admin/dpn-server.png?label=ready&title=Ready)](https://waffle.io/dpn-admin/dpn-server)
# DPN::Server
![dpn_server](https://cloud.githubusercontent.com/assets/26936378/24721992/09079786-1a10-11e7-92a3-4265d7781059.jpg)

[![Build Status](https://travis-ci.org/dpn-admin/dpn-server.svg?branch=master)](https://travis-ci.org/dpn-admin/dpn-server)
[![Code Climate](https://codeclimate.com/github/dpn-admin/dpn-server/badges/gpa.svg)](https://codeclimate.com/github/dpn-admin/dpn-server)
[![Test Coverage](https://codeclimate.com/github/dpn-admin/dpn-server/badges/coverage.svg)](https://codeclimate.com/github/dpn-admin/dpn-server/coverage)

A Rails implementation of the DPN RESTful communication layer. The current
maintainer is [Bryan Hockey](https://github.com/malakai97).

# Dependencies

The project is built and tested with mri. For specific ruby version support,
consult `.travis.yml` or the Travis CI build page.  Bundler is required.
All other dependencies are described in the gemfile.

# Development and Test

```
git clone git@github.com:dpn-admin/dpn-server.git
cd dpn-server
git submodule update --init --recursive
bundle install --path .bundle
bundle exec rake config
bundle exec rake db:setup
bundle exec rspec
```

# Production

## Configuration

### Configuration Files
Configuration is set in the yaml files in the `config` folder
that are generated by `bundle exec rake config`.  These files
are excluded from version control.  Example files (denoted by
the `.example` suffix) are the best source of information for
configuring these files.

### Gems Specific to My Environment
You may wish to include additional gems specific to your
deployment, e.g. "mysql2".  This can be done by creating a file
Gemfile.local with your gems.  See Gemfile.local.example for
more information.

### Firewall
Each other node will need incoming https to your instance.

### Installation

Once the files are in place and configured appropriately
on your application server:

```
bundle install --path .bundle
bundle exec rake db:migrate
bundle exec rake assets:precompile
```

### Nodes and Other Data

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

The easiest way to get the data required to run your installation is to grab the
production seed files from [the private repo](https://github.com/dpn-admin/private)
and unpack them into `db/seeds/production-seeds.d`.  You will need to modify the 
nodes seed to use the credentials specific to your node.

From there, you can simply run `bundle exec rake db:seed`.  Note that the 
installation steps, above, should already be complete.  This operation is 
idempotent.

## Replication and Synchronization

dpn-server now provides built-in clients to handle replication and
synchronization from other nodes.  If you wish to use this feature,
you must additionally perform the following configuration steps.

To disable this feature, simply specify `:disbled` in `config/dpn.yml`.
Consult `config/dpn.yml.example` for more information.

### Firewall
Each other node will need ssh (for rsync) access to your instance.

### RSync
In order to get bags from other nodes, you'll need to mint an ssh keypair.  The
private key should be installed locally, and the public key issued to each other
node.

### Storage
Separate staging and repository directories are required
(and specified in config/secrets.yml). Pruning of old files
in the staging directory is considered environment-specific and
therefore out of scope for this project.

### Redis

You must install redis.  On Debian-based machines, sufficient packages are
available in apt: `apt install redis-server redis-tools`

### Resque-Pool
All jobs utilize a pool of workers.  To start the pool, spawn the process via:

```
bundle exec rake resque:pool
```

### Resque-Scheduler
Synchronization jobs are driven by resque-scheduler.  This process can
be started via:

```
bundle exec rake resque:scheduler
```

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
