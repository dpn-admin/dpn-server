# DPN::Server

[![Build Status](https://travis-ci.org/dpn-admin/dpn-server.svg?branch=master)](https://travis-ci.org/dpn-admin/dpn-server)

A Rails implementation of the DPN RESTful communication layer. The current
maintainer is [Bryan Hockey](https://github.com/malakai97).


# Installation and Deployment

## Dependencies

The project is built and tested with ruby 2.2.1.  Bundler is required.
All other dependencies are described in the gemfile.

## Getting the Files

```
git clone git@github.com:dpn-admin/dpn-server.git
bundle install --path .bundle
```

## Configuration

### Development, Test

The default configuration should be sufficient.

### Production 

The environment variables in config/environments/production.rb must be set
under all environments.  We use [dotenv](https://github.com/bkeepers/dotenv)
to manage these, so you can set them in a .env.production file.
See .env.production.example for the variables that are
required and what they do.  Before running any of the
```bundle``` commands, you should have these variables defined in your shell
environment.

If you are using Apache with Passenger, An example Apache virtualhost file is 
included in ```apache-dpn-rails-example.conf```


You will need to precompile the assets. This will create a ```public/assets/``` directory.

```
bundle exec rake assets:precompile
```

## Database

### Development, Test

These environments use a sqlite database.  No configuration is required beyond
running 

```
bundle exec rake db:setup
```

### Production
You should create a database for your environment.  The project expects a
MySQL database, and has not been tested with other RDBMSs.

The connection credentials should be defined in .env.production, but 
config/database.yml offers more finely tuned options.

You should not have to create or populate the tables.  Rails will do this
for you, assuming you have populated the configuration variables.

```
bundle exec rake db:setup
```

## Storage

Separate staging and repository directories are required
(and specified in config/environments/*.rb). Pruning of old files
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

The admin interface can be reached at /admin/

## Firewall

Each other node will need https and ssh (for rsync) access to your instance.

## RSync

To allow rsync over ssh, you will need to install each other node's public keys
in the rsync user's authorized keys.  Since this grants ssh access for a real
user, we recommend using a chroot environment and restricting the shell using
[rssh](http://www.pizzashack.org/rssh/).

In order to get bags from other nodes, you'll need to mint a ssh keypair.  The
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

Likewise, the correspending token used to make requests against other nodes is stored as
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


