package Functions;

use strict;
use warnings;
use lib './';
use Sample;

sub read_samples{
  my $file = shift or die('[xx] Error: you must pass a file!');
  my @samples; # [Sample::(Word, Pos)]
  my $new_sample; #::Sample
  my @words; #words list of word and PoS
  open(my $f_handler, '<:encoding(UTF-8)',$file) or die("[xx] Error: Could not open the file '$file'!");
  while(my $row = <$f_handler>){
    chomp $row;
    $row=~s/[[:punct:]]//g;
    @words = split ' ',$row;
    for (my $i=0; $i<(scalar(@words)-1); $i+=2){
      $words[$i] = lc $words[$i];
      $new_sample = new Sample($words[$i],$words[$i+1]);
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
