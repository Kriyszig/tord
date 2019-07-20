# TorD

[![Build Status](https://travis-ci.com/Kriyszig/tord.svg?branch=master)](https://travis-ci.com/Kriyszig/tord)

[![Knight](https://www.torproject.org/static/images/home/svg/surveillance.svg?h=688a829c)](https://www.torproject.org/)

TorD is a simple wrapper arounf D programming language's `std.net.curl` to make requests through [Tor](https://www.torproject.org/). TorD provides a
simple hasle free way to make requests through Tor. Born out of my new fond love for Onion Routing and D Programming langauge, the real
inspiration for this came from the JavaScript library [tor-request](https://github.com/talmobi/tor-request) by [talmobi](https://github.com/talmobi)

### What is Tor?

Tor [The Onion Router] is a program devloped to protect your privacy online.  You can watch [this video](https://www.youtube.com/watch?v=VmsFxBEN3fc) to learn
more about Tor. On the plus side, Tor is open source - [git repository](https://gitweb.torproject.org/tor.git). If you have any questions regarding it's working,
you can check the source code yourself or as the developers on the Tor mailing list - they are a nice bunch of people :)

#### Note: This project is still in the initital development stage. Breaking changes can and will happen.

This project will not make it to DUB until the API is stable.

Requirements:
* Tor
* A D compiler - dmd or ldc

You can find installation instruction for Tor on their website. If you are going to use the Tor browser, download the Tor browser bundle.

#### Usage

```d
import tord.request: Request;

auto tr = Request();
auto tresponse = tr.get("https://api.ipify.org");
//import std.stdio: writeln;
//writeln(tresponse);

import std.net.curl: get;
auto response = get("https://api.ipify.org");
assert(tresponse != response);
```

The above piece of code fetches your IP address over Tor and the normal IP and compares them to make sure they aren't the same.

Contributions and suggestions are welcome (^_^)
