package MCMC;

use lib './';
use Functions;
use Sampler;

sub new{
  my ($class,$num_samples)=(shift,shift);
  my $self = bless {
    num_samples => $num_samples
  },$class;
  return $self;
}
