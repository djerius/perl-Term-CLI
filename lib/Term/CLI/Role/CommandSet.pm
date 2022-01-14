#=============================================================================
#
#       Module:  Term::CLI::CommandSet
#
#  Description:  Class for sets of (sub-)commands in Term::CLI
#
#       Author:  Steven Bakker (SBAKKER), <sbakker@cpan.org>
#      Created:  05/02/18
#
#   Copyright (c) 2018 Steven Bakker
#
#   This module is free software; you can redistribute it and/or modify
#   it under the same terms as Perl itself. See "perldoc perlartistic."
#
#   This software is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#=============================================================================

package Term::CLI::Role::CommandSet 0.054002;

use 5.014;
use warnings;

use Term::CLI::L10N qw( loc );

use Types::Standard 1.000005 qw(
    ArrayRef
    Bool
    CodeRef
    InstanceOf
    ConsumerOf
    Maybe
);

use Moo::Role;
use namespace::clean 0.25;

my $ERROR_STATUS  = -1;

has parent => (
    is       => 'rwp',
    weak_ref => 1,
    isa      => ConsumerOf ['Term::CLI::Role::CommandSet'],
);

has _commands => (
    is       => 'rw',
    writer   => '_set_commands',
    init_arg => 'commands',
    isa      => Maybe [ ArrayRef [ InstanceOf ['Term::CLI::Command'] ] ],
    trigger  => 1,
    coerce   => sub {

        # Copy the array, so the reference we store becomes
        # "internal", preventing accidental modification
        # from the outside.
        return [ @{ $_[0] } ];
    },
);

has callback => (
    is        => 'rw',
    isa       => Maybe [CodeRef],
    predicate => 1
);

has missing_cmd_ok => (
    is      => 'ro',
    isa     => Bool,
    default => 0
);

# $self->_set_commands($ref) => $self->_trigger__commands($ref);
#
# Trigger to run whenever the object's _commands array ref is set.
#
sub _trigger__commands {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my ( $self, $arg ) = @_;

    # No need to check for defined-ness of $arg.
    # The writer method already checks & croaks.
    for my $cmd (@$arg) {
        $cmd->_set_parent($self);
    }
    return;
}

sub commands {
    my $self = shift;
    my @l    = sort { $a->name cmp $b->name } @{ $self->_commands // [] };
    return @l;
}

sub has_commands {
    my $self = shift;
    return ( $self->_commands and scalar @{ $self->_commands } > 0 );
}

sub add_command {
    my ( $self, @commands ) = @_;

    if ( !$self->_commands ) {
        $self->_set_commands( [] );
    }

    for my $cmd (@commands) {
        push @{ $self->_commands }, $cmd;
        $cmd->_set_parent($self);
    }
    return $self;
}

sub command_names {
    my $self = shift;
    return map { $_->name } $self->commands;
}

sub find_matches {
    my ( $self, $partial ) = @_;
    return () if !$self->has_commands;
    my @found = grep { rindex( $_->name, $partial, 0 ) == 0 } $self->commands;
    return @found;
}

sub root_node {
    my $self = my $curr_node = shift;

    while ( my $parent = $curr_node->parent ) {
        $curr_node = $parent;
    }
    return $curr_node // $self;
}

sub find_command {
    my ( $self, $partial ) = @_;
    my @matches = $self->find_matches($partial);

    if ( @matches == 1 ) {
        return $matches[0];
    }
    if ( @matches == 0 ) {
        return $self->set_error( loc( "unknown command '[_1]'", $partial ) );
    }
    return $self->set_error(
        loc("ambiguous command '[_1]' (matches: [_2])",
            $partial,
            join( ', ', sort map { $_->name } @matches )
        )
    );
}

sub try_callback {
    my ( $self, %args ) = @_;

    if ( $self->has_callback && defined $self->callback ) {
        return $self->callback->( $self, %args );
    }
    return %args;
}

# CLI->_set_completion_attribs();
#
# Set some attributes in the Term::ReadLine object related to
# custom completion.
#
sub _set_completion_attribs {
    my $self = shift;
    my $root = $self->root_node;
    my $term = $root->term;


    # set Completion for current object
    $term->Attribs->{completion_function} = sub { $self->_complete_line( @_ ) };

    # Default: '"
    $term->Attribs->{completer_quote_characters} = $root->quote_characters;

    # Default: \n\t\\"'`@$><=;|&{( and <space>
    $term->Attribs->{completer_word_break_characters} = $root->word_delimiters;

    # Default: <space>
    $term->Attribs->{completion_append_character} =
        substr( $root->word_delimiters, 0, 1 );

    return;
}

# See POD X<complete_line>
sub _complete_line {
    my ( $self, $text, $line, $start ) = @_;

    my $root = $self->root_node;

    $self->_set_completion_attribs;

    my $quote_char = $root->_rl_completion_quote_character;

    my @words;

    if ( $start > 0 ) {
        if ( length $quote_char ) {

            # ReadLine thinks the $text to be completed is quoted.
            # The quote character will precede the $start of $text.
            # Make sure we do not include it in the text to break
            # into words...
            ( my $err, @words ) =
                $root->_split_line( substr( $line, 0, $start - 1 ) );
        }
        else {
            ( my $err, @words ) =
                $root->_split_line( substr( $line, 0, $start ) );
        }
    }

    push @words, $text;

    my @list;

    if ( @words == 1 ) {
        @list = grep { rindex( $_, $words[0], 0 ) == 0 } $self->command_names;
    }
    elsif ( my $cmd = $self->find_command( $words[0] ) ) {
        @list = $cmd->complete_line( @words[ 1 .. $#words ] );
    }

    return @list if length $quote_char; # No need to worry about spaces.

    # Escape spaces in reply if necessary.
    my $delim = $root->word_delimiters;
    return map {s/([$delim])/\\$1/rgx} @list;
}

sub readline {    ## no critic (ProhibitBuiltinHomonyms)
    my ( $self, %args ) = @_;

    my $root = $self->root_node;

    my $prompt = $args{prompt} // $self->prompt;
    my $skip   = exists $args{skip} ? $args{skip} : $root->skip;

    $self->_set_completion_attribs;

    my $input;
    while ( defined( $input = $root->term->readline($prompt) ) ) {
        next if defined $skip && $input =~ $skip;
        last;
    }
    return $input;
}

sub _execute {
    my ( $self, $cmd ) = @_;

    my $root = $self->root_node;
    my ( $error, @cmd ) = $root->_split_line($cmd);

    my %args = (
        status       => 0,
        error        => q{},
        command_line => $cmd,
        command_path => [$self],
        unparsed     => \@cmd,
        options      => {},
        arguments    => [],
    );

    return $self->try_callback( %args, status => $ERROR_STATUS,
        error => $error )
        if length $error;

    if ( @cmd == 0 ) {
        $args{error}  = loc("missing command");
        $args{status} = $ERROR_STATUS;
    }
    elsif ( my $cmd_ref = $self->find_command( $cmd[0] ) ) {
        %args = $cmd_ref->execute( %args, unparsed => [ @cmd[ 1 .. $#cmd ] ] );
    }
    else {
        $args{error}  = $self->error;
        $args{status} = $ERROR_STATUS;
    }

    return $self->try_callback(%args);
}


1;

__END__

=pod

=head1 NAME

Term::CLI::Role::CommandSet - Role for (sub-)commands in Term::CLI

=head1 SYNOPSIS

 package Term::CLI::Command {

    use Moo;

    with('Term::CLI::Role::CommandSet');

    ...
 };

 my $cmd = Term::CLI::Command->new( ... );

 $cmd->callback->( %args ) if $cmd->has_callback;

 if ( $cmd->has_commands ) {
    my $cmd_ref = $cmd->find_command( $cmd_name );
    die $cmd->error unless $cmd_ref;
 }

 say "command names:", join(', ', $cmd->command_names);

 $cmd->callback->( $cmd, %args ) if $cmd->has_callback;

 %args = $cmd->try_callback( %args );

=head1 DESCRIPTION

Role for L<Term::CLI>(3p) elements that contain
a set of L<Term::CLI::Command>(3p) objects.

This role is used by L<Term::CLI>(3p) and L<Term::CLI::Command>(3p).

=head1 ATTRIBUTES

This role defines two additional attributes:

=over

=item B<commands> =E<gt> I<ArrayRef>

Reference to an array containing C<Term::CLI::Command> object
instances that describe the sub-commands that the command takes,
or C<undef>.

Note that the elements of the array are copied over to an internal
array, so modifications to the I<ArrayRef> will not be seen.

=item B<callback> =E<gt> I<CodeRef>

Reference to a subroutine that should be called when the command
is executed, or C<undef>.

=back

=head1 ACCESSORS AND PREDICATES

=over

=item B<has_callback>
X<has_callback>

=item B<has_commands>
X<has_commands>

Predicate functions that return whether or not any (sub-)commands
have been added to this object.

=item B<callback> ( [ I<CODEREF> ] )
X<callback>

I<CODEREF> to be called when the command is executed. The callback
is called as:

   OBJ->callback->(OBJ,
        status       => Int,
        error        => Str,
        options      => HashRef,
        arguments    => ArrayRef[Value],
        command_line => Str,
        command_path => ArrayRef[InstanceOf['Term::CLI::Command']],
   );

Where:

=over

=item I<CLI_REF>

Reference to the current C<Term::CLI> object.

=item C<status>

Indicates the status of parsing/execution so far.
It has the following meanings:

=over

=item I<E<lt> 0>

Negative status values indicate a parse error. This is a sign that no
action should be taken, but some error handling should be performed.
The actual parse error can be found under the C<error> key. A typical
thing to do in this case is for one of the callbacks in the chain (e.g.
the one on the C<Term::CLI> object) to print the error to F<STDERR>.

=item I<0>

The command line parses as valid and execution so far has been successful.

=item I<E<gt> 0>

Some error occurred in the execution of the action. Callback functions need
to set this by themselves.

=back

=item C<error>

In case of a negative C<status>, this will contain the parse error. In
all other cases, it may or may not contain useful information.

=item C<options>

Reference to a hash containing all command line options.
Compatible with the options hash as set by L<Getopt::Long>(3p).

=item C<arguments>

Reference to an array containing all the arguments to the command.
Each value is a scalar value, possibly converted by
its corresponding L<Term::CLI::Argument>'s
L<validate|Term::CLI::Argument/validate> method (e.g. C<3e-1> may have
been converted to C<0.3>).

=item C<unparsed>

Reference to an array containing all the words on the command line that
have not been parsed as arguments or sub-commands yet. In case of parse
errors, this often contains elements, and otherwise should be empty.

=item C<command_line>

The complete command line as given to the
L<Term::CLI::execute|Term::CLI/execute> method.

=item C<command_path>

Reference to an array containing the "parse tree", i.e. a list
of object references:

    [
        InstanceOf['Term::CLI'],
        InstanceOf['Term::CLI::Command'],
        ...
    ]

The first item in the C<command_path> list is always the top-level
L<Term::CLI> object, while the last is always the same as the
I<OBJ_REF> parameter.

=back

The callback is expected to return a hash (list) containing at least the
same keys. The C<command_path>, C<arguments>, and C<options> should
be considered read-only.

Note that a callback can be called even in the case of errors, so you
should always check the C<status> before doing anything.

=item B<commands>
X<commands>

Return the list of subordinate C<Term::CLI::Command> objects
(i.e. "sub-commands") sorted on C<name>.

=item B<parent>
X<parent>

Return a reference to the object that "owns" this object.
This is typically another object class that consumes this
C<Term::CLI::Role::CommandSet> role, such as
C<Term::CLI>(3p) or C<Term::CLI::Command>(3p), or C<undef>.

=back

=head1 METHODS

=over

=item B<add_command> ( I<CMD_REF>, ... )
X<add_command>

Add the given I<CMD_REF> command(s) to the list of (sub-)commands, setting
each I<CMD_REF>'s L<parent|/parent> in the process.

=item B<command_names>
X<command_names>

Return the list of (sub-)command names, sorted alphabetically.

=item B<find_matches> ( I<Str> )
X<find_matches>

Return a list of all commands in this object that match the I<Str>
prefix.

=item B<find_command> ( I<Str> )
X<find_command>

Check whether I<Str> uniquely matches a command in this C<Term::CLI>
object. Returns a reference to the appropriate
L<Term::CLI::Command> object if successful; otherwise, it
sets the objects C<error> field and returns C<undef>.

Example:

    my $sub_cmd = $cmd->find_command($prefix);
    die $cmd->error unless $sub_cmd;

=item B<root_node>
X<root_node>

Walks L<parent|/parent> chain until it can go no further. Returns a
reference to the object at the top. In a functional setup, this
is expected to be a L<Term::CLI>(3p) object.

=item B<try_callback> ( I<ARGS> )
X<try_callback>

Wrapper function that will call the object's C<callback> function if it
has been set, otherwise simply returns its arguments.

=back

=head1 SEE ALSO

L<Term::CLI>(3p),
L<Term::CLI::Command>(3p).

=head1 AUTHOR

Steven Bakker E<lt>sbakker@cpan.orgE<gt>, 2018.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2018 Steven Bakker

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. See "perldoc perlartistic."

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=begin __PODCOVERAGE

=head1 THIS SECTION SHOULD BE HIDDEN

This section is meant for methods that should not be considered
for coverage. This typically includes things like BUILD and DEMOLISH from
Moo/Moose. It is possible to skip these when using the Pod::Coverage class
(using C<also_private>), but this is not an option when running C<cover>
from the command line.

The simplest trick is to add a hidden section with an item list containing
these methods.

=over

=item BUILD

=item DEMOLISH

=back

=end __PODCOVERAGE

=cut
