#!/usr/bin/perl

use strict;

##---------------------------------------------------------------------------##
## public:
##---------------------------------------------------------------------------##

##---------------------------------------------------------------------------##
## $int listSize (\@list)
##---------------------------------------------------------------------------##
sub listSize
{
   my ($list) = @_;
   return scalar(@{$list});
}

##---------------------------------------------------------------------------##
## $string listMaxString (\@list)
##---------------------------------------------------------------------------##
sub listMaxString
{
   my ($list) = @_;
   my $result = undef;
   foreach my $element (@{$list})
   {
      if(not(defined($result)) or $element gt $result)
      {
         $result = $element;
      }
   }
   return $result;
}

##---------------------------------------------------------------------------##
## $double listMax (\@list)
##---------------------------------------------------------------------------##
sub listMax
{
   my ($list) = @_;
   my $result = undef;
   foreach my $element (@{$list})
   {
      if(not(defined($result)) or $element > $result)
      {
         $result = $element;
      }
   }
   return $result;
}

##---------------------------------------------------------------------------##
## $double listSum (\@list)
##---------------------------------------------------------------------------##
sub listSum
{
   my ($list) = @_;
   my $result = 0;
   my $num    = 0;
   foreach my $element (@{$list})
   {
      if($element =~ /\S/ and $element ne 'NaN')
      {
         $result += $element;
         $num++;
      }
   }
   return $num == 0 ? undef : $result;
}

##---------------------------------------------------------------------------##
## $string listMinString (\@list)
##---------------------------------------------------------------------------##
sub listMinString
{
   my ($list) = @_;
   my $result = undef;
   foreach my $element (@{$list})
   {
      if(not(defined($result)) or $element lt $result)
      {
         $result = $element;
      }
   }
   return $result;
}

#---------------------------------------------------------------------------##
# $double listMin (\@list)
#---------------------------------------------------------------------------##
sub listMin
{
   my ($list) = @_;
   my $result = undef;
   foreach my $element (@{$list})
   {
      if(not(defined($result)) or $element < $result)
      {
         $result = $element;
      }
   }
   return $result;
}

#---------------------------------------------------------------------------##
# \@list listSublist (\@list list, \@list indices)
#---------------------------------------------------------------------------##
sub listSublist
{
   my ($list, $indices) = @_;

   my @sublist;

   foreach my $index (@{$indices})
   {
      push(@sublist, $$list[$index]);
   }

   return \@sublist;
}

#---------------------------------------------------------------------------##
# \@list listCombinations (\@list, $int min=undef, $int max=undef,
#                          $string delim="\t")
#---------------------------------------------------------------------------##
sub listCombinations
{
   my ($list, $min, $max, $delim) = @_;
   $delim = not(defined($delim)) ? "\t" : $delim;

   my %result;

   my @bits;
   foreach my $item (@{$list})
      { push(@bits, 0); }

   my $i = 0;
   &listCombinationsRecursively($list, \@bits, \%result, \$i, $min, $max, $delim);

   my @result;
   foreach my $combination (sort(keys(%result)))
   {
      $i = $result{$combination};
      $result[$i] = $combination;
   }

   return \@result;
}

##---------------------------------------------------------------------------##
## private:
##---------------------------------------------------------------------------##

##---------------------------------------------------------------------------##
## void listCombinationsRecursively (\@list, \@list bits, \%set result,
##                                   \$int i, $int min, $int max,
##                                   $string delim="\t")
##---------------------------------------------------------------------------##
sub listCombinationsRecursively
{
   my ($list, $bits, $result, $i, $min, $max, $delim) = @_;

   my @combination;
   for(my $j = 0; $j < scalar(@{$list}); $j++)
   {
      if($$bits[$j])
      {
         push(@combination, $$list[$j]);
      }
   }

   if($#combination >= 0 and
      (not(defined($min)) or $#combination >= ($min - 1)) and
      (not(defined($max)) or $#combination <= ($max - 1)))
   {
      my $combination = join($delim, @combination);

      if(not(exists($$result{$combination})))
      {
         $$result{$combination} = $$i;
         $$i++;
      }
   }

   for(my $j = 0; $j < scalar(@{$bits}); $j++)
   {
      if($$bits[$j] == 0)
      {
         my @bits_copy  = @{$bits};
         $bits_copy[$j] = 1;
         &listCombinationsRecursively($list, \@bits_copy, $result, $i, $min, $max, $delim);
      }
   }
}


##---------------------------------------------------------------------------##
## void listPrint (\@list, \*FILE file=STDOUT, $delim)
##---------------------------------------------------------------------------##
sub listPrint
{
   my ($list, $fp, $delim) = @_;
   $fp = not(defined($fp)) ? \*STDOUT : $fp;
   $delim = not(defined($delim)) ? "\t" : $delim;

   my $i = 0;
   foreach my $element (@{$list})
   {
      if($i > 0)
      {
         print $delim;
      }
      print $fp "$element";
      $i++;
   }
}

#---------------------------------------------------------------------------
# \@list listRead ($string file, $string delim="\t", int col=0,
#                  \%assoc alias=undef, $int headers=0)
#---------------------------------------------------------------------------
sub listRead
{
   my ($file, $delim, $col, $alias, $headers) = @_;
   $col     = not(defined($col)) ? 0 : $col;
   $delim   = not(defined($delim)) ? "\t" : $delim;
   $headers = defined($headers) ? $headers : 0;

   my $fp;
   open($fp, $file) or die("Could not open file '$file' in setRead");
   my @list;
   my $line_no = 0;
   my $header = '';
   while(<$fp>)
   {
      $line_no++;

      if($line_no > $headers)
      {
         my @tuple = split($delim, $_, $col + 2);
         chomp($tuple[$#tuple]);
         my $element = $tuple[$col];
         if(defined($alias))
         {
            if(exists($$alias{$element}))
            {
               $element = $$alias{$element};
               push(@list, $element);
            }

         }
         else
         {
            push(@list, $element);
         }
      }
      else
      {
         $header .= $_;
      }
   }
   close($fp);
   return (\@list, $header);
}

##-----------------------------------------------------------------------------
## \@list listRandom (\@list list, $int num=scalar(@list), $int replace=1)
##-----------------------------------------------------------------------------
sub listRandom
{
   my ($list, $num, $replace) = @_;
   $num     = not(defined($num)) ? scalar(@{$list}) : $num;
   $replace = not(defined($replace)) ? 1 : 0;

   my $list_copy = $list;
   my @sub_list;

   if(not($replace))
   {
      my @list_copy = @{$list};
      $list_copy = \@list_copy;
   }

   for(my $i=0; $i<$num; $i++)
   {
     my $r = int(rand(scalar(@{$list_copy})));
     my $item;
     if($replace)
     {
       $item = $$list_copy[$r];
     }
     else
     {
       $item = splice(@{$list_copy}, $r, 1);
     }
     push(@sub_list, $item);
   }
   return \@sub_list;
}

##-----------------------------------------------------------------------------
## $double listMean (\@list)
##-----------------------------------------------------------------------------
sub listMean
{
   my ($list) = @_;

   my $mean = 0;

   foreach my $element (@{$list})
   {
      $mean += $element;
   }

   my $num = scalar(@{$list});

   if($num > 0)
   {
      $mean /= $num;
   }
   else
   {
      $mean = undef;
   }

   return $mean;
}

##-----------------------------------------------------------------------------
# \@list listPermute (\@list, $int num=scalar(@list), $replace=0)
##-----------------------------------------------------------------------------
sub listPermute
{
   my ($list, $num, $replace) = @_;

   $num = defined($num) ? $num : scalar(@{$list});

   $replace = defined($replace) ? $replace : 0;

   my @new_list;

   my $item = undef;

   my $num_entries = scalar(@{$list});

   my @I;
   my %I;
   my %notI;

   if(not($replace))
   {
      for(my $i = 0; $i < $num_entries; $i++)
      {
         $notI{$i} = $i;
      }
   }

   for (my $i = 0; $i < $num; $i++)
   {
      my $r = int(rand($num_entries));

      if($replace)
      {
         $item = $$list[$r];
      }
      else
      {
         while(exists($I{$r}))
         {
            $r = int(rand($num_entries));
         }
         $I{$r} = 1;
         delete($notI{$r});
      }

      push(@new_list, $$list[$r]);
   }

   return \@new_list;
}

# $int binarySearch (\@list, $double value,
#                    $int beg=undef, $int end=undef)
sub binarySearch
{
   my ($list, $value, $beg, $end) = @_;
   my $index;

   $beg = defined($beg)   ? $beg   : 0;
   $end = defined($end)   ? $end   : scalar(@{$list}) - 1;

   # Base case:
   if($beg >= $end - 1)
   {
      $index = $beg;
   }
   else
   {
      my $pivot       = int(($end + $beg) * 0.5);
      my $pivot_val   = $$list[$pivot];

      my $beg_val = $$list[$beg];
      my $end_val = $$list[$end];
      print STDERR "[$value, $beg_val, $pivot_val, $end_val]\n";

      if($value < $pivot_val)
      {
         $index = &binarySearch($list, $value, $beg, $pivot);
      }
      elsif($value > $pivot_val)
      {
         $index = &binarySearch($list, $value, $pivot, $end);
      }
      else
      {
         $index = $pivot;
      }
   }
   return $index;
}

1




