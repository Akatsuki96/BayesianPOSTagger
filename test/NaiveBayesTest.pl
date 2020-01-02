#!/usr/bin/perl

use strict;
use warnings;
use Test::Simple 'no_plan';
use lib '../utils/';
use Functions;
use NaiveBayes;

my @samples = Functions::read_samples('test_samples');
my $naive_bayes = new NaiveBayes();
$naive_bayes->train(\@samples);
ok($naive_bayes->get_num_classes() eq 25,"The number of classes is 25");
my @tagged;
$naive_bayes->tag_file('test_set','output');
$naive_bayes->tag_file('test_set'); # write to stdout
@tagged = $naive_bayes->tag("The dog broke the bottle");
ok($tagged[0]->get_word() eq "the" && $tagged[0]->get_pos() eq "ART","Word 'The' well-tagged");
ok($tagged[1]->get_word() eq "dog" && $tagged[1]->get_pos() eq "NOUN","Word 'dog' well-tagged");
ok($tagged[2]->get_word() eq "broke" && $tagged[2]->get_pos() eq "VERB","Word 'broke' well-tagged");
ok($tagged[3]->get_word() eq "the" && $tagged[3]->get_pos() eq "ART","Word 'the' well-tagged");
ok($tagged[4]->get_word() eq "bottle" && $tagged[4]->get_pos() eq "NOUN","Word 'bottle' well-tagged");
