#!/usr/bin/perl

use strict;

require "EXE_BASE_DIR/lib/load_args.pl";
require "EXE_BASE_DIR/lib/format_number.pl";
require "EXE_BASE_DIR/lib/sequence_helpers.pl";

if ($ARGV[0] eq "--help")
{
  print STDOUT <DATA>;
  exit;
}

my $file_ref;
my $file = $ARGV[0];
if (length($file) < 1 or $file =~ /^-/) 
{
  $file_ref = \*STDIN;
}
else
{
  open(FILE, $file) or die("Could not open file '$file'.\n");
  $file_ref = \*FILE;
}

my %args = load_args(\@ARGV);
my $alphabet_str = get_arg("a", "A;C;G;T", \%args);
my $errors = get_arg("e", 0, \%args);

my @alphabet = split(/\;/, $alphabet_str);

my $matrix_name;
my $consensus;
my $position_num;
while(<$file_ref>)
{
  chop;

  if (/<WeightMatrix.*Name=[\"]([^\"]+)[\"]/)
  {
      $matrix_name = $1;
      $consensus = "";
      $position_num = 0;
  }
  elsif (/<Position.*Weights=[\"]([^\"]+)[\"]/)
  {
      my @row = split(/\;/, $1);

      my $sequence_char = "";
      my $max_probability = 0;

      my @row1;
      for (my $i = 0; $i < @row; $i++)
      {
	$row1[$i] = "$i;$row[$i]";
      }
      @row1 = sort { my @aa = split(/\;/, $a); my @bb = split(/\;/, $b); $bb[1] <=> $aa[1] } @row1;

      for (my $i = 0; $i < @row; $i++)
      {
	  if ($i == 0 or $row[$i] > $max_probability)
	  {
	      $max_probability = $row[$i];
	      $sequence_char = $alphabet[$i];
	  }
      }

      if ($position_num < $errors)
      {
	my @row = split(/\;/, $row1[1]);
	$consensus .= "$alphabet[$row[0]]";
      }
      else
      {
	my @row = split(/\;/, $row1[0]);
	$consensus .= "$alphabet[$row[0]]";
      }

      $position_num++;
  }
  elsif (/<[\/]WeightMatrix/)
  {
      print "$matrix_name\t$consensus\n";
  }
}

__DATA__

EXE_BASE_DIR/lib/gxw2consensus.pl <gxm file>

   Outputs the consensus for each weight matrix assuming PSSMs

   -a <str>:   Alphabet (default: 'A;C;G;T')

   -e <num>:   Output the second highest letter in the first <num> positions (default: 0)

