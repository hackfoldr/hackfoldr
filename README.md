hack.g0v.tw
===========

Organize gdoc and hackpad documents for hackathons.

## Why?

We need a way to organize many dynamic documents before and during hackathon.

The shared folder feature in google docs comes very close to what we want, but
as every document is opened in edit mode, it soon becomes unusable.

Hackpad collections are great too, but we also want to include spreadsheets as one of the items.

So we build this small client-only tool that reads a list of url from an ethercalc document, rendering it in a way similar to google docs folder.  If the document supports read-only mode, we use that by default when it is opened by the user, and an edit link to provided.

For example, with an index like http://ethercalc.org/g0v-hackath2n, you'll get http://hack.g0v.tw/#/g0v-hackath2n/BfddbG2JBOi

## Supported document types

* google docs
* google spreadsheets
* google prensetation
* google drawing
* hackpad
* ethercalc

# CC0 1.0 Universal

To the extent possible under law, Chia-liang Kao has waived all copyright
and related or neighboring rights to twlyparser.

This work is published from Taiwan.

http://creativecommons.org/publicdomain/zero/1.0
