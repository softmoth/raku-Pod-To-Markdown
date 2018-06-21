use v6;

# We just ignore over/back directives (Markdown has limited support for
# this)

use Test;
use Pod::To::Markdown;

plan 1;

=begin pod
=over 4

asdf

Foo

=back 4

asdf

=end pod


is pod2markdown($=pod), q:to/EOF/, 'Ignore =over/=back';
asdf

Foo

asdf
EOF

# vim:set ft=perl6:
