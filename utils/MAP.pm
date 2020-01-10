package MAP;

use strict;
use warnings;
use lib './';
use Switch;
use Functions;
use Sampler;

use constant SMALL_PROB => 4.22316915059e-10;

sub new{
  my $class = shift;
  my $self = bless {
    words => {},
    tagged_words => {},
    prev_words => {}, # act -> prev
    next_words =>{}, # act -> next
    classes => {},
    first_class =>{},
    last_class =>{},
    class_transition =>{},
    wtag_prog =>{},
    prev_wtag_prob => {},
    next_wtag_prob => {},
    first_class_prob =>{},
    last_class_prob =>{},
    class_trans_prob =>{},
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

sub add_first{
  my $class = shift;
  my $word = shift;
#  print("[!!] First: $word\n");
  if(defined($class->{first_class}{$word})){
    $class->{first_class}{$word}+=1;
  }else{
    $class->{first_class}{$word}=1;
  }
}

sub add_last{
  my $class = shift;
  my $word = shift;
  if(defined($class->{last_class}{$word})){
    $class->{last_class}{$word}+=1;
  }else{
    $class->{last_class}{$word}=1;
  }
}

sub add_class_trans{
  my $class = shift;
  my $word = shift;
  if(defined($class->{class_transition}{$word})){
    $class->{class_transition}{$word}+=1;
  }else{
    $class->{class_transition}{$word}=1;
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
    case 4 {$class->{first_class_prob}{$wtag}=$class->{first_class}{$wtag}/$tot;}
    case 5 {$class->{last_class_prob}{$wtag}=$class->{last_class}{$wtag}/$tot;}
    case 6 {$class->{class_trans_prob}{$wtag}=$class->{class_transition}{$wtag}/$tot;}
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
  #  if($samples[$i_sample]->is_last()){
  #    print("ISLAST");
  #    $class->add_last($samples[$i_sample]->get_pos()) ;
  #  }
    $class->add_first($samples[$i_sample]->get_pos()) if($samples[$i_sample]->is_first());
    $class->add_word($tagged_word);
    $class->add_prev($tagged_word,$prev_word) unless($i_sample==0);
    $class->add_next($tagged_word,$next_word) unless($i_sample==scalar(@samples)-1);
    $class->add_pos($samples[$i_sample]->get_pos());
    $class->add_class_trans($samples[$i_sample]->get_pos()."/".$samples[$i_sample+1]->get_pos()) if($i_sample > 0 and $i_sample < scalar(@samples)-1);
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
  my $f_count = Functions::sum(values %{$class->{first_class}});
  #my $l_count = Functions::sum(values %{$class->{last_class}});
  #print("FCOUNT: $f_count LCOUNT: $l_count\n");
  $class->update_model(4,$_,0,$f_count) for (keys %{$class->{first_class}});
  #$class->update_model(5,$_,0,$l_count) for (keys %{$class->{last_class}});
  for my $cl (keys %{$class->{class_transition}}){
    my @spl = split '/',$cl;
    $class->update_model(6,$cl,0,$class->{classes}{$spl[1]});
  }

}

sub get_num_classes{
  my $class = shift;
  return $class->{num_classes};
}
sub word_contained{
  my ($class,$word) = (shift,shift);
  return defined($class->{words}{$word});
}

sub tag{
  my ($class,$row) = (shift,shift);
  my @tagged_words;
  my %path;
  my @classes = keys %{$class->{classes}};
  my @prev_pos;
  chomp $row;
  my @words = split ' ',$row;
  my $temp_id = -1;
  my ($emission,$trans_prob) =(0,0);
  my $last_max = 0;
  my $last_tag;
  for my $word (0..scalar(@words)-1){
    my $act_word = $words[$word];
    my $max_val =0;
    $last_max = 0;
    $prev_pos[$word]=0;
    if($word == 0){
      # Base Case
      for my $tag (@classes){
        # If I've already seen word/tag in training phase
        if($class->word_contained("$act_word/$tag")){
          $path{$tag}{$word}=[(defined($class->{first_class_prob}{$tag})?$class->{first_class_prob}{$tag}:0)*$class->{wtag_prob}{"$act_word/$tag"},-1];
          print("Contained: ".((defined($class->{first_class_prob}{$tag})?$class->{first_class_prob}{$tag}:0)*$class->{wtag_prob}{"$act_word/$tag"})."\n");

        #  $prev_pos[$word]=1;
        }else{
          # If I never saw  word/tag in traning phase
        #  print("TAG: $tag\n");
          $path{$tag}{$word}=[SMALL_PROB*(defined($class->{first_class_prob}{$tag})?$class->{first_class_prob}{$tag}:0),-1];

        }
        $prev_pos[$word]=1;
        #Update max state
        if($word == scalar(@words)-1 and $last_max < $path{$tag}{$word}[0]){
          $last_max = $path{$tag}{scalar(@words)-1}[0];
          $last_tag = $tag;
        }
      }
      #print("[--] New => Word: $act_word Prob: $last_max Tag: $last_tag TMP: $temp_id\n");
      #return;
    }else{
      # Transition Case
    #  $temp_id = -1;
      for my $tag (@classes){
        $max_val = 0;
        # If $act_word is a known word, we know the emission probability otherwise we can use SMALL_PROB
        $emission =($class->word_contained("$act_word/$tag")?$class->{wtag_prob}{"$act_word/$tag"}:SMALL_PROB);
        #print("Word: $act_word TAG: $tag Emission $emission\n");
        $prev_pos[$word]=1;
        for my $otag (@classes){
          #If I already saw a transition $tag->$otag in traning otherwise 0
          $trans_prob = (defined($class->{class_transition}{"$tag/$otag"})?$class->{class_transition}{"$tag/$otag"}:0);
          my $new_coeff = ($path{$otag}{$word-1}[0]) * $trans_prob;
          if($max_val < $new_coeff){
            $temp_id = $otag;
            $max_val = $new_coeff;
          }
        }
        # new state reached with probability
      #  print("Adding $tag at $word with prev $temp_id for $act_word\n");
        $path{$tag}{$word} = [$max_val * $emission, $temp_id];
      #  print("Last max: $last_max Act: ".$path{$tag}{$word}[0]."\n");
        if($word == (scalar(@words)-1) and $last_max < $path{$tag}{$word}[0]){
          $last_max = $path{$tag}{scalar(@words)-1}[0];
          $last_tag = $tag;
        #  print("[--] New MAX => Word: $act_word Prob: $last_max Tag: $last_tag TMP: $temp_id\n");
        }
      }
    }
  }
  my @traversal;
  @words = reverse @words;
  for my $i (0..scalar(@words)-1){
    push @tagged_words,new Sample($words[$i],$last_tag);
    $last_tag = $path{$last_tag}{scalar(@words)-$i-1}[1];
  }
  return (reverse @tagged_words);
}

1;
