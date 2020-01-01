#!/usr/bin/perl

use strict;
use warnings;
use Test::Simple 'no_plan';
use lib '../utils/';
use Sampler;

my $sample;
# Bernoulli Sampling
my $p = 0.5;
$sample=Sampler::bernoulli_sampling($p);
print("[--] Bernoulli($p) => Sample: $sample\n");

# Uniform Sampling
my ($low,$high)=(0.7,0.8);
$sample=Sampler::uniform_sampling($low,$high);
print("[--] Uniform($low,$high) => Sample: $sample\n");

# Uniform Integer Sampling
($low,$high)=(0,10);
$sample=Sampler::uniform_integer_sampling($low,$high);
print("[--] UniformInteger($low,$high) => Sample: $sample\n");

#Gaussian Sampling
my ($mean,$std)=(5,0.5);
$sample=Sampler::gaussian_sampling($mean,$std);
print("[--] Gaussian($mean,$std) => Sample: $sample\n");

#Gamma Sampling
my ($scale,$order)=(1,5);
$sample=Sampler::gamma_sampling($scale,$order);
print("[--] Gamma($scale,$order) => Sample: $sample\n");

#Beta Sampling
my ($alpha,$beta)=(3,5);
$sample=Sampler::beta_sampling($alpha,$beta);
print("[--] Beta($alpha,$beta) => Sample: $sample\n");
