# Pod::To::Markdown (Perl6)

Render Pod as Markdown.
[![Build Status](https://travis-ci.org/softmoth/perl6-pod-to-markdown.svg?branch=master)](https://travis-ci.org/softmoth/perl6-pod-to-markdown)

## Installation

Using panda:
```
$ panda update
$ panda install Pod::To::Markdown
```

Using ufo:
```
$ ufo
$ make
$ make test
$ make install
```

## Usage:

From command line:

    $ perl6 --doc=Markdown lib/class.pm

From Perl6:

```
use Pod::To::Markdown;

=NAME
foobar.pl

=SYNOPSIS
    foobar.pl <options> files ...
	
say pod2markdown($=pod);
```
