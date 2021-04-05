unit class Pod::To::Markdown:ver<0.2.0>:auth<github:softmoth>;

# NB We can rely on Pod::To::HTML to define Pod::Defn for us on old
# compilers
use Pod::To::HTML:auth<github:Raku>;

#my sub Debug(&code) { &code() }
my sub Debug(&code) { }

method render($pod, Bool :$no-fenced-codeblocks --> Str)
{
    my Bool $*fenced-codeblocks = !$no-fenced-codeblocks;
    my Bool $*in-code-block = False;
    my $*positional-separator = "\n\n";
    node2md($pod) ~ "\n";
}

sub pod2markdown($pod, Bool :$no-fenced-codeblocks --> Str)
is export
{
    return Pod::To::Markdown.render($pod, :$no-fenced-codeblocks);
}


multi sub node2md(Pod::Heading $pod) {
    # Collapse contents without newlines, is this correct behaviour?
    my $*positional-separator = ' ';
    my Str $head = node2md($pod.contents);
    head2md($pod.level, $head);
}

multi sub node2md(Pod::Block::Code $pod) {
    my $*in-code-block = True;
    code2md($pod.contents>>.&node2md.join.trim-trailing,
        :lang($pod.config<lang>));
}

multi sub node2md(Pod::Block::Named $pod) {
    given $pod.name {
        when 'pod'    { node2md($pod.contents) }
        when 'para'   { $pod.contents>>.&node2md.join(' ') }
        when 'defn'   { node2md($pod.contents) }
        when 'config' { Debug { die "NAMED CONFIG" }; '' }
        when 'nested' { Debug { die "NAMED NESTED" }; '' }
        default       { head2md(1, $pod.name) ~ "\n\n" ~ node2md($pod.contents); }
    }
}

multi sub node2md(Pod::Block::Para $pod) {
    $pod.contents>>.&node2md.join
}

sub entity-escape($str) {
    $str.trans([ '&', '<', '>' ] => [ '&amp;', '&lt;', '&gt;' ])
}

multi sub node2md(Pod::Block::Table $pod) {
    node2html($pod)
            .trim
            # Rakudo's Pod parsing is incomplete; see Rakudo issue #2863
            #
            # Here we implement a hack to allow Unicode entities to be
            # displayed in tables; it's a specific enough pattern that it
            # should not unintentionally transform the text.
            #
            # See Pod::To::Markdown issue #26
            .subst(:g, rx/ 'E&lt;0x' (<.xdigit> ** 4) '&gt;' /, { "&#x{$0};" })
}

multi sub node2md(Pod::Block::Declarator $pod) {
    my $lvl = 2;
    return '' unless $pod.WHEREFORE.WHY;
    my $what = do given $pod.WHEREFORE {
        when Method {
            signature2md($lvl, $_, :method);
        }
        when Sub {
            signature2md($lvl, $_, :!method);
        }
        when .HOW ~~ Metamodel::ClassHOW {
            if (.WHAT =:= Attribute) {
                my $name = .gist;
                $name .= subst('!', '.') if .has_accessor;
                head2md($lvl+1, "has $name");
            }
            else {
                head2md($lvl, "class $_.perl()");
            }
        }
        when .HOW ~~ Metamodel::ModuleHOW {
            head2md($lvl, "module $_.perl()");
        }
        when .HOW ~~ Metamodel::PackageHOW {
            head2md($lvl, "package $_.perl()");
        }
        default {
            ''
        }
    }
    $what ~ "\n\n" ~ node2md($pod.WHEREFORE.WHY.contents);
}

multi sub node2md(Pod::Block::Comment $pod) {
    ''
}

my %Mformats =
    U => '_',
    I => '*',
    B => '**',
    C => '`';

my %HTMLformats =
    R => 'var';

multi sub node2md(Pod::FormattingCode $pod) {
    return '' if $pod.type eq 'Z';
    my $text = $pod.contents>>.&node2md.join;

    # It is safer to strip formatting in code blocks
    return $text if $*in-code-block;

    if $pod.type eq 'L' {
        if $pod.meta.elems > 0 {
            $text =  '[' ~ $text ~ '](' ~ $pod.meta[0] ~ ')';
        } else {
            $text = '[' ~ $text.subst(/ ^ '#' /, '') ~ '](' ~ $text ~ ')';
        }
    }
    # If the code contains a backtick, we need to do more work
    if $pod.type eq 'C' and $text.contains('`') {
        # We need to open and close with some number larger than the largest
        # contiguous number of backticks
        my $length = $text.match(/'`'*/, :g).sort.tail.chars + 1;
        my $symbol = %Mformats{$pod.type} x $length;
        # If text starts with a backtick we need to pad it with a space
        my $begin = $text.starts-with('`')
            ?? $symbol ~ ' '
            !! $symbol;
        # likewise if it ends with a backtick that must be padded as well
        my $end = $text.ends-with('`')
            ?? ' ' ~ $symbol
            !! $symbol;
        $text = $begin ~ $text ~ $end
    }
    else {
        $text = %Mformats{$pod.type} ~ $text ~ %Mformats{$pod.type}
            if %Mformats{$pod.type} :exists;
    }

    $text = sprintf '<%s>%s</%s>',
        %HTMLformats{$pod.type},
        $text,
        %HTMLformats{$pod.type}
        if %HTMLformats{$pod.type} :exists;

    $text;
}

multi sub node2md(Pod::Item $pod) {
    my $level = $pod.level // 1;
    my $markdown = '* ' ~ node2md($pod.contents[0]);
    $markdown ~= "\n\n" ~ node2md($pod.contents[1..*]).indent(2)
        if $pod.contents.elems > 1;
    $markdown.indent($level * 2);
}

multi sub node2md(Pod::Defn $pod) {
    my $fmt = %Mformats{$pod.config<formatted> // 'B'} // '';
    $fmt ~ node2md($pod.term) ~ $fmt ~ "\n\n" ~ node2md($pod.contents)
}

multi sub node2md(Positional $pod) {
    $pod>>.&node2md.grep(*.?chars).join($*positional-separator)
}

multi sub node2md(Pod::Config $pod) {
    ''
}

multi sub node2md($pod) {
    $pod.Str
}


sub head2md(Int $lvl, Str $head) {
    given min($lvl, 6) {
        when 1  { $head ~ "\n" ~ ('=' x $head.chars) }
        when 2  { $head ~ "\n" ~ ('-' x $head.chars) }
        default { '#' x $_ ~ ' ' ~ $head }
    }
}

sub code2md(Str $code, :$lang) {
    if $lang and $*fenced-codeblocks {
        "```$lang\n$code\n```"
    }
    else {
        $code.indent(4)
    }
}

sub signature2md(Int $lvl, Callable $sig, Bool :$method!) {
    # TODO Add proto? How?
    my $name = join ' ', $sig.multi ?? 'multi' !! (), $method ?? 'method' !! 'sub', $sig.name;
    my @params = $sig.signature.params;
    if $method {
        # Ignore invocant
        @params.shift;
        # Ignore default slurpy named parameter
        @params.pop
            if do given @params[*-1] { .slurpy and .name eq '%_'; };
    }
    my $code = $name;
    $code ~= @params.elems
        ?? "(\n{ @params.map({ .perl.indent(4) }).join(",\n") }\n)"
        !! "()";
    $code ~= ' returns ' ~ $sig.signature.returns.perl
        unless $sig.signature.returns.WHICH =:= Mu;
    $code = code2md($code, :lang<raku>);
    head2md($lvl+1, $name) ~ "\n\n" ~ $code;
}

=begin comment
This isn't useful as long as all tables are rendered as HTML. It
could still come in handy if, esthetically, we'd want simple
tables rendered as plain Markdown.

sub table2md(Pod::Block::Table $pod) {
    my @rows = $pod.contents;
    my @maxes;
    for @rows, $pod.headers.item -> @row {
      for 0..^@row -> $i {
          @maxes[$i] = max @maxes[$i], @row[$i].chars;
      }
    }
    my $fmt = Arr@maxes>>.sprintf('%%-%ds)
    @rows.map({
      my @cols = @_;
      my @ret;
      for 0..@_ -> $i {
          @ret.push: sprintf('%-'~$i~'s',

    if $pod.headers {
      @rows.unshift([$pod.headers.item>>.chars.map({'-' x $_})]);
      @rows.unshift($pod.headers.item);
    }
    @rows>>.join(' | ') ==> join("\n");
}
=end comment

# vim: ts=8
