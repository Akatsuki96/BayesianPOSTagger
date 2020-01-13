#!/usr/bin/perl

use strict;
use warnings;
use lib '../utils/';
use Functions;
use NaiveBayes;
use Tester;


my $naive_bayes = new NaiveBayes();
my $tester = new Tester($naive_bayes);
# transform the file in a list of Sample (tuple word:pos)
my @samples = Functions::read_samples("./brown_corpus");
# execute the training
$naive_bayes->train(\@samples);
print("[--] Training phase completed!\n");
# tag a given sentence

my @tagged = $naive_bayes->tag("Time flies like an arrow .");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
@tagged = $naive_bayes->tag("They work at the office .");
print("\n");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
@tagged = $naive_bayes->tag("The work was done yesterday .");
print("\n");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
@tagged = $naive_bayes->tag("The xxx is blue .");
print("\n");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
@tagged = $naive_bayes->tag("The book was bought by Charles .");
print("\n");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
print("\n");
Functions::tag_file($naive_bayes,"test_set","out_test");
$tester->test('./test_set');
