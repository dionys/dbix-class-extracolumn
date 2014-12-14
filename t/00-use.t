#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;


BEGIN {
	use_ok 'DBIx::Class::ExtraColumn' or print("Bail out!\n");
}

diag "Testing DBIx::Class::ExtraColumn $DBIx::Class::ExtraColumn::VERSION, Perl $], $^X";
