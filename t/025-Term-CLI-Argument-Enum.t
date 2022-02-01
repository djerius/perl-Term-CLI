#!/usr/bin/perl -T
#
# Copyright (c) 2018-2022, Steven Bakker.
#
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.14.0. For more details, see the full text
# of the licenses in the directory LICENSES.
#

use 5.014_001;
use warnings;

sub Main {
    Term_CLI_Argument_Enum_test->SKIP_CLASS(
        ($::ENV{SKIP_ARGUMENT})
            ? "disabled in environment"
            : 0
    );
    Term_CLI_Argument_Enum_test->runtests();
    return;
}

package Term_CLI_Argument_Enum_test {

use parent 0.225 qw( Test::Class );

use Test::More 1.001002;
use Test::Exception 0.35;
use FindBin 1.50;
use Term::CLI::Argument::Enum;
use Term::CLI::L10N;

my $ARG_NAME= 'test_enum';
my @ONE_WORDS = qw( one oneself onetime );
my @T_WORDS = qw( two three );
my @ENUM_VALUES = (@ONE_WORDS, @T_WORDS);

# Untaint the PATH.
$::ENV{PATH} = '/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin';

sub startup : Test(startup => 1) {
    my $self = shift;

    Term::CLI::L10N->set_language('en');

    my $arg = Term::CLI::Argument::Enum->new(
        name => $ARG_NAME,
        value_list => [@ENUM_VALUES]
    );

    isa_ok( $arg, 'Term::CLI::Argument::Enum', 'Term::CLI::Argument::Enum->new' );
    $self->{arg} = $arg;
    return;
}

sub check_constructor: Test(1) {
    my $self = shift;

    throws_ok
        { Term::CLI::Argument::Enum->new( name => $ARG_NAME) }
        qr/Missing required arguments: value_list/,
        'error on missing value_list';
    return;
}

sub check_attributes: Test(2) {
    my $self = shift;
    my $arg = $self->{arg};
    is( $arg->name, $ARG_NAME, "name attribute is $ARG_NAME" );
    is( $arg->type, 'Enum', "type attribute is Enum" );
    return;
}

sub check_complete: Test(4) {
    my $self = shift;
    my $arg = $self->{arg};

    my @expected = sort @ENUM_VALUES;
    is_deeply( [$arg->complete('')], \@expected,
        "complete returns (@ENUM_VALUES) for ''");

    @expected = sort @T_WORDS;
    is_deeply( [$arg->complete('t')], \@expected,
        "complete returns (@expected) for 't'");

    @expected = sort @ONE_WORDS;
    is_deeply( [$arg->complete('one')], \@expected,
        "complete returns (@expected) for 'one'");

    @expected = ();
    is_deeply( [$arg->complete('X')], \@expected,
        "complete returns (@expected) for 'X'");
    return;
}

sub check_validate: Test(10) {
    my $self = shift;
    my $arg = $self->{arg};

    ok( !$arg->validate(undef), "'undef' does not validate");

    is ( $arg->error, 'value cannot be empty',
        "error on 'undef' value is set correctly" );

    $arg->set_error('SOMETHING');

    ok( !$arg->validate(''), "'' does not validate");
    is ( $arg->error, 'value cannot be empty',
        "error on '' value is set correctly" );

    $arg->set_error('SOMETHING');

    ok( !$arg->validate('thing'), "'thing' does not validate");
    is ( $arg->error, 'not a valid value',
        "error on '' value is set correctly" );

    ok( !$arg->validate('t'), "'t' is ambiguous");
    like ( $arg->error, qr/^ambiguous value \(matches: .*\)$/,
        "error on ambiguous value is set correctly" );

    $arg->set_error('SOMETHING');

    my $test_value = $ONE_WORDS[1];
    ok( $arg->validate($test_value), "'$test_value' validates");

    is ( $arg->error, '',
        "error is cleared on successful validation" );
    return;
}

}

Main();
