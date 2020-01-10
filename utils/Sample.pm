package Sample;

use strict;
use warnings;

sub new{
  my ($class,$word,$pos,$firstlast) = (shift,shift,shift,shift);
  #print("FLAST: $firstlast\n");
  my $self = bless {word => $word, pos => $pos, firstlast => $firstlast},$class;
  return $self;
}

sub is_first{
  my $class = shift;
  return (($class->{firstlast} == 1));
}

sub is_last{
  my $class = shift;
  return (($class->{firstlast} == -1));
}

sub get_word{
  my $class = shift;
  return $class->{word};
}

sub get_pos{
  my $class = shift;
  return $class->{pos};
}

sub is_word_equals{
  my ($class,$str) = (shift,shift);
  return $class->{word} eq $str;
}

1;
