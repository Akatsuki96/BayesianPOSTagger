package Functions;

use strict;
use warnings;
use lib './';
use Sample;

sub read_samples{
  my $file = shift or die('[xx] Error: you must pass a file!');
  my $punc = shift;
  my @samples; # [Sample::(Word, Pos)]
  my $new_sample; #::Sample
  my @words; #words list of word and PoS
  open(my $f_handler, '<:encoding(UTF-8)',$file) or die("[xx] Error: Could not open the file '$file'!");
  while(my $row = <$f_handler>){
    chomp $row;
    #$row=~s/[[:punct:]]//g unless(defined($punc));
    @words = split " ",$row;
    for (my $i=0; $i<(scalar(@words)); $i++){
      my @wordpos = split '/',$words[$i];
      #$words[$i] = lc $words[$i];
      #print("[".$wordpos[0]."|".$wordpos[1]."]"); #for (@wordpos);
      $new_sample = new Sample(($wordpos[0]),$wordpos[1]);
      push @samples,$new_sample;
    }
  }
  close($f_handler);
  return @samples; # return samples
}


sub is_in{
  my ($lst,$str)=(shift,shift);
  for my $elem (@$lst){
    return 1 unless(not $elem eq $str);
  }
  return 0;
}

1;
