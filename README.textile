h2. Impetus

This is a fork of W3C DOM Conformance Test Suite. The original W3C code is
in disrepair. The W3C CVS repository can be checked out from here:

  cvs -d :pserver:anonymous@dev.w3.org:/sources/public checkout 2001/DOM-Test-Suite

The build documentation is also out-of-date:

  http://www.w3.org/DOM/Test/Documents/DOMTSBuild.html

And the mailing list is inactive:

  http://lists.w3.org/Archives/Public/www-dom-ts/

This fork attempts to improve the situation.

h2. Building

Install Apache Ant. "ant -p" will display all the possible targets.
An example run is "ant dom1-core-gen-jsunit", which will generate
the ECMAScript tests for DOM Core Level 1.

h2. Running the ECMAScript Tests

Supposedly, you can just point your user agent here:

  build/ecmascript/jsunit/testRunner.html

Then you select the tests to you want to run from:

  build/ecmascript/level(1|2|3)/

But, it doesn't work right now. Check back later.
