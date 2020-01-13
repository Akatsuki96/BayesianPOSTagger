package NaiveBayes;

use lib './';
use Functions;
use Sampler;

sub new{
  my $class = shift;
  my $self = bless {
    words =>{}, # {(word_tag : occurency)}
    classes => {}, # {(tag : occurency)}
    word_tag_prob => {}, # {(word_tag : P(word | tag))}
    tag_prob =>{}, # {(tag : P(tag))}
    num_classes => 0 # total number of tag
  },$class;
  return $self;
}

sub add_to{
  my ($class,$set,$word) = (shift,shift,shift);
  if(defined($class->{$set}{$word})){
    $class->{$set}{$word}+=1;
  }else{
    $class->{$set}{$word}=1;
  }
}

sub compute_probability{
  my ($class,$model,$wtag,$tot) = (shift,shift,shift,shift);
  if($model){
    $class->{word_tag_prob}{$wtag}=$class->{words}{$wtag}/$tot;
  }else{
    $class->{tag_prob}{$wtag}=$class->{classes}{$wtag}/$tot;
  }
}

sub train{
  my ($class,$samples) = (shift,shift);
  my @samples = @$samples;
  for my $sample (@samples){
    my ($word,$pos) = ($sample->get_word(),$sample->get_pos());
    $class->add_to("words",$word."_".$pos);
    $class->add_to("classes",$pos);
    $class->{num_classes}+=1;
  }
  $class->compute_probability(1,$_,$class->{classes}{(split '_',$_)[1]}) for (keys %{$class->{words}});
  $class->compute_probability(0,$_,$class->{num_classes}) for (keys %{$class->{classes}});
}


sub tag{
  my ($class,$row) = (shift,shift);
  my @tagged_words; # [(word,tag)]
  chomp $row;
  # for each word in the sentence
  for my $word (split ' ',$row){
    my ($max_prob,$new_tag) = (0,"NN");
    # get known tags
    my %classes = %{$class->{classes}};
    #for each known tag
    for my $tag (keys %classes){
      my $tagged = $word."_".$tag;
      # if the word_tag has 0 occurency, skip this tag
      next unless(defined($class->{words}{$tagged}));
      #compute likelihood
      my $prob_tagged = $class->{word_tag_prob}{$tagged};
      #compute prior
      my $tag_prob = $class->{tag_prob}{$tag};
      #compute posterior
      my $post = $prob_tagged*$tag_prob;
      if($post > $max_prob){
        $new_tag = $tag;
        $max_prob = $post;
      }
    }
    # assign to the word its most probable tag
    push @tagged_words,new Sample($word,$new_tag);
  }
  return @tagged_words;
}

1;
