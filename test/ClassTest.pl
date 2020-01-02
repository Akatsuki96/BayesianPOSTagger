#!/usr/bin/perl

use strict;
use warnings;
use Test::Simple 'no_plan';
use lib '../utils/';
use Sentence;
use Sample;
use TextStats;

my $sentence = new Sentence("This is a test.");
ok($sentence->get_sentece() eq "This is a test.","get_sentence return 'This is a test.' on sentence 'This is a test.'");
ok($sentence->get_number_of_words() eq 4,"get_number_of_words on 'This is a test.' returns 4");
ok($sentence->get_next_word() eq "This","First word of 'This is a test.' is 'This'");
ok($sentence->get_next_word() eq "is","Second word of 'This is a test.' is 'is'");
ok($sentence->get_next_word() eq "a","Third word of 'This is a test.' is 'a'");
ok($sentence->get_next_word() eq "test.","Fourth word of 'This is a test.' is 'test.'");
ok($sentence->get_next_word() eq 0,"There is no fifth word in 'This is a test'");
$sentence->reset();
ok($sentence->get_next_word() eq "This","Counter reset");

# Sample test
my $sample = new Sample("Test","NOUN");
ok($sample->get_word eq "Test","Sample (Test,NOUN) has the word 'Test'");
ok($sample->get_pos eq "NOUN","Sample (Test,NOUN) has the pos 'NOUN'");
ok($sample->is_word_equals("Test"),"The word 'Test' is represented by the sample (Test,NOUN)");
