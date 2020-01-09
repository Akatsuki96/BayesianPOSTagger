#!/usr/bin/perl

use strict;
use warnings;
use Test::Simple 'no_plan';
use lib '../utils/';
use Functions;
use CompleteNaiveBayes;

my @samples = Functions::read_samples('test_samples');
my @samples2 = Functions::read_samples('test_samples2');
my @samples3 = Functions::read_samples('brown/ca03');
my @samples4 = Functions::read_samples('brown/ca04');
my @samples5 = Functions::read_samples('brown/ca05');
my @samples6 = Functions::read_samples('brown/ca06');
my @samples7 = Functions::read_samples('brown/ca07');
my @samples8 = Functions::read_samples('brown/ca08');
my @samples9 = Functions::read_samples('brown/ca09');
my @samples10 = Functions::read_samples('brown/ca10');
my @samples11 = Functions::read_samples('brown/ca11');
my @samples12 = Functions::read_samples('brown/ca12');
my @samples13 = Functions::read_samples('brown/ca13');
my @samples14 = Functions::read_samples('brown/ca14');


my $cnaivebayes= new CompleteNaiveBayes();
$cnaivebayes->train(\@samples);
$cnaivebayes->train(\@samples2);
$cnaivebayes->train(\@samples3);
$cnaivebayes->train(\@samples4);
$cnaivebayes->train(\@samples5);
$cnaivebayes->train(\@samples6);
$cnaivebayes->train(\@samples7);
$cnaivebayes->train(\@samples8);
$cnaivebayes->train(\@samples9);
$cnaivebayes->train(\@samples10);
$cnaivebayes->train(\@samples11);
$cnaivebayes->train(\@samples12);
$cnaivebayes->train(\@samples13);
$cnaivebayes->train(\@samples14);



#my @tagged = $cnaivebayes->tag("The dog broke the bottle .");
#print($_->get_word()."[".$_->get_pos()."] ") for(@tagged);
my @tagged = $cnaivebayes->tag("Time flies like an arrow");
print($_->get_word()."[".$_->get_pos()."] ") for(@tagged);

print("\n");
