#!/usr/bin/perl

use strict;

require "EXE_BASE_DIR/lib/load_args.pl";

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

my $lowercase = get_arg("l", 0, \%args);
my $column = get_arg("c", "", \%args);

while(<$file_ref>)
{
    if (length($column) > 0)
    {
	chop;

	my @row = split(/\t/);

	for (my $i = 0; $i < @row; $i++)
	{
	    if ($i > 0) { print "\t"; }

	    if ($i == $column)
	    {
		if ($lowercase eq "1") { print "\L$row[$i]"; }
		else { print "\U$row[$i]"; }
	    }
	    else
	    {
		print "$row[$i]";
	    }
	}

	print "\n";
    }
    elsif ($lowercase eq "1") { print "\L$_"; }
    else { print "\U$_"; }
}

__DATA__

EXE_BASE_DIR/lib/to_upper_case.pl <file>

   Converts <file> into upper case.

   -l:       Convert to lower case

   -c <num>: Convert only column <num> (default: convert the entire line)

