package TextStats;
use strict;
use warnings;

sub new{
  my $class = shift;
  return (bless {
      prob_sp => {},
      prob_fst_sp => {},
      prob_wrd_spch => {},
      prob_n_spch => {}
      },$class);
}


1;
