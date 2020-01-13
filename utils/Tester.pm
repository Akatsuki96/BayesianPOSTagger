package Tester;

sub new{
  my ($class,$tagger) = (shift,shift);
  my @tagger_argv = @_;
  my $self =bless {
    tagger => $tagger,
    tagger_args => @tagger_argv
  },$class;
  return $self;
}

sub get_sentence_tags{
  my ($class,$tsentence) = (shift,shift);
  my $sentence = '';
  my @words = split ' ',$tsentence;
  my @tags;
  for(@words){
    my @act = split '_',$_;
    $sentence.= $act[0].' ' ;
    push @tags,$act[1];
  }
  return ($sentence,\@tags);
}

sub test{
  my ($class,$testset,$num_samples,$burn_in) = (shift,shift,shift,shift);
  my ($tot_words,$tot_sentences)=(0,0);
  my ($right_words,$right_sentences)=(0,0);
  open(my $test_fh, '<:encoding(UTF-8)',$testset) or die("[xx] Error: Could not open the file '$testset'!");
  while($row = <$test_fh>){
    chomp $row;
    my @sent_tags;
    @sent_tags = $class->get_sentence_tags($row);
    my @tags = @{$sent_tags[1]};
    my @result = $class->{tagger}->tag($sent_tags[0],$num_samples,$burn_in);
    my $is_right = 1;
    for my $i (0..scalar(@result)-1){
      if($result[$i]->get_pos() eq $tags[$i]){
        $right_words++ ;
      }else{
        $is_right=0;
      }
      $tot_words+=1;
    }
    $right_sentences++ unless($is_right==0);
    $tot_sentences++;
  }
  die("[xx] Error: Test set is empty!") unless($tot_sentences > 0);
  print("[++] Accuracy Test:\n");
  print("[--] Number of sentences in test set: $tot_sentences\n");
  print("[--] Number of words in test set: $tot_words\n");
  print("[--] Weak Accuracy: ".(($right_words/$tot_words)*100)."\n");
  print("[--] Strong Accuracy: ".(($right_sentences/$tot_sentences)*100)."\n");
}



1;
