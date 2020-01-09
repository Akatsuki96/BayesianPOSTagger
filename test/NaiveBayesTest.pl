#!/usr/bin/perl

use strict;
use warnings;
use Test::Simple 'no_plan';
use lib '../utils/';
use Functions;
use NaiveBayes;

sub train_ca{
  my $naive_bayes = shift;
  my @samples;
  for my $i (1..44){
    if ($i<10){
      @samples = Functions::read_samples("brown/ca0$i");
    }else{
      @samples = Functions::read_samples("brown/ca$i");
    }
    $naive_bayes->train(\@samples);
  }
}

sub train_cb{
  my $naive_bayes = shift;
  my @samples;
  for my $i (1..27){
    if ($i<10){
      @samples = Functions::read_samples("brown/cb0$i");
    }else{
      @samples = Functions::read_samples("brown/cb$i");
    }
    $naive_bayes->train(\@samples);
  }
}


my $naive_bayes = new NaiveBayes();

train_ca($naive_bayes);
train_cb($naive_bayes);

my @tagged = $naive_bayes->tag("They work today .");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
