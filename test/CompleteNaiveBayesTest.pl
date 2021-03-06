#!/usr/bin/perl

use strict;
use warnings;
use lib '../utils/';
use Functions;
use CompleteNaiveBayes;
use Tester;

my $naive_bayes = new CompleteNaiveBayes();
my $tester = new Tester($naive_bayes);
my @samples = Functions::read_samples("./brown_corpus");
$naive_bayes->train(\@samples);
print("[--] Training phase completed!\n");


my @tagged = $naive_bayes->tag("Time flies like an arrow .");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
@tagged = $naive_bayes->tag("They work at the office .");
print("\n");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
@tagged = $naive_bayes->tag("The work was done yesterday .");
print("\n");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
@tagged = $naive_bayes->tag("The xxx is blue while the yyy is green .");
print("\n");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
@tagged = $naive_bayes->tag("The xyz was bought by Charles .");
print("\n");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
print("\n");
Functions::tag_file($naive_bayes,"test_set","out_test_complete");
$tester->test('./test_set');
