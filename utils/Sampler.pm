package Sampler;
use lib './';
use Math::Random ('random_uniform','random_uniform_integer','random_normal','random_gamma','random_beta');

sub bernoulli_sampling{
  my $prob=shift;
  my $num = uniform_sampling(0,1);
  return $num < $prob?1:0;
}

sub uniform_sampling{
  my ($low,$high)=(shift,shift);
  return random_uniform(1,$low,$high);
}

sub uniform_integer_sampling{
  my ($low,$high)=(shift,shift);
  return random_uniform_integer(1,$low,$high);
}

sub gaussian_sampling{
  my ($mu,$sigma)=(shift,shift);
  return random_normal(1,$mu,$sigma);
}

sub gamma_sampling{
  my ($scale,$order)=(shift,shift);
  return random_gamma(1,$scale,$order);
}

sub beta_sampling{
  my ($alpha,$beta)=(shift,shift);
  return random_beta(1,$alpha,$beta);
}

1;
