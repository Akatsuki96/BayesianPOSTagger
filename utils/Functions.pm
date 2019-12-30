package Functions;
use Math::GammaFunctio;
use strict;
use warnings;

sub get_from_gamma_pdf{
  my ($alpha,$beta)=(shift,shift);
  my $rnd=rand();
  return exp(-$rnd/$beta)/(($beta**$alpha) * gamma($alpha)) * $rnd**($alpha-1);
}
