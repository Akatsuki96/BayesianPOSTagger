package NaiveBayes;

use lib './';
use Functions;
use Sampler;

sub new{
  my $class = shift;
  my $self = bless {
    words =>{},
    classes => {},
    word_tag_prob => {},
    tag_prob =>{},
    num_classes => 0
  },$class;
  return $self;
}

sub update_model{
  my ($class,$model,$wtag,$tot) = (shift,shift,shift,shift);
  if($model){
    $class->{word_tag_prob}{$wtag}=$class->{words}{$wtag}/$tot;
  }else{
    $class->{tag_prob}{$wtag}=$class->{classes}{$wtag}/$tot;
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

sub get_tag_from_tagged{
  my ($class,$tagged)=(shift,shift);
  my @spl = split '/',$tagged;
  return $spl[1];
}

sub add_word{
  my ($class,$word)=(shift,shift);
  if($class->word_contained($word)){
    $class->{words}{$word}+=1;
  }else{
    $class->{words}{$word}=1;
  }
}

sub add_tag{
  my ($class,$pos)=(shift,shift);
  if($class->class_contained($pos)){
    $class->{classes}{$pos}+=1;
  }else{
    $class->{classes}{$pos}=1;
  }
}

sub train{
  my ($class,$samples) = (shift,shift);
  my @samples = @$samples;
  for my $sample (@samples){
    my ($word,$pos) = ($sample->get_word(),$sample->get_pos());
    $word = $word."/$pos";
    $class->add_word($word);
    $class->add_tag($pos);
    $class->{num_classes}+=1;
  }
  $class->update_model(1,$_,$class->{classes}{$class->get_tag_from_tagged($_)}) for (keys %{$class->{words}});
  $class->update_model(0,$_,$class->{num_classes}) for (keys %{$class->{classes}});
}

sub tag_file{
  my ($class,$to_tag,$output) = (shift,shift,shift);
  my ($f_hand,$f_out);
  open($f_hand,'<:encoding(UTF-8)',$to_tag) or die("[xx] Error: Couldn't open the file '$to_tag'!");
  open($f_out,'>:encoding(UTF-8)',$output) or $f_out=STDOUT;
  while($row = <$f_hand>){
    my @tagged_words = $class->tag($row);
    for my $tword (@tagged_words){
      print $f_out ($tword->get_word()."[".$tword->get_pos()."]"." ");
    }
    print $f_out ("\n");
  }
  close($f_hand);
  close($f_out) unless($f_out == STDOUT);
}

sub tag{
  my ($class,$row) = (shift,shift);
  my @tagged_words;
  my ($new_tag,$max_prob);
  chomp $row;
  for my $word (split ' ',$row){
    $max_prob = 0;
    $new_tag="nn";
    my %classes = %{$class->{classes}};
    for my $tag (keys %classes){
      my $tagged = $word."/".$tag;
      next unless($class->word_contained($tagged));
      my $prob_tagged = $class->{word_tag_prob}{$tagged}; #likelihood
      my $tag_prob = $class->{tag_prob}{$tag}; #prior
      my $post = $prob_tagged*$tag_prob;
      if($post > $max_prob){
        $new_tag = $tag;
        $max_prob = $post;
      }
    }
    push @tagged_words,new Sample($word,$new_tag);
  }
  return @tagged_words;
}

1;
