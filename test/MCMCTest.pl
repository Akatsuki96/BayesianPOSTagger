#!/usr/bin/perl

use strict;
use warnings;
#use Test::Simple 'no_plan';
use lib '../utils/';
use Functions;
use MCMC;

my $mcmc = new MCMC(100,50);
my @test_sample = Functions::read_samples("./brown_corpus");
$mcmc->train(\@test_sample);
print("[--] Training phase completed!\n");
my @tagged = $mcmc->tag("Time flies like an arrow .",5);

print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
print("\n");
