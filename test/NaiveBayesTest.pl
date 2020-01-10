#!/usr/bin/perl

use strict;
use warnings;
#use Test::Simple 'no_plan';
use lib '../utils/';
use Functions;
use NaiveBayes;

my $naive_bayes = new NaiveBayes();
my @samples = Functions::read_samples("./brown_corpus");
$naive_bayes->train(\@samples);
print("[--] Training phase completed!\n");



my @tagged = $naive_bayes->tag("Time flies like an arrow .");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
@tagged = $naive_bayes->tag("They work at the office .");
print("\n");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
print("\n");
Functions::tag_file($naive_bayes,"test_set","out_test");
