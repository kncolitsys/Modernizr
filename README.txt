# modernizr-server

[Modernizr](http://modernizr.com) is a JavaScript library for detecting
whether various HTML5 and CSS3 properties are supported by a viewer's 
browser. However, being JavaScript, these properties sit entirely on the 
client's side of browser. This can be a bummer if you'd like to make use
of the client's capabilities in one's server logic.

As James G Pearce states in his server side Modernizr solution:
"Progressive enhancement, media queries and body classes are fine for tweaking
sites and their appearance. But for structural changes to sites and pages,
sometimes it's much simpler to just emit the right markup from the server in the
first place."

Amen. Why send copious amounts of data over the wire when we don't have to?

Server-side modernizr is a way to bring browser capability data to your
server code. For example, in cfml:

    <cfinclude template="modernizr-server.cfm" />

    <cfoutput>
        The server knows:
        <cfloop index="feature" list="#StructKeyList(stcModernizr)#">
            <br /> #feature#: #stcModernizr[feature]#
        </cfloop>
    </cfoutput>


Outputs the following:
    The server knows:
    canvas: 1
    canvastext: 1
    geolocation: 1
    crosswindowmessaging: 1
    websqldatabase: 1
    indexeddb: 0
    hashchange: 1
    ...

This is exactly the same feature detectection available to cfml applications 
as through the (Javascript) API on the client.

## How to use it (with cfml)

Download the latest Modernizr script from
[http://modernizr.com](http://modernizr.com) and place it in the `modernizr.js`
directory. Within that directory, the file should also be called `modernizr.js`,
but it can be either the compressed or uncompressed version of the file. (If you
want to put it in a different place, see the note at the bottom of this
section.)

Ideally, the `modernizr-server.cfm` code should be included at the very start of
your cfml page - or at the very least before any HTML is emitted:

    <cfinclude template="modernizr-server.cfm" />
        ...

In any subsequent point of your script, you can use the `stcModernizr` structure in the
same way that you would have used the `Modernizr` object on the client:

    <cfscript>
    if (stcModernizr['svg'] eq 1) {
        ...
    } elseif (stcModernizr['canvas'] eq 1) {
        ...
    }
    </cfscript>
        
See the Modernizr [documents](www.modernizr.com/docs/) for all of the features
that are tested and available through the API.
        
Some features, (in particular `video`, `audio`, `input`, and `inputtypes`)
have sub-features, so these are available as nested cfml structures:

    <cfscript>
    if (stcModernizr['inputtypes']['search'] eq 1) {
        WriteOutput("<input type='search' ...");
    } else {
        WriteOutput("<input type='text' ...");
    }
    </cfscript>
    
All features and sub-features are returned as integer `1` or `0` for `true` or
`false`, so they can be used in logical evaluations in cfml. 


## Relocating modernizr.js

If you want to place the Modernizr script in a specific place on your server,
you can alter its (relative) path at the top of the `modernizr-server.cfm` library.
By default this is in a peer folder to the library file:

    modernizr_js = '../modernizr.js/modernizr.js';

The Javascript file does *not* have to be in a folder that's directly visible to
a web browser - just one that the `modernizr-server.cfm` library can read.
Nevertheless, if you are also using Modernizr on the client, you might have a
copy of the script on your web server already, and you can use that.


## How it works

The first time the user accesses a page which includes the modernizr-server.php
library, the library sends the Modernizr script to the client, with a small
script added to the end. Modernizr runs as usual and populates the feature test
results.

The small suffix script then serializes the results into a concise cookie, which
is set on the client using Javascript. It then refreshes the page immediately.

This second time the cfml script is executed, the library takes the
cookie and instantiates the server-side `session['Modernizr']` object with its contents. 

While either of the cookie or session remain active, no further execution of the
Modernizr script will take place. If they both expire, the next request to a
page containing `modernizr-server.cfm` will cause the browser to rerun the
Modernizr tests again.


## Caveats

This library relies on the browser reloading the page it just visited - to
re-request it with the Modernizr data in a cookie. In theory, if the cookie does
not get set on the client correctly, the refresh could loop indefinitely. Hopefully
a solution to this problem will be coming shortly.

You are advised to first use `modernizr-server.cfm` on a page that is accessed by
the user with a `GET` method. If the first request made is a `POST` (from a form,
for example), the refresh of the page will cause the browser to ask the user if
they want to immediately resubmit the form, which may confuse them.