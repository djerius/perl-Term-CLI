#!/usr/bin/perl -T
#
# Copyright (C) 2018, Steven Bakker.
#
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl 5.14.0. For more details, see the full text
# of the licenses in the directory LICENSES.
#

use strict;

use Test::More;
use Test::Compile;

my @pms = all_pm_files;
my @pls = all_pl_files;

plan tests => int(@pms) + int(@pls);

pm_file_ok($_) for @pms;
pl_file_ok($_) for @pls;
