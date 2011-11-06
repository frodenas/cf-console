CF-Console
==========

CF-Console is an easy-to-use web-based interface for [Cloud Foundry](http://cloudfoundry.org/),
the industry’s first open Platform as a Service (PaaS) offering.

[![Build Status](https://secure.travis-ci.org/frodenas/cf-console.png)](http://travis-ci.org/frodenas/cf-console)

Demo
----
Check [CF-Console at cloudfoundry.com](http://cf-console.cloudfoundry.com/).

Installation
------------
No DB required, just clone the project and start the server:

* git clone git://github.com/frodenas/cf-console.git
* bundle install
* rails s / thin start / ...

If you plan to deploy this app to a production environment:

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

Changelog
---------

### v0.1: October 23, 2011
* First commit to github


Copyright
---------

Copyright (c) 2011 Ferran Rodenas. See LICENSE for details.
