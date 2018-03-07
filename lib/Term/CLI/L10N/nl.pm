#===============================================================================
#
#       Module:  Term::CLI::L10N::nl
#       Author:  Steven Bakker (SBAKKER), <sbakker@cpan.org>
#      Created:  27/02/18
#
#   Copyright (c) 2018 AMS-IX B.V.; All rights reserved.
#
#   This module is free software; you can redistribute it and/or modify
#   it under the same terms as Perl itself. See "perldoc perlartistic."
#
#   This software is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#===============================================================================

package Term::CLI::L10N::nl;

our $VERSION = 0.01;

use Modern::Perl;

use parent qw( Term::CLI::L10N );

use Locale::Maketext::Lexicon::Gettext;

our %Lexicon = %{ Locale::Maketext::Lexicon::Gettext->parse(<DATA>) };
close DATA;

# $str = $lh->singularize($num, $plural);
# $str = $lh->singularise($num, $plural);
*singularise = \&singularize;
sub singularize {
    my $self = shift;

    local($_) = shift;

    # -zen, -ven -> -s, -f
    s/zen$/s/ and return $_;
    s/ven$/f/ and return $_;

    # -eu?en, -ei?en
    s/(eu|ei)([^aeiou])en$/$1$2/ and return $_;
    
    # gelegenheden -> gelegenheid
    s/heden$/heid/ and return $_;

    # musea -> museum
    # aquaria -> aquarium
    s/([ei])a$/$1um/  and return $_;

    # leraren -> leraar
    s/([aeiou])([^aeiou])en$/$1$1$2/ and return $_;
    
    # ballen -> bal
    s/([^aeiou])\1en$/$1/ and return $_;

    # schermen -> scherm
    # auto's   -> auto
    # lepels   -> lepel
    return s/(?:'?en|'s|s)$//r;
}


# $str = $lh->numerate($num, $plural [, $singular ]);
#
# NOTE: this reverses the semantics of the
# plural/singular forms, because it's easier
# to go from plural to singular in Dutch.
#
sub numerate {
    my ($handle, $num, @forms) = @_;

    my $is_plural = ($num != 1);

    return '' unless @forms;
    if (@forms == 1) { # only plural specified
        my $word = $forms[0];
        if ($is_plural) {
            return $word;
        }
        return $handle->singularize($word);
    }
    else { # Both plural and singular are supplied
        return $is_plural ? $forms[0] : $forms[1];
    }
}

1;

__DATA__
#:
msgid ""
msgstr ""

"Project-ID-Version: Term::CLI 0.01\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=utf-8\n"
"Content-Transfer-Encoding: 8bit\n"

##############################################################################
### lib/Term/CLI/Argument/Bool.pm ############################################

#: lib/Term/CLI/Argument/Bool.pm:94
msgid "invalid boolean value"
msgstr "ongeldige booleaanse waarde"

#: lib/Term/CLI/Argument/Bool.pm:83
msgid "ambiguous boolean value (matches [%1] and [%2])"
msgstr "geen eenduidige booleaanse waarde (komt overeen met zowel [%1] als [%2])"

##############################################################################
### lib/Term/CLI/Argument/Enum.pm ############################################

#: lib/Term/CLI/Argument/Enum.pm:50
msgid "not a valid value"
msgstr "geen geldige waarde"

#:
msgid "ambiguous value (matches: %1)"
msgstr "geen eenduidige waarde (mogelijke waarden: %1)"

##############################################################################
### lib/Term/CLI/Argument/Number.pm ##########################################

#: lib/Term/CLI/Argument/Number.pm
msgid "not a valid number"
msgstr "geen geldig getal"

#: lib/Term/CLI/Argument/Number.pm
msgid "too small"
msgstr "getal te klein"

#: lib/Term/CLI/Argument/Number.pm
msgid "too large"
msgstr "getal te groot"

##############################################################################
### lib/Term/CLI/Argument.pm #################################################

#: lib/Term/CLI/Argument.pm
msgid "value cannot be empty"
msgstr "waarde mag niet leeg zijn"

##############################################################################
### lib/Term/CLI/Argument/String.pm ##########################################

#: lib/Term/CLI/Argument/String.pm
msgid "value must be defined"
msgstr "waarde moet gedefinieerd zijn"

#: lib/Term/CLI/Argument/String.pm
msgid "too short (min. length %1)"
msgstr "te kort (min. lengte %1)"

#: lib/Term/CLI/Argument/String.pm
msgid "too long (max. length %1)"
msgstr "te lang (max. lengte %1)"

#############################################################################

#: lib/Term/CLI/Command/Help.pm
msgid ""
"Show help for any given command sequence.\n"
"The C<--pod> option (or C<-p>) will cause raw POD\n"
"to be shown."
msgstr ""
"Toon hulp voor willekeurige commando's.\n"
"De C<--pod> optie (of C<-p>) geeft POD broncode\n"
"als uitvoer."

#: lib/Term/CLI/Command/Help.pm
msgid "show help"
msgstr "toon hulp"

#: lib/Term/CLI/Command/Help.pm
msgid "Commands"
msgstr "Commando's"

#: lib/Term/CLI/Command/Help.pm
msgid "Usage"
msgstr "Gebruiksoverzicht"

#: lib/Term/CLI/Command/Help.pm
msgid "Description"
msgstr "Beschrijving"

#: lib/Term/CLI/Command/Help.pm
msgid "Sub-Commands"
msgstr "Sub-Commando's"

#: lib/Term/CLI/Command/Help.pm
msgid "cannot run '%1': %2"
msgstr "kan programma '%1' niet starten: %2"

#############################################################################

#: lib/Term/CLI/Role/CommandSet.pm
msgid "unknown command '%1'"
msgstr "onbekend commando '%1'"

#:
msgid "ambiguous command '%1' (matches: %2)"
msgstr "geen eenduidig commando '%1' (mogelijk: %2)"

#:
msgid "I counted %quant(%1,thing)"
msgstr "Ik heb %quant(%1,dingen) geteld"

#:
msgid "I counted %quant(%1,car)"
msgstr "Ik heb %quant(%1,auto's) geteld"

##############################################################################
### lib/Term/CLI/Command.pm ##################################################

#: lib/Term/CLI/Command.pm
msgid "for"
msgstr "voor"

#: lib/Term/CLI/Command.pm
msgid "missing '%1' argument"
msgstr "'%1' argument is niet ingevoerd"

#: lib/Term/CLI/Command.pm
msgid "need %1 '%2' %numerate(%1,argument)"
msgstr "er zijn %1 '%2' %numerate(%1,argumenten) nodig"

#: lib/Term/CLI/Command.pm
msgid "need %1 or %2 '%3' arguments"
msgstr "er zijn %1 of %2 '%3' argumenten nodig"

#: lib/Term/CLI/Command.pm
msgid "need between %1 and %2 '%3' arguments"
msgstr "er zijn %1 t/m %2 '%3' argumenten nodig"

#: lib/Term/CLI/Command.pm
msgid "need at least %1 '%2' %numerate(%1,argument)"
msgstr "er %numerate(%1,zijn,is) tenminste %1 '%2' %numerate(%1,argumenten) nodig"

#: lib/Term/CLI/Command.pm
msgid "no arguments allowed"
msgstr "argumenten zijn niet toegestaan"

#: lib/Term/CLI/Command.pm
msgid "too many '%1' arguments (max. %2)"
msgstr "teveel '%1' argumenten (max. %2)"

#: lib/Term/CLI/Command.pm
msgid "incomplete command: missing '%1'"
msgstr "commando niet compleet: verwachte '%1' niet gezien"

#: lib/Term/CLI/Command.pm
msgid "missing sub-command"
msgstr "commando niet compleet (sub-commando verwacht)"

#: lib/Term/CLI/Command.pm
msgid "expected '%1' instead of '%2'"
msgstr "'%1' verwacht in plaats van '%2'"

#: lib/Term/CLI/Command.pm
msgid "unknown sub-command '%1'"
msgstr "onbekend sub-commando '%1'"

#############################################################################
### TO DO

#: lib/Term/CLI.pm:146
msgid "ERROR"
msgstr "FOUT"

#: lib/Term/CLI.pm:372
msgid "missing command"
msgstr ""

#: lib/Term/CLI/Role/CommandSet.pm:138
msgid "unknown command '$partial'"
msgstr ""

#: lib/Term/CLI/Role/CommandSet.pm:142
msgid "ambiguous command '%1' (matches: %2)"
msgstr ""