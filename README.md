Hackfoldr
===========

Organize gdoc and hackpad documents for hackathons.

## Why?

We need a way to organize many dynamic documents before and during hackathon.

The shared folder feature in google docs comes very close to what we want, but as every document is opened in edit mode, it soon becomes unusable.  It is also impossible to sort the items and we had to use numeric prefix to achieve that.

Hackpad collections are great too, but we also want to include spreadsheets as one of the item types.

So we build this small single-page static web application that reads a list of url from an EtherCalc document, rendering it in a way similar to a google docs folder.  If the document supports read-only mode, we use that by default when it is opened by the user, and provide an additional edit link.

For example, with an index like http://ethercalc.org/g0v-hackath2n, you'll get http://hackfoldr.org/g0v-hackath2n/BfddbG2JBOi

## Supported document types

* Google Docs
* Google Spreadsheets
* Google Prensetation
* Google Drawing
* Hackpad
* EtherCalc
* Modify this
* Home_made
# Prerequisites
[Node.js](http://nodejs.org/) is required on your system.

Check it with the following commands:

    $ npm -v
    $ node -v

# Install

    $ npm i
    $ npm start

Then after the building message completes, connect to http://localhost:3333/.

# Using Vagrant to develop

[Vagrant](http://docs.vagrantup.com/v2/why-vagrant/index.html) provides easy-to-configure, reproducible, and portable work environments. It will create a headless VirtualBox VM, then prepare the development environment and launch the server for you. You can then develop and test the code anywhere :).

To use Vagrant, you need to install:

- Vagrant (>= 1.6.x)
- VirtualBox

To setup up work environment:

    $ vagrant up

It will take several minutes for the first time, since it will have to configure its Ubuntu VM image. After the operation is finished, browse to `http://localhost:6987/` in your favorite browser. You are all set!

`vagrant halt` if you need to shut down the Vagrant VM. For more information about Vagrant, see the [documentation of Vagrant](http://docs.vagrantup.com).

Note: Have to use older Vagrant (1.3.0+)? Change the `Vagrantfile`.

# Google API key

To use the google APIs client to query YouTube Data API and check live status of Youtube videos, you need to apply your own Google API Key for browser applications at [https://code.google.com/apis/console#:access](https://code.google.com/apis/console#:access). After getting your API key, commit it into app/config.jsenv

# Fork

1. fork to your github account
2. `$ git clone git@github.com/GITHUB_ACCOUNT/hackfoldr`
3. `$ npm install`
4. replace GITHUB_ACCOUNT, HACKFOLDR_ID, DOMAIN_NAME, GA_ID in gulpfile.ls
5. `$ npm run fork`
6. `$ npm run build`
7. `$ ./deploy`

# CC0 1.0 Universal

To the extent possible under law, Chia-liang Kao has waived all copyright
and related or neighboring rights to hackfoldr.

This work is published from Taiwan.

http://creativecommons.org/publicdomain/zero/1.0
