use v6;

use Test;
use Pod::To::Markdown;

plan 1;

is pod2markdown($=pod), q:to/EOF/.trim,
I like traffic lights.

But not when they are red.
EOF
    'Comments disappear';

=begin pod
I like traffic lights.

=comment Tendentious stuff!

But not when they are red.
=end pod
