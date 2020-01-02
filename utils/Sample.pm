package Sample;

use strict;
use warnings;

sub new{
  my ($class,$word,$pos) = (shift,shift,shift);
  my $self = bless {word => $word, pos => $pos},$class;
  return $self;
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
