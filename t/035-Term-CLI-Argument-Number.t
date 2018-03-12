#!/usr/bin/perl -T
#
# Copyright (C) 2018, Steven Bakker.
#
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.14.0. For more details, see the full text
# of the licenses in the directory LICENSES.
#

use 5.014_001;
use strict 1.08;
use Modern::Perl 1.20140107;

sub Main {
    Term_CLI_Argument_Filename_test->SKIP_CLASS(
        ($::ENV{SKIP_ARGUMENT})
            ? "disabled in environment"
            : 0
    );
    Term_CLI_Argument_Filename_test->runtests();
}

package Term_CLI_Argument_Filename_test {

use parent 0.228 qw( Test::Class );

use Test::More 1.001002;
use Test::Exception 0.35;
use FindBin 1.51;
use Term::CLI::ReadLine;
use Term::CLI::Argument::Number;
use Term::CLI::L10N;

my $ARG_NAME  = 'test_number';

# Untaint the PATH.
$::ENV{PATH} = '/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin';

sub startup : Test(startup => 1) {
    my $self = shift;

    Term::CLI::L10N->set_language('en');

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
