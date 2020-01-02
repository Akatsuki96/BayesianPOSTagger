package Sentence;

use strict;
use warnings;

sub new{
  my ($class,$str)=(shift,shift);
  my $self = bless {
    full_sentence => $str
  },$class;
  my @words=split (" ",$str);
  $self->{words}=\@words;
  $self->{actual_word}=0;
  return $self;
}

sub get_next_word{
  my $class = shift;
  return 0 unless($class->{actual_word} < scalar(@{$class->{words}}));
  $class->{actual_word}++;
  return $class->{words}[$class->{actual_word}-1];
}

sub get_number_of_words{
  my $class = shift;
  return scalar(@{$class->{words}});
}

sub get_sentece{
  my $class=shift;
  return $class->{full_sentence};
}

sub reset{
  my $class=shift;
  $class->{actual_word}=0;
}

1;
