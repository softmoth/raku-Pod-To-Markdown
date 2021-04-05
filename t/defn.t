use Test;

# do NOT move this below following `use` line; the module exports a fake Pod::Defn
constant no-pod-defn = ::('Pod::Defn') ~~ Failure;

use Pod::To::Markdown;

plan :skip-all<Compiler does not support Pod::Defn> if no-pod-defn;

plan +$=pod;
my $ix = 0;

=defn
The term
The definition that
can span multiple lines

is pod2markdown($=pod[$ix++]), q:to/EOF/,
    **The term**

    The definition that can span multiple lines
    EOF
    'Basic =defn';

=for defn
The term
This definition B<contains formatting>.

# https://github.com/Raku/old-issue-tracker/issues/2863
todo 'Raku old-issue-tracker #2863; does not parse defn contents as Pod';
is pod2markdown($=pod[$ix++]), q:to/EOF/,
    **The term**

    This definition **contains formatting**.
    EOF
    '=defn with formatting in contents';

=begin pod

=for defn :formatted<I>
A term
The definition

=for defn :formatted<_>
Another
Definition to test

=end pod
is pod2markdown($=pod[$ix++]), q:to/EOF/,
    *A term*

    The definition

    Another

    Definition to test
    EOF
    'Sequential =defns, different formatting';

# vim:set ft=raku:
