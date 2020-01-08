package TagTriplet;

sub new{
  my ($class,$prev,$act,$next)=(shift,shift,shift,shift);
  my $self = bless {
    prev => $prev,
    act => $act,
    next => $next
  },$class;
  return $self;
}

sub has_prev{
  my ($self,$prev)=(shift,shift);
  return $self->{prev} eq $prev;
}

sub has_next{
  my ($self,$next)=(shift,shift);
  return $self->{next} eq $next;
}

sub has_act{
  my ($self,$act)=(shift,shift);
  return $self->{act} eq $act;
}

sub triplet_equal{
  my ($self,$other)=(shift,shift);
  return ($self->{prev} eq $other->{prev}) and ($self->{act} eq $other->{act}) and ($self->{next} eq $other->{next});
}

1;
