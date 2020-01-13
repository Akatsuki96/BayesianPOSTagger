#!/usr/bin/perl

use strict;
use warnings;
#use Test::Simple 'no_plan';
use lib '../utils/';
use Functions;
use MCMC;
use Tester;

my $mcmc = new MCMC(100,50);
my $tester= new Tester($mcmc);
my @test_sample = Functions::read_samples("./brown_corpus");
$mcmc->train(\@test_sample);
print("[--] Training phase completed!\n");
my @tagged = $mcmc->tag("Time flies like an arrow .",-1,1);
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
print("\n");
@tagged = $mcmc->tag("They work at the office .",5,1);
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
print("\n");
@tagged = $mcmc->tag("The work was done .");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
print("\n");
@tagged = $mcmc->tag("The xxx is blue .",5,1);
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
print("\n");
@tagged = $mcmc->tag("The book was bought by Charles .",5,1);
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
print("\n");
$tester->test('./test_set',10,1);
