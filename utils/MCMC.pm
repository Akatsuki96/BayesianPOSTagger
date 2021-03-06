package MCMC;

use lib './';
use Functions;
use Switch;
use Sampler;

use constant SMALL_PROB => 4.22e-14;

sub new{
  my ($class,$num_samples,$burn_in)=(shift,(shift or 100),(shift or 5));
  my $self = bless {
    num_samples => $num_samples,
    burn_in => $burn_in,
    tagged_words => {},
    prev_words => {}, # act -> prev
    next_words =>{}, # act -> next
    classes => {},
    class_transition => {}, # class w1 -> class w2
    first_class => {},
    wtag_prob =>{},
    prev_wtag_prob => {},
    next_wtag_prob => {},
    first_class_prob => {}, #prob first class
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


sub add_to{
  my $class = shift;
  my $set = shift;
  my $word = shift;
  if(defined($class->{$set}{$word})){
    $class->{$set}{$word}+=1;
    #print("Added: ".$class->{$set}{$word}."\n");
  }else{
    $class->{$set}{$word}=1;
  }
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
  my @spl = split '_',$tagged;
  return $spl[1];
}

sub compute_probability{
  my ($class,$model,$wtag,$prevnext,$tot) = (shift,shift,shift,shift,shift);
  switch($model){
    case 1 {$class->{wtag_prob}{$wtag}=$class->{words}{$wtag}/$tot;}
    case 2 {$class->{prev_wtag_prob}{$wtag}{$prevnext}=$class->{prev_words}{$wtag}{$prevnext}; }
    case 3 {$class->{next_wtag_prob}{$wtag}{$prevnext}=$class->{next_words}{$wtag}{$prevnext}; }
    case 4 {$class->{first_class_prob}{$wtag}=$class->{first_class}{$wtag}/$tot;}
    case 5 {
      $class->{class_trans_prob}{$wtag}=$class->{class_transition}{$wtag}/$tot;
    #  print("Trans updated: ".$class->{class_trans_prob}{$wtag}."\n");
    }
    else { $class->{tag_prob}{$wtag}=$class->{classes}{$wtag}/$tot; }
  }
}

sub word_contained{
  my ($class,$word) = (shift,shift);
  return defined($class->{words}{$word});
}

sub class_contained{
  my ($class,$tag) = (shift,shift);
  return defined($class->{classes}{$tag});
}

sub train{
  my ($class,$samples) = (shift,shift);
  my @samples = @$samples;
  for my $i_sample (0..scalar(@samples)-1){
    my ($prev_word,$tagged_word,$next_word);
    $tagged_word = $samples[$i_sample]->get_word()."_".$samples[$i_sample]->get_pos();
    $class->add_to("first_class",$samples[$i_sample]->get_pos()) if($samples[$i_sample]->is_first());
    $class->add_to("words",$tagged_word);
    $class->add_pos($samples[$i_sample]->get_pos());
    $class->add_to("class_transition",$samples[$i_sample]->get_pos()."_".$samples[$i_sample-1]->get_pos()) if($i_sample > 0);#if($i_sample < scalar(@samples)-1);
    $class->{num_classes}+=1;

  }
  my $f_count = Functions::sum(values %{$class->{first_class}});
  $class->compute_probability(1,$_,0,$class->{classes}{$class->get_tag_from_tagged($_)}) for (keys %{$class->{words}});
  $class->compute_probability(4,$_,0,$f_count) for (keys %{$class->{first_class}});
  for my $cl (keys %{$class->{class_transition}}){
    my @spl = split '_',$cl;
    $class->compute_probability(5,$cl,0,$class->{classes}{$spl[1]});
  }
  $class->compute_probability(0,$_,0,$class->{num_classes}) for (keys %{$class->{classes}});

}

sub generate_first_sampling{
  print("[--] Generating first sample...\n");
  my ($class,$row,$init) = (shift,shift,shift);
  my @tagged_words;
  my ($new_tag,$max_prob);
  chomp $row;
  if(defined($init)){
    for my $word (split ' ',$row){
      $max_prob = 0;
      $new_tag="NN";
      my %classes = %{$class->{classes}};
      for my $tag (keys %classes){
        my $tagged = $word."_".$tag;
        next unless($class->word_contained($tagged));
        my $prob_tagged = $class->{wtag_prob}{$tagged}; #likelihood
        my $tag_prob = $class->{tag_prob}{$tag}; #prior
        my $post = $prob_tagged*$tag_prob;
      #  print("LIKELIHOOD: $prob_tagged PRIOR: $tag_prob POST: $post\n");
        if($post > $max_prob){
          $new_tag = $tag;
          $max_prob = $post;
        }
      }
      push @tagged_words,new Sample($word,$new_tag);
    }
  }else{
    push @tagged_words,new Sample($_,"NN") for (split ' ',$row);
  }
  return @tagged_words;
}

sub tag{
  my ($class,$sentence,$to_sample,$naiveinit)=(shift,shift,(shift or 1),shift);
  print("[--] Sentence: $sentence\n");
  my @tag_samples=$class->generate_first_sampling($sentence,$naiveinit);
  print("[--] Initial Sample: ");
  print ($_->get_word()."[".$_->get_pos()."] ") for (@tag_samples);
  print("\n");
  my @prev_sample = ();#map {$_} @tag_samples;
  push @prev_sample,$_ for (@tag_samples);
  my @last_sample = ();
  my @words = split ' ',$sentence;
  my @tagged_words=();
  my @classes = keys %{$class->{classes}};
  my %samples={};
  my %smap={};
  my %map_sample;
  for my $i (0..$class->{num_samples}){
    #print("[??] Generating sample number $i...\n");
    @last_sample = ();
    push @last_sample,$_ for (@prev_sample);
    for my $j (0..scalar(@words)-1){
      my @tags= ();
      my @weights = ();
      my $sum_weights = 0;
      for $tag (@classes){
        my $wtag_p = defined($class->{wtag_prob}{$words[$j]."_".$tag})?$class->{wtag_prob}{$words[$j]."_".$tag}:SMALL_PROB;
        my $prior;
        if($j==0){
          $prior = $class->{first_class_prob}{$tag}*((scalar(@words)>1)?$class->{class_trans_prob}{$last_sample[$j+1]->get_pos()."_".$tag}:1);
        }elsif($j==scalar(@words)-1){
          $prior = defined($class->{class_trans_prob}{$tag."_".$last_sample[$j-1]->get_pos()})?$class->{class_trans_prob}{$tag."_".$last_sample[$j-1]->get_pos()}:0;
        }else{
          $prior = (defined($class->{class_trans_prob}{$tag."_".$last_sample[$j-1]->get_pos()})?$class->{class_trans_prob}{$tag."_".$last_sample[$j-1]->get_pos()}:0)*
                   (defined($class->{class_trans_prob}{$last_sample[$j+1]->get_pos()."_".$tag})?$class->{class_trans_prob}{$last_sample[$j+1]->get_pos()."_".$tag}:0);
        }
        my $post = $prior * $wtag_p;
        $sum_weights+=$post;
        push @tags,$tag;
        push @weights,$post;
      }
      if($sum_weights > 0){ # normalization
        $weights[$_]/=$sum_weights for(0..scalar(@weights)-1);
      }
      my $c_sum =0;
      my $r = rand();
      for my $index (0..scalar(@weights)-1){
        $c_sum +=$weights[$index];
        $weights[$index] = $c_sum;
      }
      my $r_index = -1;
      for my $index (1..scalar(@weights)-1){
        $r_index=$index if($weights[$index] >= $r and $r >= $weights[$index-1]);
      }
      $r_index = 0 unless($r_index!=-1);
      $last_sample[$j] = new Sample($last_sample[$j]->get_word(),$tags[$r_index]);
    }
    @prev_sample=();
    push @prev_sample,$_ for (@last_sample);
    $samples{$i} = [];
    push @{$samples{$i}},$_ for(@prev_sample);
    for $sample_index (0..scalar(@prev_sample)-1){
      if(defined($map_sample{$sample_index}{$prev_sample[$sample_index]->get_pos()})){
        $map_sample{$sample_index}{$prev_sample[$sample_index]->get_pos()}+=1;
      }else{
        $map_sample{$sample_index}{$prev_sample[$sample_index]->get_pos()}=1;
      }
    }
  }
  shift @samples for (0..$class->{burn_in});
  if ($to_sample > 1){
    for my $i (0..$to_sample){
      my $rnd = int(rand(scalar(keys %samples)-1));
      my @smp = @{$samples{$rnd}};
      my $pos_key='';
      print("[++] Sample $rnd: ");
      print($_->get_word()."[".$_->get_pos()."] ") for (@{$samples{$rnd}});
      $pos_key.=$_->get_pos()."_" for (@{$samples{$rnd}});
      if(defined($smap{$pos_key})){
        $smap{$pos_key}+=1;
      }else{
        $smap{$pos_key}=1;
      }
      print("\n");
    }
    my $max = 0;
    my $max_key='';
    for my $key (keys %smap){
      if($smap{$key} > $max){
        $max_key = $key;
        $max=$smap{$key};
      }
    }
    my @best_tags = split '_',$max_key;
    push @tagged_words, new Sample($words[$_],$best_tags[$_]) for (0..scalar(@words)-1);
    @samples = ();
    return @tagged_words;
  }elsif($to_sample < 0){
    for my $im_smp (0..scalar(keys %map_sample)-1){ #0..n
      my $highest=0;
      my $mp_tag = '';
      for $tag (keys %{$map_sample{$im_smp}}){ #tag in position $im_smp
        print("[--] Pos: $im_smp Tag: $tag Count: ".$map_sample{$im_smp}{$tag}."\n");
        if($highest < $map_sample{$im_smp}{$tag}){
          $highest = $map_sample{$im_smp}{$tag};
          $mp_tag = $tag;
        }
      }
      push @tagged_words,new Sample($words[$im_smp],$mp_tag);
    }
  }else{
    @tagged_words=@{$samples{int(rand(scalar(keys %samples)-1))}};
  }

  return @tagged_words;
}

1;
