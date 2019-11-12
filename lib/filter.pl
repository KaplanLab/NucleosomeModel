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

my $column = get_arg("c", -1, \%args);
my $header_columns = get_arg("h", 1, \%args);
my $min_filter = get_arg("min", "__None__", \%args);
my $min_strict_filter = get_arg("mins", "__None__", \%args);
my $min_length_filter = get_arg("minl", "__None__", \%args);
my $max_filter = get_arg("max", "__None__", \%args);
my $max_strict_filter = get_arg("maxs", "__None__", \%args);
my $max_length_filter = get_arg("maxl", "__None__", \%args);
my $abs_filter = get_arg("abs", "__None__", \%args);
my $below_abs_filter = get_arg("babs", "__None__", \%args);
my $str_filter = get_arg("str", "__None__", \%args);
my $equal_str_filter = get_arg("estr", "__None__", \%args);
my $equal_str_list_filter_str = get_arg("estr_list", "__None__", \%args);
my $not_equal_str_filter = get_arg("nstr", "__None__", \%args);
my $min_pass_filter = get_arg("min_pass", 1, \%args);
my $relative_min_pass_filter = get_arg("rel_min_pass", "", \%args);
my $non_empty_filter = get_arg("ne", "__None__", \%args);
my $empty_filter = get_arg("e", "__None__", \%args);
my $numeric_filter = get_arg("numeric", "__None__", \%args);
my $print_num = get_arg("print_num", 0, \%args);
my $skip_rows = get_arg("sk", 0, \%args);
my $skip_rows2 = get_arg("skip", 0, \%args);
my $use_column = get_arg("u",-1,\%args);
my $is_verbose_mode = get_arg("q", "verbose", \%args);
my $pass_from = get_arg("pass_from", 0, \%args);

if ($skip_rows2 > $skip_rows) { $skip_rows = $skip_rows2; }

my $total_num_passed = 0;

my %equal_str_list_filter;
if (length($equal_str_list_filter_str) > 0)
{
  my @row = split(/;/, $equal_str_list_filter_str);
  for (my $i = 0; $i < @row; $i++)
  {
    $equal_str_list_filter{$row[$i]} = "1";
  }
}

for (my $i = 0; $i < $skip_rows; $i++)
{
  if ($print_num == 1) { print "0\t"; }

  my $line = <$file_ref>;
  print $line;
}

if ($is_verbose_mode eq "verbose")
{
  print STDERR "EXE_BASE_DIR/lib/filter.pl reading input file ";
}

my $row_counter = 1;
while(<$file_ref>)
{
    chomp;

    if (($is_verbose_mode eq "verbose") and ($row_counter % 10000 == 0))
    {
      print STDERR ".";
    }

    my @row = split(/\t/,$_,-1);
    my $print = 0;
    my $num_passed = 0;
    if ($relative_min_pass_filter ne ""){ $min_pass_filter=int($relative_min_pass_filter*scalar(@row)) }


    if ($use_column > -1)
    {
	if ($min_filter                 ne "__None__") { $min_filter=$row[$use_column]; }
	if ($min_strict_filter          ne "__None__") { $min_strict_filter=$row[$use_column]; }
	if ($min_length_filter          ne "__None__") { $min_length_filter=$row[$use_column]; }
	if ($max_filter                 ne "__None__") { $max_filter=$row[$use_column]; }
	if ($max_strict_filter          ne "__None__") { $max_strict_filter=$row[$use_column]; }
	if ($max_length_filter          ne "__None__") { $max_length_filter=$row[$use_column]; }
	if ($abs_filter                 ne "__None__") { $abs_filter=$row[$use_column]; }
	if ($below_abs_filter           ne "__None__") { $below_abs_filter=$row[$use_column]; }
	if ($str_filter                 ne "__None__") { $str_filter=$row[$use_column]; }
	if ($equal_str_filter           ne "__None__") { $equal_str_filter=$row[$use_column]; }
	if ($equal_str_list_filter_str  ne "__None__") { $equal_str_list_filter_str=$row[$use_column]; }
	if ($not_equal_str_filter       ne "__None__") { $not_equal_str_filter=$row[$use_column]; }
	if ($non_empty_filter           ne "__None__") { $non_empty_filter=$row[$use_column]; }
	if ($empty_filter               ne "__None__") { $empty_filter=$row[$use_column]; }
	if ($numeric_filter             ne "__None__") { $numeric_filter=$row[$use_column]; }
    }

    if ($column ne "-1")
    {
	if (&pass_filter($row[$column]) == 1)
	{
	    $num_passed++;
	}
    }
    else
    {
	for (my $i = $header_columns; $i < @row; $i++)
	{
	    if (&pass_filter($row[$i]) == 1)
	    {
		$num_passed++;
	    }
	}
    }
    if ($num_passed>=$min_pass_filter){
      $print=1;
    }
    
    if ($print == 1)
    {
      if ($print_num != 0) { print "$num_passed\t"; }
      print "$_\n";

      $total_num_passed++;
    }
    elsif ($total_num_passed >= 1 and $pass_from == 1)
    {
      if ($print_num != 0) { print "$num_passed\t"; }
      print "$_\n";
    }

    $row_counter++;
}

if ($is_verbose_mode eq "verbose")
{
  print STDERR "Done.\n";
}

sub pass_filter
{
  my ($num) = @_;

  my $pass = 1;

  my $sci_number = $num =~ /^[0-9\.]+[Ee][\-][0-9]+/;

  if ($num =~ /[A-Z]/ and $sci_number != 1) { if ($min_filter ne "__None__" or $max_filter ne "__None__") { $pass = 0; } }

  if ($min_filter                    ne "__None__" and $num < $min_filter)                      { $pass = 0; }
  if ($min_strict_filter             ne "__None__" and $num <= $min_strict_filter)              { $pass = 0; }
  if ($min_length_filter             ne "__None__" and length($num) < $min_length_filter)       { $pass = 0; }
  if ($max_filter                    ne "__None__" and $num > $max_filter)                      { $pass = 0; }
  if ($max_strict_filter             ne "__None__" and $num >= $max_strict_filter)              { $pass = 0; }
  if ($max_length_filter             ne "__None__" and length($num) > $max_length_filter)       { $pass = 0; }
  if ($abs_filter                    ne "__None__" and abs($num) < $abs_filter)                 { $pass = 0; }
  if ($below_abs_filter              ne "__None__" and abs($num) > $below_abs_filter)           { $pass = 0; }
  if ($str_filter                    ne "__None__" and not($num =~ /$str_filter/))              { $pass = 0; }
  if ($equal_str_filter              ne "__None__" and $num ne $equal_str_filter)               { $pass = 0; }
  if ($equal_str_list_filter_str     ne "__None__" and $equal_str_list_filter{$num} ne "1")     { $pass = 0; }
  if ($not_equal_str_filter          ne "__None__" and $num eq $not_equal_str_filter)           { $pass = 0; }
  if ($non_empty_filter              ne "__None__" and length($num) == 0)                       { $pass = 0; }
  if ($empty_filter                  ne "__None__" and length($num) > 0)                        { $pass = 0; }
  if ($numeric_filter                ne "__None__" and ($num =~ /^[0-9]+/) == 0)                { $pass = 0; }

  return $pass;
}

__DATA__

EXE_BASE_DIR/lib/filter.pl <data file>

   Filters the rows of a file based on filters. A row is printed if it passes
   the filter. The filter can be defined on a specific column or if no column
   is specified, then the row passes the filter if any of the columns passes.
   Tip: To count how many columns pass the filter without applying the filter,
   use "-min_pass 0 -print_num" .

   -c <num>:           The column to which the filter is applied (if not specified,
                       then if either column passes, the row passes.

   -h <num>:           Number of columns that are headers (default: 1)

   -min <num>:         Filter passes if the number is above or equal to <num>
   -mins <num>:        Filter passes if the number is strictly above <num>
   -minl <num>:        Filter passes if the number of characters of the column is >= <num>
   -max <num>:         Filter passes if the number is below or equal to <num>
   -maxs <num>:        Filter passes if the number is strictly below <num>
   -maxl <num>:        Filter passes if the number of characters of the column is <= <num>
   -abs <num>:         Filter passes if the number is above <num> or below -<num>
   -babs <num>:        Filter passes if the number is above -<num> and below <num>
   -str <str>:         Filter passes if the column contains <str>
   -estr <str>:        Filter passes if the column is equal to <str>
   -estr_list <str>:   Filter passes if the column is equal to one of the values in <str1;str2;...>
   -nstr <str>:        Filter passes if the column is *not* equal to <str>
   -ne:                Filter passes if string is not empty
   -e:                 Filter passes if string is empty
   -min_pass <num>:    Filter passes if at least num columns pass the filter (default: 1)
   -rel_min_pass <num>:Filter passes if at least int(num*rowlength) columns pass the filter
   -numeric:           Filter passes if string is numeric

   -pass_from:         Print all rows from the point that one row passed the filter

   -u <num>:           Use column <num> as the value for the the specified filters (e.g.
                       for the parameters " -c 1 -u 0 -mins " rows whose value in the second
                       column is greater than the value in the first column will pass)

   -print_num:         Prints the number of columns that passed the filter

   -sk <num>:          Print first num rows without filtering
   -skip <num>:        Print first num rows without filtering
   -q:                 Quite mode (default is verbose)

