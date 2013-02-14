
JSnake
======

JSnake is a project created in order for me to learn Node.js, Socket.IO, Twitter Bootstrap, Knockout.js and so on.

This is licensed under the MIT license.

Setup
-----

1. Run the commands below in console.

		$ git clone git://github.com/s-shin/jsnake.git
		$ cd jsnake
		$ npm install
		$ cake build
		$ cake devel

2. Open a web browser and access <http://localhost:3000/>
3. Input `/test` as "Server address" (see [js/main.coffee](./tree/master/js/main.coffee)).

Environment
-----------

I checked the execution in Node.js v0.8.1 and following modules.

- underscore@1.4.4
- redis@0.8.2
- jade@0.28.1
- winston@0.6.2
- express@3.1.0
- socket.io@0.9.13
