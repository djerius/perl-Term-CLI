#!/usr/bin/perl -T

use 5.014_001;
use strict;
use Modern::Perl;

sub Main {
    Term_CLI_Argument_Filename_test->SKIP_CLASS(
        ($::ENV{SKIP_ARGUMENT})
            ? "disabled in environment"
            : 0
    );
    Term_CLI_Argument_Filename_test->runtests();
}

package Term_CLI_Argument_Filename_test {

use parent qw( Test::Class );

use Test::More;
use Test::Exception;
use FindBin;
use Term::CLI::ReadLine;
use Term::CLI::Argument::Number;

my $ARG_NAME  = 'test_number';

# Untaint the PATH.
$::ENV{PATH} = '/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin';

sub startup : Test(startup => 1) {
    my $self = shift;
    my $arg = Term::CLI::Argument::Number->new(
        name => $ARG_NAME,
    );

    isa_ok( $arg, 'Term::CLI::Argument::Number',
            'Term::CLI::Argument::Number->new' );

    $self->{arg} = $arg;
}

sub check_constructor: Test(1) {
    my $self = shift;

    throws_ok
        { Term::CLI::Argument::Number->new() }
        qr/Missing required arguments: name/,
        'error on missing name';
}

sub check_attributes: Test(2) {
    my $self = shift;
    my $arg = $self->{arg};
    is( $arg->name, $ARG_NAME, "name attribute is $ARG_NAME" );
    is( $arg->type, 'Number', "type attribute is Number" );
}

sub check_validate: Test(7) {
    my $self = shift;
    my $arg = $self->{arg};


    ok( !$arg->validate(undef), "'undef' does not validate");
    is ( $arg->error, 'not a valid number',
        "error on 'undef' value is set correctly" );

    $arg->set_error('SOMETHING');

    ok( !$arg->validate(''), "'' does not validate");
    is ( $arg->error, 'not a valid number',
        "error on '' value is set correctly" );

    $arg->set_error('SOMETHING');

    ok( !$arg->validate(), "() does not validate");

    is ( $arg->error, 'not a valid number',
        "error on () value is set correctly" );

    $arg->set_error('SOMETHING');

    my $test_value = '1.2e3';
    throws_ok { $arg->validate($test_value) }
        qr/coerce_value.*? has not been overloaded/,
        'validate on Term::CLI::Number fails (coerce_value not overloaded)';
}

}

Main();
