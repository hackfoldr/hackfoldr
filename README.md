hack.g0v.tw
===========

Organize gdoc and hackpad documents for hackathons.

## Why?

We need a way to organize many dynamic documents before and during hackathon.

The shared folder feature in google docs comes very close to what we want, but as every document is opened in edit mode, it soon becomes unusable.  It is also impossible to sort the items and we had to use numeric prefix to achieve that.

Hackpad collections are great too, but we also want to include spreadsheets as one of the item types.

So we build this small single-page static web application that reads a list of url from an EtherCalc document, rendering it in a way similar to a google docs folder.  If the document supports read-only mode, we use that by default when it is opened by the user, and provide an additional edit link.

For example, with an index like http://ethercalc.org/g0v-hackath2n, you'll get http://hack.g0v.tw/#/g0v-hackath2n/BfddbG2JBOi

## Supported document types

* Google Docs
* Google Spreadsheets
* Google Prensetation
* Google Drawing
* Hackpad
* EtherCalc

# Install

    % npm i
    % npm run start

# Using vagrant to develop

[Vagrant](http://docs.vagrantup.com/v2/why-vagrant/index.html) provides easy to configure, reproducible, and portable work environments.

To use vagrant, you need to install:

- vagrant (> 1.1.x)
- virtualbox

To setup up work environment:

    % vagrant box add g0v https://dl.dropboxusercontent.com/u/4339854/g0v/g0v-ubuntu-precise64.box
    % vagrant up

After `vagrant up`, browse http://localhost:6987/ in your favorite browser. You are all set!

# CC0 1.0 Universal

To the extent possible under law, Chia-liang Kao has waived all copyright
and related or neighboring rights to hackfoldr.

This work is published from Taiwan.

http://creativecommons.org/publicdomain/zero/1.0
