[![Build Status](https://travis-ci.org/softmoth/raku-Pod-To-Markdown.svg?branch=master)](https://travis-ci.org/softmoth/raku-Pod-To-Markdown) [![Windows Status](https://ci.appveyor.com/api/projects/status/github/softmoth/raku-Pod-To-Markdown?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/softmoth/raku-Pod-To-Markdown/branch/master)

NAME
====

Pod::To::Markdown - Render Pod as Markdown

SYNOPSIS
========

From command line:

    $ raku --doc=Markdown lib/To/Class.rakumod

From Raku:

```raku
use Pod::To::Markdown;

=NAME
foobar.pl

=SYNOPSIS
    foobar.pl <options> files ...

print pod2markdown($=pod);
```

EXPORTS
=======

    class Pod::To::Markdown
    sub pod2markdown

DESCRIPTION
===========

### method render

```raku
method render($pod, Bool :$no-fenced-codeblocks --> Str)
```

Render Pod as Markdown

To render without fenced codeblocks (```` ``` ````), as some markdown engines don't support this, use the :no-fenced-codeblocks option. If you want to have code show up as ```` ```raku```` to enable syntax highlighting on certain markdown renderers, use:

    =begin code :lang<raku>

### sub pod2markdown

```raku
sub pod2markdown($pod, Bool :$no-fenced-codeblocks --> Str)
```

Render Pod as Markdown, see .render()

LICENSE
=======

This is free software; you can redistribute it and/or modify it under the terms of The [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

