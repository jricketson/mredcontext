# Introduction

This is a code editor. The intention is to allow developers to have better context about where they are when they are editting code. It is not yet at the stage where I can use it to bootstrap itself. At the moment it is more of a proof of concept of some ideas that I have about how to give developers better context.

I am currently investigating how to test this. It is reasonably straightforward to do run command-line tests of some of the code, but currently it is impossible to run integration tests, and also apparently impossible to run in-browser unit tests.

So, I am stopping developing unit tests for the moment, until I hear back from the developers of node-webkit if they have any ideas.

# How to run

First download [node-webkit binary](http://github.com/rogerwang/node-webkit) for your platform, and then execute:

````bash
$ git clone https://github.com/jricketson/mredcontext.git
$ /Path/To/nw mredcontext
````

# How to run tests

install mocha
```
sudo npm install -g mocha

```

then run
```
make test
```