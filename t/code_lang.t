use v6;
use lib <blib/lib lib>;

use Test;
use Pod::To::Markdown;

plan 1;

my $markdown = Q:to/ENDING/;
```perl6
say "Here is some perl 6 code!";

say "Here is another line here";

exit 0;
```

    Some code without lang set here
ENDING

is pod2markdown($=pod), $markdown.chomp,
   'Pod with lang set renders correctly.';

=begin pod
=begin code :lang<perl6>
say "Here is some perl 6 code!";

say "Here is another line here";

exit 0;
=end code
=begin code
Some code without lang set here
=end code
=end pod
