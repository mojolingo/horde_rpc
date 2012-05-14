horde_rpc
===========

horde_rpc is a client library for accessing the Horde XML-RPC interface from Ruby.

Features
--------

* Retrieve Client records
* Record time for Clients

Requirements
------------

* A working Horde installation

Install
-------

    gem install horde_rpc

Examples
--------

```ruby
  require 'horde_rpc'
  horde = HordeRPC.new 'http://horde.bar.com'
  client = horde.first_client_for_company 'UberClient'
  puts "Client by name 'UberClient' has ID #{client['id']}"

  horde.record_time :client       => client['id'],
                    :date         => Date.today,
                    :hours        => 3.5,
                    :employee     => 'foo@bar.com',
                    :description  => 'Did stuff'
                    :type         => 1
```

Author
------

Original author: Ben Langfeld

Links
-----
* [Source](https://github.com/mojolingo/horde_rpc)
* [Documentation](http://rdoc.info/github/mojolingo/horde_rpc/master/frames)
* [Bug Tracker](https://github.com/mojolingo/horde_rpc/issues)

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * If you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2012 Mojo Lingo LLC. MIT licence (see LICENSE for details).
