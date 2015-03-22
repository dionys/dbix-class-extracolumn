#!/usr/bin/env perl

use 5.008001;
use strict;
use warnings;

use ExtUtils::MakeMaker 6.64;


WriteMakefile(
	NAME               => 'DBIx::Class::ExtraColumn',
	AUTHOR             => 'Denis Ibaev <dionys@cpan.org>',
	VERSION_FROM       => 'lib/DBIx/Class/ExtraColumn.pm',
	ABSTRACT_FROM      => 'lib/DBIx/Class/ExtraColumn.pm',
	LICENSE            => 'perl',
	MIN_PERL_VERSION   => '5.008001', # like DBIx::Class
	CONFIGURE_REQUIRES => {
		'ExtUtils::MakeMaker' => '6.64',
	},
	TEST_REQUIRES      => {
		'Test::More'          => 0,
	},
	PREREQ_PM          => {
		'parent'              => 0,
		'DBIx::Class'         => 0,
	},
	META_MERGE         => {
		resources => {
			license     => 'http://dev.perl.org/licenses/',
			repository  => 'http://github.com/dionys/dbix-class-extracolumn',
			bugtracker  => 'http://github.com/dionys/dbix-class-extracolumn/issues',
		},
		no_index  => {directory => ['t']},
	},
	dist               => {COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
	clean              => {FILES => 'DBIx-Class-ExtraColumn-*'},
	test               => {TESTS => 't/*.t'},
);
