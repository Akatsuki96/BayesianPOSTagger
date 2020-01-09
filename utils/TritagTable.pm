package TritagTable;

sub new{
  my ($class,$labels_ptr) = (shift,shift);
  my $self = bless {
    labels=>@$labels_ptr,
    tab => {} # cell{l_actual}{l_prev}{l_next}
  }, $class;
  $self->init();
  return $self;
}

sub init{
  my $class = shift;
  my @labels = $class->{labels};
  for my $i (0..scalar(@labels)){
    for my $j (0..scalar(@labels)){
      for my $k (0..scalar(@labels)){
        $class->{tab}{i}{j}{k}=0;
      }
    }
  }
}


1;
