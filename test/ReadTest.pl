#!/usr/bin/perl

use strict;
use warnings;
use Test::Simple 'no_plan';
use lib '../utils/';
use Functions;

my @samples = Functions::read_samples("./test_samples");
ok($samples[0]->get_word() eq "This","First word in samples is 'This'");
ok($samples[1]->get_pos() eq "VERB","Second pos in samples is 'VERB'");
