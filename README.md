# SSL+Tcp echo server written in Pony

A [Pony](https://ponylang.org) SSL TCP server that receives a
text message from a client over a TCP connection and
sends it back to the client.

At the moment this is kinda working in that my
two ssl clients are able to speak to it. But,
I can't set_server_verify(true) and at the moment
I'm not sure what that means.

Also, currently not tested with OpenSSL 1.0!!!

# Compile
```
$ cd pony-ssl_tcp_echo_server
$ ponyc ../pony-ssl_tcp_echo_server
```
# Run
Start server in one terminal window:
```
wink@wink-envy:~/prgs/ponylang/pony-ssl_tcp_echo_server (master)
$ ./pony-ssl_tcp_echo_server 
ServerListenNotify.litening:
```
In another terminal window run the client:
```
wink@wink-envy:~/prgs/ponylang/pony-ssl_tcp_echo_server (master)
$ ../pony-ssl_tcp_echo_client/pony-ssl_tcp_echo_client 
Main.create:+
Main.create: 1
Main.create: 2
Main.create: 3
Main.create: 4
Main.create: 5
Main.create:-
MyTCPConnectionNotify.connecting: count=2
MyTCPConnectionNotify.connecting: count=1
MyTCPConnectionNotify.connected: writing "Hello"
MyTCPConnectionNotify.sent: data=Hello
MyTCPConnectionNotify.received: data=Hello
MyTCPConnectionNotify.closed:
```
You'll now see the output from server:
```
$ ./pony-ssl_tcp_echo_server 
ServerListenNotify.litening:
ServerListenNotify.connected:
ServerListenNotify.connected: 1
ServerListenNotify.connected: 2.1
ServerListenNotify.connected: 2.2
ServerListenNotify.connected: 2.3
ServerListenNotify.connected: 2.4
ServerListenNotify.connected: 2.5
ServerListenNotify.connected: 2.6
ServerListenNotify.connected: 3
ServerListenNotify.connected: 4
ServerConnNotify.accepted:
ServerConnNotify.connected: writing "Hello"
ServerConnNotify.sent: data=Hello
ServerConnNotify.received: data=Hello
ServerConnNotify.closed:
```
You can also use c-ssl_client
```
$ ../c-ssl_client/ssl_client 127.0.0.1 8989
Connected with ECDHE-RSA-AES256-GCM-SHA384 encryption
Server certificates:
Subject: /O=Fake Authority
Issuer: /O=Fake Authority
Received: "Hello"
```
# Acknowledgements
From the [actor TCPListener](https://github.com/ponylang/ponyc/blob/master/packages/net/tcp_listener.pony) documentation in the [ponyc](https://github.com/ponylang/ponyc) repo.
