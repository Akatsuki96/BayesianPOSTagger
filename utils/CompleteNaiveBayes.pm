package CompleteNaiveBayes;

use strict;
use warnings;
use lib './';
use Functions;
use Sampler;
use TagTriplet;

sub new{
  my $class = shift;
  my $self = bless {
    words => {},
    tagged_words => {},
    prev_words => {}, # act -> prev
    next_words =>{}, # act -> next
    classes => {},
    prev_class =>{},
    next_class => {},
    num_classes => 0
  },$class;
  return $self;
}

sub class_contained{
  my ($class,$tag) = (shift,shift);
  return defined($class->{classes}{$tag});
}

sub triplet_defined{
  my ($class,$triplet)=(shift,shift);
  for (keys %{$class->{triplets}}){
    return 1 if($_->triplet_equal($triplet));
  }
  return 0;
}

sub get_most_probable_by{
  my ($class,$prev,$act,$next) = (shift,shift,shift);
  my ($trip,$max)=(0,0);
  for (keys %{$class->{triplets}}){
    if((not defined($prev) or $_->TagTriplet::has_prev($prev)) and (not defined($act) or $_->TagTriplet::has_act($act)) and (not defined($act) or $_->TagTriplet::has_next($next)) and $class->{triplets}{$_} > $max){
      $trip = $_;
      $max = $class->{triplets}{$_};
    }
  }
  return $trip;
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

sub add_tagged_word{
  my $class = shift;
  my $word = shift;
  if(defined($class->{tagged_words}{$word})){
    $class->{tagged_words}{$word}+=1;
  }else{
    $class->{tagged_words}{$word}=1;
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

sub add_prev_pos{
  my ($class,$pos,$prev_pos)=(shift,shift,shift);
  if(defined($class->{prev_class}{$pos}{$prev_pos})){
    $class->{prev_class}{$pos}{$prev_pos}+=1;
  }else{
    $class->{prev_class}{$pos}{$prev_pos}=1;
  }
}


sub add_next_pos{
  my ($class,$pos,$next_pos)=(shift,shift,shift);
  if(defined($class->{next_class}{$pos}{$next_pos})){
    $class->{next_class}{$pos}{$next_pos}+=1;
  }else{
    $class->{next_class}{$pos}{$next_pos}=1;
  }
}

sub train{
  my ($class,$samples,$ttable) = (shift,shift,shift);
  my @samples = @$samples;
  for my $i_sample (0..scalar(@samples)-1){
    next if($i_sample == 0 || $i_sample == scalar(@samples)-1);

    my ($prev_word,$prev_pos)=($samples[$i_sample-1]->get_word(),$samples[$i_sample-1]->get_pos());
    my ($word,$pos) = ($samples[$i_sample]->get_word(),$samples[$i_sample]->get_pos());
    my ($next_word,$next_pos)=($samples[$i_sample+1]->get_word(),$samples[$i_sample+1]->get_pos());
    my $tagged_word;

    $tagged_word = $word."[$pos]";
    $prev_word = $prev_word."[$prev_pos]";
    $next_word = $next_word."[$next_pos]";

    print("[!!] Adding:-> Word: $tagged_word Prev: $prev_word Next: $next_word\n");

    $class->add_word($word);
    $class->add_tagged_word($tagged_word);
    $class->add_prev($tagged_word,$prev_word);
    $class->add_next($tagged_word,$next_word);
    $class->add_pos($pos);
    $class->add_prev_pos($pos,$prev_pos);
    $class->add_next_pos($pos,$next_pos);
    $class->{num_classes}+=1;
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

sub get_word_tag_occurency{
  my ($class,$wtag)=(shift,shift);
  return defined($class->{tagged_words}{$wtag})?$class->{tagged_words}{$wtag}:0;
}

sub get_prev_intersect{
  my ($class,$wtag_act,$wtag_prev)=(shift,shift,shift);
  return defined($class->{prev_words}{$wtag_act}{$wtag_prev})?$class->{prev_words}{$wtag_act}{$wtag_prev}:0;
}

sub get_next_intersect{
  my ($class,$wtag_act,$wtag_prev)=(shift,shift,shift);
  return defined($class->{next_words}{$wtag_act}{$wtag_prev})?$class->{next_words}{$wtag_act}{$wtag_prev}:0;
}


sub is_known{
  my ($class, $word)=(shift,shift);
  return defined($class->{words}{$word});
}

sub get_log{
  my $val=shift;
  return (defined($val) and $val != 0)?log($val)/log(2):-9;
}

sub tag{
  my ($class,$row,$punc) = (shift,shift,shift);
  my @tagged_words;
  my ($word,$prev,$next);
  my @best_tags;
  my $max_prob=-999999;
  my %posteriors;
  chomp $row;
  #$row=~s/[[:punct:]]//g if(defined($punc));
  my @words=split  " ",$row;
  my ($prior,$likelihood,$post)=(0,0,0);

  my @tags = keys %{$class->{classes}};
  for my $i (0..scalar(@words)-1){
    push @best_tags,"unk";
    $word = $words[$i];
    $prev = defined($words[$i-1])?$words[$i-1]:0;
    $next = defined($words[$i+1])?$words[$i+1]:0;

    for my $tag (@tags){
      $likelihood =0;
      #my $tag_prob = log($class->{classes}{$tag}/$class->get_num_classes());
      my $tagged_word = $word."[$tag]";
      if($class->is_known($word)){
        my $occurrency_word_tag = $class->get_word_tag_occurency($word."[$tag]");
        next if($occurrency_word_tag==0);
        if($class->is_known($word)){
          $prior = get_log($occurrency_word_tag/$class->{words}{$word});
        }else{

        }
        print("[--] I: $i Word: $word Tag: $tag Prior: $prior\n");
        for my $other_tag (@tags){
          my $tagged_next = $next."[$other_tag]";
          my $tagged_prev = $prev."[$other_tag]";
          if(defined($prev) and not defined($next)){
            $likelihood += get_log($class->get_prev_intersect($tagged_word,$tagged_prev)/$occurrency_word_tag);
          }elsif(defined($next) and not defined($prev)){
            $likelihood +=
              get_log($class->get_prev_intersect($tagged_word,$tagged_next)/$occurrency_word_tag);
          }else{
            $likelihood +=
              get_log($class->get_prev_intersect($tagged_word,$tagged_prev)/$occurrency_word_tag)+
              get_log($class->get_next_intersect($tagged_word,$tagged_next)/$occurrency_word_tag);
          }
        }
      }else{
        $prior = get_log($class->{classes}{$tag}/$class->get_num_classes());
      }
      #DEBUG
      $post = $prior+$likelihood;
      print("[--] Log Likelihood: $likelihood Posterior: $post\n");
      if($max_prob < $post){ #posterior update
        $max_prob = $post;
        @best_tags = ();
        push @best_tags, $tag;
      }elsif($max_prob == $post){
        push @best_tags,$tag;
      }
    }
    my $mag = $best_tags[Sampler::uniform_integer_sampling(0,scalar(@best_tags)-1)];
    push @tagged_words,new Sample($word,$mag);
    print("[--] Best tag: $mag\n");
    @best_tags=();
    $max_prob=-999999;
    undef @best_tags;
  }
  return @tagged_words;
}

1;
