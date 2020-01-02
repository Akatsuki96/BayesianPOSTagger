package NaiveBayes;

use lib './';
use Functions;
use Sampler;

sub new{
  my $class = shift;
  my $self = bless {
    class_prob =>{}, # {class : probability}
    words =>{},
    classes => {},
    num_classes => 0
  },$class;
  return $self;
}

sub word_contained{
  my ($class,$word) = (shift,shift);
  return defined($class->{words}{$word});
}

sub class_contained{
  my ($class,$tag) = (shift,shift);
  return defined($class->{classes}{$tag});
}

sub get_num_classes{
  my $class = shift;
  return $class->{num_classes};
}

sub train{
  my ($class,$samples) = (shift,shift);
  my @samples = @$samples;
  for my $sample (@samples){
    my ($word,$pos) = ($sample->get_word(),$sample->get_pos());
    $word = $word."[$pos]";
    if($class->word_contained($word)){
      $class->{words}{$word}+=1;
    }else{
      $class->{words}{$word}=1;
    }
    if($class->class_contained($pos)){
      $class->{classes}{$pos}+=1;
    }else{
      $class->{classes}{$pos}=1;
    }
    $class->{num_classes}+=1;
  }
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
  my @best_tags;
  my $max_prob;
  my %posteriors;
  chomp $row;
  $row=~s/[[:punct:]]//g;
  my @words=split ' ',$row;
  for my $word (@words){
    $word = lc $word;
    $max_prob = 0;
    push @best_tags,"NOUN";
    my %classes = %{$class->{classes}};
    for my $tag (keys %classes){
      my $cls_prior = $classes{$tag}/$class->get_num_classes();
      my $tagged = $word."[".$tag."]";
      if($class->word_contained($tagged)){
        my $likelihood = $class->{words}{$tagged}/$classes{$tag};
        my $post = $cls_prior*$likelihood;
        if($max_prob < $post){
          $max_prob = $post;
          @best_tags = ();
          push @best_tags,$tag;
        }elsif($max_prob == $post){
          push @best_tags,$tag;
        }
        $posteriors{$tagged} = $post unless(defined($posteriors{$tagged}));
      }elsif(not defined($posteriors{$tagged})){
        $posteriors{$tagged} = 0;
      }
    }
    my $tag = $best_tags[Sampler::uniform_integer_sampling(0,scalar(@best_tags)-1)];
    push @tagged_words,new Sample($word,$tag);
    @best_tags=();
    undef @best_tags;
  }
  return @tagged_words;
}

1;
