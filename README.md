Quickwing
=========

Quickwing is a sister project of [Slowwing](https://github.com/wukerplank/quickwing). This is the "sophisticated" implementation of Quickwing. It decouples the user request from the API requests (by using RabbitMQ and node.js) to make the user experience snappier. The API requests will be done by two consumers (one for Foursquare, one for Yelp!). After they get results they normalize them and push them back into RabbitMQ. The node.js app will get them and push those results to the user's browser via socket.io.

Installation
------------

If you want to run this app you will need to have Ruby (>=1.8.7), RubyGems, Bundler, RabbitMQ and node.js installed.

You can either download a ZIP package or clone the whole repository:

    git clone https://github.com/wukerplank/quickwing.git

Go to the cloned folder and run the bundle command:

    bundle

Now create a `application.yml` file to store your API credentials

    cp config/application.yml.example config/application.yml

If you don't have API keys you can register here:

- [Foursquare](https://developer.foursquare.com)
- [Yelp!](http://www.yelp.com/developers)

Edit the `config/application.yml` file and enter your keys.

Make sure your RabbitMQ server is running and start the Rails app:

    rails s

Now get node up and running:

    cd node_modules
    npm install
    node app.js

Finally, we need to start the consumers:

    rake consumer:yelp
    rake consumer:foursquare

Navigate your browser to [http://localhost:3000/](http://localhost:3000/) and start searching!

Copyright
---------

Copyright (C) 2013 Christoph Edthofer, Thomas Esterer and Lukas Mayerhofer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
