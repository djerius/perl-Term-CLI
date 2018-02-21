#!/usr/bin/perl

use Modern::Perl;
use FindBin;
use lib ("$FindBin::Bin/../lib");

use Term::CLI;

$SIG{INT} = 'IGNORE';

my $term = Term::CLI->new(
	name     => 'bssh',             # A basically simple shell.
	skip     => qr/^\s*(?:#.*)?$/,  # Skip comments and empty lines.
	prompt   => 'bssh> ',           # A more descriptive prompt.
);

my @commands;

push @commands, Term::CLI::Command->new(
	name => 'exit',
    summary => 'Exit B<bssh>',
    description => "Exit B<bssh> with code I<excode>,\n"
                  ."or C<0> if no exit code is given.",
	callback => sub {
        my ($cmd, %args) = @_;
        return %args if $args{status} < 0;
        execute_exit($cmd->name, @{$args{arguments}});
        return %args;
    },
	arguments => [
		Term::CLI::Argument::Number::Int->new(  # Integer
            name => 'excode',
			min => 0,             # non-negative
			inclusive => 1,       # "0" is allowed
			min_occur => 0,       # occurrence is optional
			max_occur => 1,       # no more than once
		),
	],
);

sub execute_exit {
    my ($cmd, $excode) = @_;
    $excode //= 0;
    say "-- $cmd: $excode";
    exit $excode;
}

push @commands, Term::CLI::Command::Help->new();

push @commands, Term::CLI::Command->new(
    name => 'echo',
    summary => 'Print arguments to F<stdout>.',
    description => "The C<echo> command prints its arguments\n"
                .  "to F<stdout>, separated by spaces, and\n"
                .  "terminated by a newline.\n",
    arguments => [
        Term::CLI::Argument::String->new( name => 'arg', occur => 0 ),
    ],
    callback => sub {
        my ($cmd, %args) = @_;
        return %args if $args{status} < 0;
        say "@{$args{arguments}}";
        return %args;
    }
);

$term->add_command(@commands);

say "\n[Welcome to BSSH]";
while ( defined(my $line = $term->readline) ) {
    $term->execute($line);
}
print "\n";
execute_exit('exit', 0);
