#===============================================================================
#
#       Module:  Term::CLI::Argument::Number::Float
#
#  Description:  Class for floating point arguments in Term::CLI
#
#       Author:  Steven Bakker (SBAKKER), <sbakker@cpan.org>
#      Created:  22/01/18
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
#===============================================================================

use 5.014_001;

package Term::CLI::Argument::Number::Float {

use Modern::Perl;
use POSIX qw( );
use Moo;
use namespace::clean;

extends 'Term::CLI::Argument::Number';

sub coerce_value {
    return POSIX::strtod($_[1]);
}

}

1;

__END__

=pod

=head1 NAME

Term::CLI::Argument::Number::Float - class for floating point arguments in Term::CLI

=head1 SYNOPSIS

 use Term::CLI::Argument::Number::Float;

 my $arg = Term::CLI::Argument::Number::Int->new(
                name => 'index',
                min => -1.0,
                max => +1.0,
                inclusive => 1
           );

=head1 DESCRIPTION

Class for floating point arguments in L<Term::CLI>(3p). Extends
L<Term::CLI::Argument::Number>(3p).

=head2 Inherits from:

L<Term::CLI::Argument::Number>(3p).

=head2 Consumes:

None.

=head1 CONSTRUCTORS

See L<Term::CLI::Argument::Number>(3p).

=head1 ACCESSORS

See L<Term::CLI::Argument::Number>(3p).

=head1 METHODS

Inherited from
L<Term::CLI::Argument::Number>(3p).

Additionally:

=over

=item B<coerce_value> ( I<VALUE> )

Overloaded to call L<POSIX::strtod|POSIX/strtod>.

=back

=head1 SEE ALSO

L<POSIX>(3p),
L<Term::CLI::Argument::Number::Int>(3p),
L<Term::CLI::Argument::Number>(3p),
L<Term::CLI::Argument>(3p),
L<Term::CLI>(3p).

=head1 AUTHOR

Steven Bakker E<lt>sbakker@cpan.orgE<gt>, 2018.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2018 Steven Bakker

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. See "perldoc perlartistic."

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
