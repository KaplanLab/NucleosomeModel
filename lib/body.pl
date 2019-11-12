#!/usr/bin/perl

require "EXE_BASE_DIR/lib/libfile.pl";

use strict;

my $beg          = undef;
my $end          = undef;
my $count_blanks = 1;
my @skip_lines;
my @select_lines;
my $fin = \*STDIN;
while(@ARGV)
{
  my $arg = shift @ARGV;
  if($arg eq '--help')
  {
    print STDOUT <DATA>;
    exit(0);
  }
  elsif($arg eq '-b')
  {
    $count_blanks = 0;
  }
  elsif(not(defined($beg)))
  {
    $beg = int($arg);
  }
  elsif(not(defined($end)))
  {
    $end = int($arg);
  }
  elsif($arg eq '-skip')
  {
     my $lines_str = shift @ARGV;
     @skip_lines = sort {$a <=> $b} parseRanges($lines_str);
  }
  elsif($arg eq '-select')
  {
     my $lines_str = shift @ARGV;
     @select_lines = sort {$a <=> $b} parseRanges($lines_str);
  }
  elsif(-f $arg or -l $arg)
  {
     open($fin, $arg) or die("Could not open file '$arg'");
  }
  else
  {
    die("EXE_BASE_DIR/lib/body.pl: Bad argument '$arg' given.  Use --help for help.");
  }
}

if(not(defined($beg)))
{
  $beg = 1;
}

if(not(defined($end)))
{
  $end = -1;
}

my $num_lines = undef;
my $tmp_file  = undef;
if($end < -1)
{
   $tmp_file = 'tmp_' . time . '.' . rand() . '.EXE_BASE_DIR/lib/body.pl';
   open(TMP, ">$tmp_file") or die("Could not open temporary file '$tmp_file' for writing");
   while(<$fin>)
     { print TMP; }
   close(TMP);

   my $wc = `wc $tmp_file`;
   my @tuple = split(/\s+/,$wc);
   $num_lines = $tuple[1];
   print STDERR "The file has $num_lines number of lines.\n";

   open($fin, "<$tmp_file") or die("Could not open the temporary file '$tmp_file' for reading");

}

my $line = 0;
my $skip_counter = 0;
my $select_counter = 0;
$end = defined($num_lines) ? $num_lines + $end + 1 : $end;
while(<$fin>)
{
  if($count_blanks or /\S/)
  {
    $line++;
    if (@skip_lines >= $skip_counter and $line == $skip_lines[$skip_counter])
    {
       $skip_counter++;
       next;
    }
    if (@select_lines>0 and $line != $select_lines[$select_counter])
    {
      next;
    }
    $select_counter++;

    if(defined($num_lines))
    {
       if($line >= $beg and ($line <= $end))
       {
         print;
       }
    }
    else
    {
       if($line >= $beg and ($end == -1 or $line <= $end))
       {
         print;
       }
    }
  }
}

if(defined($tmp_file))
{
   system("rm -f $tmp_file");
}

exit(0);

__DATA__
Syntax: EXE_BASE_DIR/lib/body.pl BEG END < FILE

BEG, END are the beginning and end lines (inclusive) to select from
the file.  If END=-1 then the rest of the file is included for example BEG=2 END=-1
returns the whole file except the first row.

OPTIONS are:

-b: Do *not* include blank lines when counting (default counts them).
-skip <n1,n2...>: Exclude line numbers n1,n2... 
-select <n1,n2>:  Select line numbers n1,n2...

