package Sampler;
use lib './';
use Statistics::Distribution::Generator ('uniform','gaussian');
use Math::CDF ('pgamma','pbeta');

sub bernoulli_sampling{
  my $prob=shift;
  my $num = uniform(0,1);
  return $num < $prob?1:0;
}

sub uniform_sampling{
  my ($low,$high)=(shift,shift);
  return uniform($low,$high);
}

sub gaussian_sampling{
  my ($mu,$sigma)=(shift,shift);
  return gaussian($mu,$sigma);
}

sub gamma_sampling{
  my ($scale,$order)=(shift,shift);
  my $num=rand();
  return pgamma($num,$scale,1/$order);
}

sub beta_sampling{
  my ($alpha,$beta)=(shift,shift);
  my $num=rand();
  return pbeta($num,$alpha,$beta);
}

1;
