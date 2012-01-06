CF-Console
==========

CF-Console is an easy-to-use web-based interface for your [Cloud Foundry](http://cloudfoundry.org/) instances.

Continuous Integration
----------------------

[![Build Status](https://secure.travis-ci.org/frodenas/cf-console.png)](http://travis-ci.org/frodenas/cf-console)

Demo
----
Check [CF-Console at cloudfoundry.com](http://cf-console.cloudfoundry.com/).

Installation
------------
No DB required, just clone the project and start the server:

* git clone git://github.com/frodenas/cf-console.git
* bundle install
* thin start <- It must be an app server with EventMachine and Ruby 1.9 support
(e.g. [Thin](http://code.macournoyer.com/thin/) or [Rainbows!](http://rainbows.rubyforge.org/))

If you plan to deploy this app to a production environment:

* Set your brand details and Cloud Foundry providers at /config/configatron/defaults.rb
* Insert your Google Analytics Web Property ID (UA-XXXXX-X) at /app/assets/javascripts/application.js
* Change the secret token at /config/initializers/secret_token.rb
* Remove "= render "layouts/forkapp"" at /app/views/layouts/application.html.haml
* precompile the assets -> RAILS_ENV=production rake assets:precompile

Testing
-------

In order to test the application, a suite of [RSpec](https://www.relishapp.com/rspec) tests are provided.
You don't need to have a Cloud Foundry instance running in order to pass the tests, as pre-recorded HTTP
interactions are also provided thanks to [VCR](https://www.relishapp.com/myronmarston/vcr).

So just type:

    rake spec

Contributing
------------
In the spirit of [free software](http://www.fsf.org/licensing/essays/free-sw.html), **everyone** is encouraged to help
improve this project.

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by closing [issues](http://github.com/frodenas/cf-console/issues)
* by reviewing patches


Submitting an Issue
-------------------
We use the [GitHub issue tracker](http://github.com/frodenas/cf-console/issues) to track bugs and features.
Before submitting a bug report or feature request, check to make sure it hasn't already been submitted. You can indicate
support for an existing issue by voting it up. When submitting a bug report, please include a
[Gist](http://gist.github.com/) that includes a stack trace and any details that may be necessary to reproduce the bug,
including your gem version, Ruby version, and operating system. Ideally, a bug report should include a pull request with
 failing specs.


Submitting a Pull Request
-------------------------
1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add specs for your feature or bug fix.
5. Run <tt>rake spec</tt>. If your changes are not 100% covered, go back to step 4.
6. Commit and push your changes.
7. Submit a pull request.

Authors
-------

By [Ferran Rodenas](http://www.rodenas.org/) <frodenas@gmail.com>

Copyright
---------

See [LICENSE](https://github.com/frodenas/cf-console/blob/master/LICENSE) for details.
Copyright (c) 2011 [Ferran Rodenas](http://www.rodenas.org/).
