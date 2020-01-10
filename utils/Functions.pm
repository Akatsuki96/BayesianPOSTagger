package Functions;

use lib './';
use Sample;

sub read_samples{
  my $file = shift or die('[xx] Error: you must pass a file!');
  my $punc = shift;
  my @samples; # [Sample::(Word, Pos)]
  my $new_sample; #::Sample
  my $firstlast = 0;
  my @words; #words list of word and PoS
  open(my $f_handler, '<:encoding(UTF-8)',$file) or die("[xx] Error: Could not open the file '$file'!");
  while($row = <$f_handler>){
    chomp $row;
    #$row=~s/[[:punct:]]//g unless(defined($punc));
    @words = split " ",$row;
    for (my $i=0; $i<(scalar(@words)); $i++){
      my @wordpos = split '/',$words[$i];
      #$words[$i] = lc $words[$i];
      #print("[".$wordpos[0]."|".$wordpos[1]."]"); #for (@wordpos);
      if($i==0){
        $firstlast=1;#"F";
      } elsif($i==scalar(@words)-1){
        $firstlast=-1;
      } else{
        $firstlast = 0;
      }
      $new_sample = new Sample(($wordpos[0]),$wordpos[1],$firstlast);
      push @samples,$new_sample;
    }
  }
  close($f_handler);
  return @samples; # return samples
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

sub sum{
  my @list = @_;
  my $sum = 0;
  $sum+=$_ for (@list);
  return $sum;
}


sub is_in{
  my ($lst,$str)=(shift,shift);
  for my $elem (@$lst){
    return 1 unless(not $elem eq $str);
  }
  return 0;
}

1;
