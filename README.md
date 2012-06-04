SQSFraction
===========

SQSFraction is a class that can act as a model object for fractions (i.e. rational
numbers). In addition to the usual expected arithmetic operations (e.g. addition,
multiplication), it also supports the generation of fractions from arbitrary decimals with
arbitrary precision (within limits of the architecture).


Requirements
------------

The SQSFraction code aims to be cross-platform (i.e. OS X and iOS), linking against
Foundation.framework.  While the code has no inherent dependency on a particular 
development environment, the Xcode project encapsulating the code expects Xcode 4 or 
newer.

License
-------

SQSFraction and accompanying code is Copyright (C) 2012 by Synthetiq Solutions LLC and is
made available under the standard 3-clause BSD license.  Please see the license text at 
the top of any header file for full details.

If you wish to use this code but are unable to comply with the BSD license requirements
(including but not limited to attribution), proprietary licenses with or without technical
support are available.  Please contact [support@synthetiqsolutions.com][mailto] for more
information.

Usage
-----

While SQSFraction.h/.m (and its supporting NSDecimalNumber category) can be added
directly to a project, it is more maintainable to add the whole SQSFraction project
to a shared workspace.

Standard project dependency considerations apply: since a category is contained herein, it
is necessary to add -ObjC to the client target's linker flags.  If a shared workspace is
used, setting the user header search path to ${BUILT\_PRODUCTS\_DIR} will let Xcode see
public headers.

To see how to create and manipulate fraction objects, see the headers and the practical
demonstration of fraction/decimal addition in the demo application.

Contributing
------------

If you would like to contribute, please fork the repository, commit your changes, and
submit a pull request.  Your pull request will get quicker attention if:

 * Each commit is limited in scoped and logged with appropriate comments.
 * Your pull request itself is well documented.
 
If you add a feature please also add one or more supporting unit tests.  Also please run
the unit test suite before submitting a pull requests; **pull requests that fail unit
testing will be rejected**.

Finally, and this goes without saying, please make sure that, if applicable, you have
permission from your employer or client to contribute work you have done for hire.

[mailto]: mailto:support@synthetiqsolutions.com?subject=SQSMetricFormatter%20license