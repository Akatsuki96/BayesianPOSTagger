#!/usr/bin/perl

use strict;
use warnings;
#use Test::Simple 'no_plan';
use lib '../utils/';
use Functions;
use MAP;

sub train_ca{
  my $naive_bayes = shift;
  my @samples;
  my $name;
  for my $i (1..44){
    if ($i<10){
      $name = "brown/ca0$i";
    }else{
      $name = "brown/ca$i";
    }
    @samples = Functions::read_samples($name);
    $naive_bayes->train(\@samples);
    print("[!!] Training on '$name' completed!\n");
  }
}

sub train_cb{
  my $naive_bayes = shift;
  my @samples;
  my $name;
  for my $i (1..27){
    if ($i<10){
      $name = "brown/cb0$i";
    }else{
      $name = "brown/cb$i";
    }
    @samples = Functions::read_samples($name);
    $naive_bayes->train(\@samples);
    print("[!!] Training on '$name' completed!\n");

  }
}


sub train_cc{
  my $naive_bayes = shift;
  my @samples;
  my $name;
  for my $i (1..17){
    if ($i<10){
      $name = "brown/cc0$i";
    }else{
      $name = "brown/cc$i";
    }
    @samples = Functions::read_samples($name);
    $naive_bayes->train(\@samples);
    print("[!!] Training on '$name' completed!\n");
  }
}

my $map = new MAP();
my @test_sample = Functions::read_samples("./brown/ca22");
$map->train(\@test_sample);
#train_ca($map);
#train_cb($map);
#train_cc($map);

my @tagged = $map->tag("Time flies like an arrow");
print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
#@tagged = $naive_bayes->tag("They work at the office .");
#print("\n");
#print($_->get_word()."[".$_->get_pos()."] ") for (@tagged);
#print("\n");
#Functions::tag_file($naive_bayes,"test_set","out_test");
