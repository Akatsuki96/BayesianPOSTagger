package MCMC;

use lib './';
use Functions;
use Sampler;

sub new{
  my ($class,$num_samples)=(shift,shift);
  my $self = bless {
    num_samples => $num_samples,
    tagged_words => {},
    prev_words => {}, # act -> prev
    next_words =>{}, # act -> next
    classes => {},
    wtag_prog =>{},
    prev_wtag_prob => {},
    next_wtag_prob => {},
    prob_first => {},
    prob_last => {},
    tag_prob =>{},
    num_classes => 0
  },$class;
  return $self;
}
sub class_contained{
  my ($class,$tag) = (shift,shift);
  return defined($class->{classes}{$tag});
}

sub add_word{
  my $class = shift;
  my $word = shift;
  if(defined($class->{words}{$word})){
    $class->{words}{$word}+=1;
  }else{
    $class->{words}{$word}=1;
  }
}

sub add_prev{
  my ($class,$act,$prev)=(shift,shift,shift);
  if(defined($class->{prev_words}{$act}{$prev})){
    $class->{prev_words}{$act}{$prev}+=1;
  }else{
    $class->{prev_words}{$act}{$prev}=1;
  }
}


sub add_next{
  my ($class,$act,$next)=(shift,shift,shift);
  if(defined($class->{next_words}{$act}{$next})){
    $class->{next_words}{$act}{$next}++;
  }else{
    $class->{next_words}{$act}{$next}=1;
  }
}

sub add_pos{
  my ($class,$pos)=(shift,shift);
  if($class->class_contained($pos)){
    $class->{classes}{$pos}+=1;
  }else{
    $class->{classes}{$pos}=1;
  }
}


sub get_tag_from_tagged{
  my ($class,$tagged)=(shift,shift);
  my @spl = split '/',$tagged;
  return $spl[1];
}

sub update_model{
  my ($class,$model,$wtag,$prevnext,$tot) = (shift,shift,shift,shift,shift);
  switch($model){
    case 1 {$class->{wtag_prob}{$wtag}=$class->{words}{$wtag}/$tot; }
    case 2 {$class->{prev_wtag_prob}{$wtag}{$prevnext}=$class->{prev_words}{$wtag}{$prevnext}; }
    case 3 {$class->{next_wtag_prob}{$wtag}{$prevnext}=$class->{next_words}{$wtag}{$prevnext}; }
    else { $class->{tag_prob}{$wtag}=$class->{classes}{$wtag}/$tot; }
  }
}

sub train{
  my ($class,$samples) = (shift,shift);
  my @samples = @$samples;
  for my $i_sample (0..scalar(@samples)-1){
    my ($prev_word,$tagged_word,$next_word);
    $tagged_word = $samples[$i_sample]->get_word()."/".$samples[$i_sample]->get_pos();
    $prev_word = $samples[$i_sample-1]->get_word()."/".$samples[$i_sample-1]->get_pos() unless($i_sample==0);
    $next_word = $samples[$i_sample+1]->get_word()."/".$samples[$i_sample+1]->get_pos() unless($i_sample== scalar(@samples)-1);

    $class->add_word($tagged_word);
    $class->add_prev($tagged_word,$prev_word) unless($i_sample==0);
    $class->add_next($tagged_word,$next_word) unless($i_sample==scalar(@samples)-1);
    $class->add_pos($samples[$i_sample]->get_pos());
    $class->{num_classes}+=1;
  }
  $class->update_model(1,$_,0,$class->{classes}{$class->get_tag_from_tagged($_)}) for (keys %{$class->{words}});
  for my $w (keys %{$class->{words}}){
    for my $p (keys %{$class->{prev_words}{$w}}){
      $class->update_model(2,$w,$p,$class->{words}{$w});
    }
    for my $n (keys %{$class->{next_words}{$w}}){
      $class->update_model(3,$w,$n,$class->{words}{$w});
    }
  }
}
