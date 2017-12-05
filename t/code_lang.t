use v6;
use lib <blib/lib lib>;

use Test;
use Pod::To::Markdown;

plan 2;

is pod2markdown($=pod), Q:to/ENDING/.chomp,
```perl6
say "Here is some perl 6 code!";

say "Here is another line here";

exit 0;
```

    Some code without lang set here
ENDING
   'Pod with lang set renders correctly.';


is pod2markdown($=pod, :no-fenced-codeblocks), Q:to/ENDING/.chomp,
    say "Here is some perl 6 code!";

    say "Here is another line here";

    exit 0;

    Some code without lang set here
ENDING
    'Pod with lang and :no-fenced-codeblocks renders correctly';

=begin code :lang<perl6> :allow<B I>
say "B<Here is some perl 6 code!>";

say "Here is another line here";

exit 0;
=end code

=begin code :allow<B I>
Some code I<without> lang set here
=end code
