# \%set         attrib2Set            (\%attrib)
# \%set         list2Set              (\@list)
# $double       overlapPvalue         (\%set set1, \%set set2, $int N)
# \%set         pairsRead             ($string file, $string delim="\t", $int col1=0, $int col2=1, $int directed=1)
#
# \%attrib      set2Assoc             (\%set, $delim)
# \@list        set2List              (\%set, int keep_vals=0)
# \%set         setCombinations       (\%set)
# \%set         setCrossSelf          (\%set, $int ordered=1, $int identities=1, $string delim="\t")
# \%set         setDifference         (\%set set1, \%set set2)
# $int          setExists             (\%set, $string member)
# void          setExpand             (\%set set1, \%set set2)
# \%set         setIntersection       (\%set set1, \%set set2)
# void          setListsPrint         (\%sets, \*FILE fp=\*STDOUT)
# \%\@set_lists setListsRead          ($string file, $string delim="\t", $int col1=0, $int col2=1, \%attrib alias=undef)
# \@list        setMembersList        (\%set)
# \%set         setMembers            (\%set)
# void          setPrint              (\%set, \*FILE fp=\*STDOUT, $int print_values=0, $string delim1="\n", $string $delim2="\t")
# \%set         setRead               ($string file, $string delim="\t", $int col=0, $int headers=0, \%attrib alias=undef)
# \%set         setReadPairs          ($string file, $string delim="\t", $int col1=0, $int col2=1, \%attrib alias=undef)
# \%set         setReadTuples         ($string file, $string delim_in="\t", $string delim_out="\t", \@list cols=undef, $bool order=0, \%attrib alias=undef)
# \%set         setReadVec            ($string file, $mem_val=1, $string delim="\t", $int key_col=0, $int set_col=0, $headers=0)
# void          setReduce             (\%set set1, \%set set2)
# $int          setSize               (\%set)
# \%sets        setSubset             (\%set, \%set selection)
# \%set         setUnion              (\%set set1, \%set set2)
#
# \%set         sets2Vectors          (\%\%sets, \@set_selection=undef, \@member_selection=undef)
# \@list        sets2List             (\%\%sets, $string delim="\t")
# $int          setsCoMembers         (\%\%sets, $string x, $string y)
# \%\%set       setsCrossSelf         (\%\%sets, $int ordered=1, $int identities=1, $string delim="\t")
# \%\%sets      setsDifference        (\%sets sets1, \%sets sets2)
# void          setsExpand            (\%\%sets sets1, \%\%sets sets2)
# void          setsExpandSelf        (\%\%sets)
# $string       setsFindBiggest       (\%\%sets)
# \%set         setsGetDistinct       (\%\%sets, \@selection)
# \%\%sets      setsIntersection      (\%\%sets sets1, \%\%sets sets2)
# \%set         setsIntersctionSelf   (\%\%sets)
# \%\%sets      setsInvert            (\%\%sets, \%selection=undef)
# \%attrib      setsJoin              (\%\%sets, $int sort_members=0, $string delim="\t")
# \@list        setsMemberOf          (\%\%sets, $string member=$_)
# \@list        setsOverlap           (\%set, \%\%sets, $int pop_size=union(set,sets), $double cutoff=undef, $int sorted=0)
# void          setsPrint             (\%sets, \*FILE fp=\*STDOUT, $string delim="\t", $int print_values=0)
# void          setsPrintMatrix       (\%\%sets, \*FILE fp=\*STDOUT, $string delim="\t")
# void          setsPrintTable        ()
# \%\%sets      setsRead              ($string file, $string delim="\t", $int mem_col=0, $int set_col=1,\%attrib alias=undef, $int bidirectional=0)
# \%\%sets      setsReadLists         ($string file, $string delim="\t", $int key_col=0, $headers=0, \%order, $int max=undef,  $int invert=0)
# \%\%sets      setsReadMatrix        ($string file, $int mem_val=1, $string delim="\t", $int key_col=0, $headers=1, \%set order=undef, \%set selected=undef, \%attrib alias=undef)
# void          setsReadTable         ()
# \%\%sets      setsReduceSelf        (\%\%sets)
# \%set         setsReduce            (\%sets sets1, \%sets sets2)
# \@list        setsSizes             (\%\%sets)
# \%\%sets      setsSubset            (\%\%sets, \%set selection)
# $int          setsSumSizes          (\%\%sets)
# \%\%sets      setsUnion             (\%\%sets sets1, \%\%sets sets2)
# \%set         setsUnionSelf         (\%\%sets)

use strict;

require "EXE_BASE_DIR/lib/libfile.pl";
require "EXE_BASE_DIR/lib/libstats.pl";
require "EXE_BASE_DIR/lib/liblist.pl";

##---------------------------------------------------------------------------##
## public:
##---------------------------------------------------------------------------##

##---------------------------------------------------------------------------##
## $int setExists (\%set, $string member)
##---------------------------------------------------------------------------##
sub setExists
{
   my ($set, $member) = @_;
   $member = defined($member) ? $member : $_;

   return defined($set) and exists($$set{$member});
}

##---------------------------------------------------------------------------##
## \@list setMembersList (\%set)
##---------------------------------------------------------------------------##
sub setMembersList
{
   my ($set) = @_;
   return (defined($set) ? [keys(%{$set})] : []);
}

##---------------------------------------------------------------------------##
## \%set setMembers (\%set)
##---------------------------------------------------------------------------##
sub setMembers
{
   my ($set) = @_;
   return (defined($set) ? &list2Set([keys(%{$set})]) : &list2Set([]));
}

##---------------------------------------------------------------------------##
## $int setSize (\%set)
##---------------------------------------------------------------------------##
sub setSize
{
   my ($set) = @_;
   return defined($set) ? scalar(keys(%{$set})) : 0;
}

##---------------------------------------------------------------------------##
## \%sets setSubset(\%set, \%set selection)
##
## Selects a subset of sets.
##---------------------------------------------------------------------------##
sub setSubset
{
   my ($set, $selection) = @_;
   my %subset;
   foreach my $member (keys(%{$selection}))
   {
      if(exists($$set{$member}))
      {
         $subset{$member} = $$set{$member};
      }
   }
   return \%subset;
}

##---------------------------------------------------------------------------##
## \@list setsSizes (\%\%sets)
##---------------------------------------------------------------------------##
sub setsSizes
{
   my ($sets) = @_;
   my @sizes;
   foreach my $set_key (keys(%{$sets}))
   {
      push(@sizes, &setSize($$sets{$set_key}));
   }
   return \@sizes;
}

##---------------------------------------------------------------------------##
## $int setsSumSizes (\%\%sets)
##---------------------------------------------------------------------------##
sub setsSumSizes
{
   my $sizes = &setsSizes(@_);
   my $sum   = 0;
   foreach my $size (@{$sizes})
   {
      $sum += $size;
   }
   return $sum;
}

##---------------------------------------------------------------------------##
## \@list setsMemberOf (\%\%sets, $string member=$_)
##---------------------------------------------------------------------------##
sub setsMemberOf
{
   my ($sets, $member) = @_;
   $member = defined($member) ? $member : $_;

   my @sets_i_am_in;
   foreach my $set_key (keys(%{$sets}))
   {
      my $set = $$sets{$set_key};

      if(exists($$set{$member}))
      {
         push(@sets_i_am_in, $set_key);
      }
   }
   return \@sets_i_am_in;
}

##---------------------------------------------------------------------------##
## $string setsFindBiggest (\%\%sets)
##
##  Returns the set key to the largest set.
##
##---------------------------------------------------------------------------##
sub setsFindBiggest
{
   my ($sets) = @_;
   my $biggest_key  = undef;
   my $biggest_size = undef;
   foreach my $set_key (keys(%{$sets}))
   {
      my $size = &setSize($$sets{$set_key});
      if(not(defined($biggest_size)) or $size > $biggest_size)
      {
         $biggest_key  = $set_key;
         $biggest_size = $size;
      }
   }
   return $biggest_key;
}

##---------------------------------------------------------------------------##
## \%set setUnion (\%set set1, \%set set2)
##---------------------------------------------------------------------------##
sub setUnion # (\%set1, \%set2)
{
   my ($set1, $set2) = @_;

   my %union;

   if(defined($set2))
   {
      foreach my $member (keys(%{$set2}))
      {
         $union{$member} = $$set2{$member};
      }
   }

   if(defined($set1))
   {
      foreach my $member (keys(%{$set1}))
      {
         $union{$member} = $$set1{$member};
      }
   }

   return \%union;
}

##---------------------------------------------------------------------------##
## \%\%sets setsUnion (\%\%sets sets1, \%\%sets sets2)
##---------------------------------------------------------------------------##
sub setsUnion
{
   my ($sets1, $sets2) = @_;
   my $key_union = &setUnion($sets1, $sets2);
   my %unions;
   foreach my $set_key (keys(%{$key_union}))
   {
      $unions{$set_key} = &setUnion($$sets1{$set_key}, $$sets2{$set_key});
   }
   return \%unions;
}

##---------------------------------------------------------------------------##
## \%set setIntersection (\%set set1, \%set set2)
##---------------------------------------------------------------------------##
sub setIntersection
{
   my ($set1, $set2) = @_;
   my %intersection;
   if(defined($set1) and defined($set2))
   {
      foreach my $member (keys(%{$set1}))
      {
         if(exists($$set2{$member}))
         {
            $intersection{$member} = $$set1{$member};
         }
      }
   }

   return \%intersection;
}

##---------------------------------------------------------------------------##
## \%set setDifference (\%set set1, \%set set2)
##
## Computes the difference set1-set2 -- returns a set with members contained
## in set1 but not in set2.
##---------------------------------------------------------------------------##
sub setDifference
{
   my ($set1, $set2) = @_;
   my %difference;
   if(defined($set1))
   {
      if(defined($set2))
      {
         foreach my $member (keys(%{$set1}))
         {
            if(not(exists($$set2{$member})))
            {
               $difference{$member} = $$set1{$member};
            }
         }
      }
      else
      {
         %difference = %{$set1};
      }
   }
   return \%difference;
}

##---------------------------------------------------------------------------##
## \%\%sets setsDifference (\%sets sets1, \%sets sets2)
##
##---------------------------------------------------------------------------##
sub setsDifference
{
   my ($sets1, $sets2) = @_;
   my %diffs;
   foreach my $set_key (keys(%{$sets1}))
   {
      if(exists($$sets2{$set_key}))
      {
         $diffs{$set_key} = &setDifference($$sets1{$set_key}, $$sets2{$set_key});
      }
      else
      {
         $diffs{$set_key} = \%{$$sets1{$set_key}};
      }
   }
   return \%diffs;
}

##---------------------------------------------------------------------------##
## \%\%sets setsIntersection (\%\%sets sets1, \%\%sets sets2)
##---------------------------------------------------------------------------##
sub setsIntersection
{
   my ($sets1, $sets2) = @_;
   my %intersections;
   foreach my $set_key (keys(%{$sets1}))
   {
      if(exists($$sets2{$set_key}))
      {
         $intersections{$set_key} = &setIntersection($$sets1{$set_key}, $$sets2{$set_key});
      }
   }
   return \%intersections;
}

##---------------------------------------------------------------------------##
## \%set setsUnionSelf (\%\%sets)
##---------------------------------------------------------------------------##
sub setsUnionSelf # (\%\%sets)
{
   my ($sets) = @_;
   my %union;
   my @set_keys = keys(%{$sets});
   foreach my $set_key (@set_keys)
   {
      my $set = $$sets{$set_key};
      foreach my $member (keys(%{$set}))
      {
         $union{$member} = $$set{$member};
      }
   }
   return \%union;
}

##---------------------------------------------------------------------------##
## \%set setsIntersctionSelf (\%\%sets)
##---------------------------------------------------------------------------##
sub setsIntersectionSelf
{
   my ($sets) = @_;

   my @set_keys = keys(%{$sets});

   # Find out which members are in all the sets.
   my %intersection;
   my $set1 = $$sets{$set_keys[0]};
   foreach my $member (keys(%{$set1}))
   {
      my $in_all = 1;
      for(my $i = 0; $i <= $#set_keys and $in_all; $i++)
      {
         my $set = $$sets{$set_keys[$i]};

         if(not(exists($$set{$member})))
         {
            $in_all = 0;
         }
      }
      if($in_all)
      {
         $intersection{$member} = $$set1{$member};
      }
   }
   return \%intersection;
}

##---------------------------------------------------------------------------##
## \%\%sets setsReduceSelf (\%\%sets)
##
## Set all the sets equal to the intersection of the sets.
##---------------------------------------------------------------------------##
sub setsReduceSelf
{
   my ($sets) = @_;

   # Get the common members
   my $intersection = &setsIntersection($sets);

   # Reduce each set to only have members in the intersection
   my %new_sets;
   foreach my $set_key (keys(%{$sets}))
   {
      $new_sets{$set_key} = \%{$intersection};
   }

   return \%new_sets;
}

##---------------------------------------------------------------------------##
## void setReduce (\%set set1, \%set set2)
##
## Reduce set1 to the members common with set2.
##
##---------------------------------------------------------------------------##
sub setReduce
{
   my ($set1, $set2) = @_;
   if(defined($set2))
   {
      my $intersection = &setIntersection($set1, $set2);
      $set1 = $intersection;
   }
}

##---------------------------------------------------------------------------##
## void setExpand (\%set set1, \%set set2)
##
## set all the sets equal to the union of all sets.
##---------------------------------------------------------------------------##
sub setExpand
{
   my ($set1, $set2) = @_;
   my $union = &setUnion($set1, $set2);
   $set1 = $union;
}

##---------------------------------------------------------------------------##
## void setsExpand (\%\%sets sets1, \%\%sets sets2)
##---------------------------------------------------------------------------##
sub setsExpand
{
   my ($sets1, $sets2) = @_;
   my $unions = &setsUnion($sets1, $sets2);
   $sets1 = $unions;
}

##---------------------------------------------------------------------------##
## void setsExpandSelf (\%\%sets)
##
## set all the sets equal to the union of all sets.
##---------------------------------------------------------------------------##
sub setsExpandSelf
{
   my ($sets) = @_;

   my $union = &setsUnionSelf($sets);

   # Reduce each set to only have members in the intersection
   my %new_sets;
   foreach my $set_key (keys(%{$sets}))
   {
      $new_sets{$set_key} = \%{$union};
   }

   return \%new_sets;
}

##---------------------------------------------------------------------------##
## \%set setCrossSelf (\%set, $int ordered=1, $int identities=1, $string delim="\t")
##---------------------------------------------------------------------------##
sub setCrossSelf
{
   my ($set, $ordered, $identities, $delim);
   $ordered    = not(defined($ordered)) ? 1 : $ordered;
   $identities = not(defined($identities)) ? 1 : $identities;
   $delim      = not(defined($delim)) ? "\t" : $delim;
   my %pair_set;

   my @members = keys(%{$set});

   for(my $i = 0; $i <= $#members; $i++)
   {
      for(my $j = 0; $j <= $#members; $j++)
      {
         if(not($ordered) or ($j >= $i))
         {
            if($identities or ($j != $i))
            {
               my $one;
               my $two;
               if($ordered)
               {
                  $one = $members[$i];
                  $two = $members[$j];
               }
               else
               {
                  $one = (($members[$i] cmp $members[$j]) < 0) ? $members[$i] : $members[$j];
                  $two = (($members[$j] cmp $members[$j]) < 0) ? $members[$j] : $members[$i];
               }
               my $pair         = $one . $delim . $two;
               my $value        = $$set{$one} . $delim . $$set{$two};
               $pair_set{$pair} = $value;
            }
         }
      }
   }

   return \%pair_set;
}

##---------------------------------------------------------------------------##
## \%\%set setsCrossSelf (\%\%sets, $int ordered=1, $int identities=1, $string delim="\t")
##---------------------------------------------------------------------------##
sub setsCrossSelf
{
   my ($sets, $ordered, $identities, $delim);
   $ordered    = not(defined($ordered)) ? 1 : $ordered;
   $identities = not(defined($identities)) ? 1 : $identities;
   $delim      = not(defined($delim)) ? "\t" : $delim;
   my %pair_sets;
   foreach my $set_key (keys(%{$sets}))
   {
      $pair_sets{$set_key} = &setCrossSelf($$sets{$set_key}, $ordered, $identities, $delim);
   }
   return \%pair_sets;
}

##---------------------------------------------------------------------------##
## \%\%sets setsSubset (\%\%sets, \%set selection)
##
## selection contains a set of  keys that select sets.
##---------------------------------------------------------------------------##
sub setsSubset
{
   my ($sets, $selection) = @_;

   my %subset_sets;
   foreach my $set_key (keys(%{$selection}))
   {
      # $subset_sets{$set_key} = \%{$$sets{$set_key}};
      $subset_sets{$set_key} = $$sets{$set_key};
   }
   return \%subset_sets;
}

##---------------------------------------------------------------------------##
## \%attrib set2Assoc (\%set, $delim)
##---------------------------------------------------------------------------##
sub set2Assoc
{
   my ($set, $delim) = @_;
   $delim = not(defined($delim)) ? "\t" : $delim;
   my %attrib;
   foreach my $member (keys(%{$set}))
   {
      my ($attval, $value) = split($delim, $member);
      $attrib{$attval} = $value;
   }
   return \%attrib;
}

##---------------------------------------------------------------------------##
## \%set attrib2Set (\%attrib)
##---------------------------------------------------------------------------##
sub attrib2Set
{
   my ($attrib) = @_;
   my %set;
   foreach my $attval (keys(%{$attrib}))
   {
      my $value = $$attrib{$attval};
      $set{$attval} = 1;
      $set{$value}  = 1;
   }
   return \%set;
}

##---------------------------------------------------------------------------##
## \%set list2Set (\@list, $int overwrite=0)
#
#  If overwrite == 1 then items further down the list overwrite
#  items earlier in the list.  If overwrite = -1 then a list
#  of row indices are stored for each occurrence.
##---------------------------------------------------------------------------##
sub list2Set
{
   my ($list, $overwrite) = @_;

   $overwrite = defined($overwrite) ? $overwrite : 0;

   my %set;

   for(my $i = 0; $i < scalar(@{$list}); $i++)
   {
      my $member = $$list[$i];

      if($overwrite == -1)
      {
         if(not(exists($set{$member})))
         {
            my @list;
            $set{$member} = \@list;
         }
         push(@{$set{$member}}, $i);
      }
      elsif($overwrite or not(exists($set{$member})))
      {
         $set{$member} = $i;
      }
   }
   return \%set;
}

##---------------------------------------------------------------------------##
## \@list set2List (\%set, int keep_vals=0)
##---------------------------------------------------------------------------##
sub set2List
{
   my ($set, $keep_vals) = @_;
   $keep_vals = defined($keep_vals) ? $keep_vals : 0;
   my @list;
   my @keys = keys(%{$set});
   foreach my $key (@keys)
   {
      push(@list, $keep_vals ? [$key, $$set{$key}] : $key);
   }
   return \@list;
}

##---------------------------------------------------------------------------##
## $double overlapPvalue (\%set set1, \%set set2, $int N)
##
## Hypergeometric p-value for the overlap between the two sets.  $N is the
## size of the population.  If $N is not supplied, the population is assumed
## to be equal to the union of the two sets.  This gives the p-value of
## getting the intersection between set1 and set2.
## in set2 and getting the intersection by chance.
##---------------------------------------------------------------------------##
sub setOverlap
{
   my($set1, $set2, $N) = @_;

   # The number of success drawn.
   my $k = &setSize(&setIntersection($set1, $set2));

   # The number drawn from the population
   my $K = &setSize($set1);

   # The number of successes in the population
   my $n = &setSize($set2);

   # The size of the population
   $N = not(defined($N)) ? &setSize(&setUnion($set1, $set2)) : $N;

   # The hypergeometric p-value
   my $p = $k > 0 ? &ComputeLog10HyperPValue($k, $n, $K, $N) : 0;

   $p = ($k/$K < $n / $N) ? log(1 - (10**$p)) / log(10) : $p;

   return ($p, $k, $K, $n, $N);
}

##-----------------------------------------------------------------------------
## \@list setsOverlap(\%set, \%\%sets, $int pop_size=union(set,sets),
##                    $double cutoff=undef, $int sorted=0)
##
##  Computes the overlap between the members in the set to every set
##  in the given sets.  The results are sorted by decreasing p-value.
##  Each entry in the results list contains a list:
##
##  [KEY, PVAL, OVERLAP, DRAWS, SUCCESSES, POPULATION].
##
##-----------------------------------------------------------------------------
sub setsOverlap
{
   my ($set, $sets, $N, $cutoff, $sorted) = @_;
   $sorted = defined($sorted) ? $sorted : 0;

   if(not(defined($N)))
   {
      my $union = &setUnion($set, &setsUnionSelf($sets));
      $N = &setSize($union);
   }

   my @overlapping_sets;
   foreach my $set_key (@{&setMembersList($sets)})
   {
      my $set_2 = $$sets{$set_key};

      my ($pval,$ov,$draw,$suc,$pop) = &setOverlap($set, $set_2, $N);

      if(defined($pval) and (not(defined($cutoff)) or $pval < $cutoff))
      {
         push(@overlapping_sets, [$set_key,$pval,$ov,$draw,$suc,$pop]);
      }
   }

   if($sorted)
   {
      @overlapping_sets = sort { $$a[1] <=> $$b[1]; } @overlapping_sets;
   }


   return \@overlapping_sets;
}

##---------------------------------------------------------------------------##
## \%set setsReduce (\%sets sets1, \%sets sets2)
##
## Removes any elements in sets1 that do not exist in any
## set in sets2.  Returns the intersection of
## the unions of sets1 and sets2 (i.e. the set of common
## elements contained in at least one set from both sets1 and sets2.
##---------------------------------------------------------------------------##
sub setsReduce
{
   my ($sets1, $sets2) = @_;

   my $union_sets1   = &setsUnionSelf($sets1);
   my $union_sets2   = &setsUnionSelf($sets2);
   my $intersection = &setIntersection($union_sets1, $union_sets2);

   # Reduce each of the sets.
   foreach my $key_sets1 (@{&setMembersList($sets1)})
      { $$sets1{$key_sets1} = &setIntersection($$sets1{$key_sets1}, $intersection); }

   return $intersection;
}

sub setsReduceBySet
{
   my ($sets1, $set) = @_;

   # Reduce each of the sets.
   my %reduced;

   foreach my $key_sets1 (@{&setMembersList($sets1)})
      { $reduced{$key_sets1} = &setIntersection($$sets1{$key_sets1}, $set); }

   return \%reduced;
}


##---------------------------------------------------------------------------##
## \%set setCombinations (\%set)
##---------------------------------------------------------------------------##
sub setCombinations
{
   my ($set) = @_;

   my @list = keys(%{$set});

   my $combinations_list = &listCombinations(\@list);

   my $combinations = &list2Set($combinations_list);

   return $combinations;
}


##---------------------------------------------------------------------------##
## void setPrint (\%set, \*FILE fp=\*STDOUT, $int print_values=0,
##                $string delim1="\n", $string $delim2="\t")
##---------------------------------------------------------------------------##
sub setPrint
{
   my ($set, $fp, $print_values, $delim1, $delim2) = @_;
   $fp           = not(defined($fp)) ? \*STDOUT : $fp;
   $print_values = not(defined($print_values)) ? 0 : $print_values;
   $delim1       = defined($delim1) ? $delim1 : "\n";
   $delim2       = defined($delim2) ? $delim2 : "\t";

   my @members = keys(%{$set});
   my $n = scalar(@members);
   for(my $i = 0; $i < $n; $i++)
   {
      my $value = $$set{$members[$i]};
      print $fp $members[$i], ($print_values ? ($delim2 . $value) : ""),
                              ($i < $n-1 ? $delim1 : "");
   }
}

##---------------------------------------------------------------------------##
## void setsPrint (\%sets, \*FILE fp=\*STDOUT, $string delim="\t", $int print_values=0)
##---------------------------------------------------------------------------##
sub setsPrint
{
   my ($sets, $fp, $delim, $print_values) = @_;
   $fp           = not(defined($fp)) ? \*STDOUT : $fp;
   $print_values = defined($print_values) ? $print_values : 0;
   $delim        = defined($delim) ? $delim : "\t";

   foreach my $set_key (keys(%{$sets}))
   {
      my $set = $$sets{$set_key};

      foreach my $member (keys(%{$set}))
      {
         print $set_key, $delim, $member,
               ($print_values ? $delim . $$set{$member} : ""), "\n";
      }
   }
}

##---------------------------------------------------------------------------##
## void setsPrintLists (\%\%sets, \*FILE fp=\*STDOUT, $delim="\t", $int invert=0)
##---------------------------------------------------------------------------##
sub setsPrintLists
{
   my ($sets, $fp, $delim, $invert) = @_;
   $delim  = defined($delim)  ? $delim  : "\t";
   $invert = defined($invert) ? $invert : 0;

   if($invert)
   {
      my $union = &setsUnionSelf($sets);
      foreach my $member (keys(%{$union}))
      {
         print $fp $member, $delim, join($delim, @{&setsMemberOf($sets,$member)}), "\n";
      }
   }
   else
   {
      foreach my $set_key (keys(%{$sets}))
      {
         print $fp $set_key, $delim, join($delim, keys(%{$$sets{$set_key}})), "\n";
      }
   }
}

##---------------------------------------------------------------------------##
## void setsPrintMatrix (\%\%sets, \*FILE fp=\*STDOUT, $string delim="\t")
##---------------------------------------------------------------------------##
sub setsPrintMatrix
{
   my ($sets, $fp, $delim) = @_;
   $fp    = not(defined($fp)) ? \*STDOUT : $fp;
   $delim = defined($delim) ? $delim : "\t";

   my $union    = &setsUnionSelf($sets);
   my @set_keys = keys(%{$sets});

   print $fp "Key";
   foreach my $set_key (@set_keys)
   {
      print $fp $delim, $set_key;
   }
   print $fp "\n";

   foreach my $member (keys(%{$union}))
   {
      print $fp $member;
      foreach my $set_key (@set_keys)
      {
         my $in_set = 0;
         if(exists($$sets{$set_key}))
         {
            my $set = $$sets{$set_key};
            $in_set = exists($$set{$member}) ? '1' : '0';
         }
         print $fp $delim, $in_set;
      }
      print $fp "\n";
   }
}

##---------------------------------------------------------------------------##
## setsPrintTable ()
##
## same as setsPrintMatrix()
##---------------------------------------------------------------------------##
sub setsPrintTable
{
   return &setsPrintMatrix(@_);
}

##---------------------------------------------------------------------------##
## void setListsPrint (\%sets, \*FILE fp=\*STDOUT)
##---------------------------------------------------------------------------##
sub setListsPrint
{
   my ($sets, $fp) = @_;
   $fp = not(defined($fp)) ? \*STDOUT : $fp;

   foreach my $set_key (keys(%{$sets}))
   {
      my $list = $$sets{$set_key};
      print $fp "\t$set_key:\n";
      &listPrint($list, $fp);
   }
}

#---------------------------------------------------------------------------
# \%set pairsRead ($string file, $string delim="\t", $int col1=0,
#                  $int col2=1, $int directed=1)
#---------------------------------------------------------------------------
sub pairsRead
{
   my ($file, $delim, $col1, $col2, $directed) = @_;
   $col1     = not(defined($col1)) ? 0 : $col1;
   $col2     = not(defined($col2)) ? 1 : $col2;
   $delim    = not(defined($delim)) ? "\t" : $delim;
   $directed = defined($directed) ? $directed : 1;

   my $max_col = $col1 > $col2 ? $col1 : $col2;

   my %set;

   my $fp;
   open($fp, $file) or die("Could not open file '$file' in pairsRead");
   while(<$fp>)
   {
      my @tuple = split($delim, $_, $max_col + 2);
      chomp($tuple[$#tuple]);
      my ($u,$v) = ($tuple[$col1], $tuple[$col2]);

      $set{$u . $delim . $v} = 1;

      if(not($directed))
      {
         $set{$v . $delim . $u} = 1;
      }
   }
   close($fp);

   return \%set;
}

#---------------------------------------------------------------------------
# \%set setRead ($string file, $string delim="\t", $int col=0,
#                $int headers=0, \%attrib alias=undef)
#---------------------------------------------------------------------------
sub setRead
{
   my ($file, $delim, $col, $headers, $alias) = @_;
   $delim   = not(defined($delim)) ? "\t" : $delim;
   $col     = not(defined($col)) ? 0 : $col;
   $headers = not(defined($headers)) ? 0 : $headers;
   my $fp;
   open($fp, $file) or die("Could not open file '$file' in setRead");
   my %set;
   my $line = 0;
   while(<$fp>)
   {
      $line++;
      if($line > $headers)
      {
         my @tuple = split($delim, $_, $col + 2);
         chomp($tuple[$#tuple]);
         my $member = $tuple[$col];
         if(defined($alias))
         {
            if(exists($$alias{$member}))
            {
               $member = $$alias{$member};
               $set{$member} = 1;
            }

         }
         else
         {
            $set{$member} = 1;
         }
      }
   }
   close($fp);
   return \%set;
}

#---------------------------------------------------------------------------
# \%\@set_lists setListsRead ($string file, $string delim="\t", $int col1=0, $int col2=1
#                             \%attrib alias=undef)
#---------------------------------------------------------------------------
sub setListsRead
{
   my ($file, $delim, $col1, $col2, $alias) = @_;
   $col1  = not(defined($col1)) ? 0 : $col1;
   $col2  = not(defined($col2)) ? 0 : $col2;
   $delim = not(defined($delim)) ? "\t" : $delim;

   my $fp;
   open($fp, $file) or die("Could not open file '$file' in setsRead");
   my %set_lists;
   my $max_col = $col1 > $col2 ? $col1 : $col2;
   while(<$fp>)
   {
      my @tuple = split($delim, $_, $max_col + 2);
      chomp($tuple[$#tuple]);
      my ($member, $set_key) = ($tuple[$col1], $tuple[$col2]);
      if(defined($alias))
      {
         if(exists($$alias{$member}))
         {
            $member = $$alias{$member};
         }
         else
         {
            $member = undef;
         }

      }
      if(defined($member))
      {
         if(not(defined($set_lists{$set_key})))
         {
            my @list;
            $set_lists{$set_key} = \@list;
         }
         my $list = $set_lists{$set_key};
         push(@{$list}, $member);
      }
   }
   close($fp);
   return \%set_lists;
}

#---------------------------------------------------------------------------
# \%\%sets setsReadLists ($string file, $string delim="\t", $int key_col=0,
#                         $headers=0, \%order, $int max=undef, 
#                         $int invert=0)
#
#     \%order - if supplied will get the name of the sets in the order
#               they were read from the file.
#---------------------------------------------------------------------------
sub setsReadLists
{
   my ($file, $delim, $key_col, $headers, $order, $max, $invert) = @_;
   $delim    = not(defined($delim))   ? "\t" : $delim;
   $key_col  = not(defined($key_col)) ?    0 : $key_col;
   $headers  = not(defined($headers)) ?    1 : $headers;
   $invert   = defined($invert) ? $invert : 0;

   my %sets;

   my $fp;

   my $header = &getHeader($file, $headers, $delim, \$fp);

   while(<$fp>)
   {
      my @members = split($delim, $_);
      chomp($members[$#members]);
      my $key = splice(@members, $key_col, 1);

      if(not($invert))
      {
         my %set;
         my $n = defined($max) ? (scalar(@members) > $max ? $max : scalar(@members)) : scalar(@members);
         for(my $i = 0; $i < $n; $i++)
         {
            $set{$members[$i]} = 1;
         }
         $sets{$key} = &setUnion($sets{$key}, \%set);
      }
      else
      {
         my $n = defined($max) ? (scalar(@members) > $max ? $max : scalar(@members)) : scalar(@members);
         for(my $i = 0; $i < $n; $i++)
         {
            my $set_key = $members[$i];
            if(not(defined($sets{$members[$i]})))
            {
               my %set;
               $sets{$members[$i]} = \%set;
            }
            my $set = $sets{$members[$i]};
            $$set{$key} = 1;
         }
      }
   }
   close($fp);
   return \%sets;
}


#---------------------------------------------------------------------------
# \%\%sets setsReadMatrix ($string file, $int mem_val=1, $string delim="\t",
#                         $int key_col=0, $headers=1,
#                         \%set order=undef, \%set selected=undef,
#                         \%attrib alias=undef)
#
#     \%order - if supplied will get the name of the sets in the order
#               they were read from the file
#     \%selected - selects only certain sets (each entry has a set key).
#---------------------------------------------------------------------------
sub setsReadMatrix
{
   my ($file, $mem_val, $delim, $key_col, $headers, $order, $selected, $alias) = @_;
   $mem_val   = not(defined($mem_val))  ?  '1' : $mem_val;
   $delim    = not(defined($delim))   ? "\t" : $delim;
   $key_col  = not(defined($key_col)) ?    0 : $key_col;
   $headers  = not(defined($headers)) ?    1 : $headers;

   my %sets;

   my $fp;

   my $header = &getHeader($file, $headers, $delim, \$fp);

   while(<$fp>)
   {
      my @tuple = split($delim, $_);
      chomp($tuple[$#tuple]);
      my $member = $tuple[$key_col];

      if(defined($alias) and exists($$alias{$member}))
      {
         $member = $$alias{$member};
      }

      for(my $i = 0; $i < scalar(@tuple); $i++)
      {
         if($i != $key_col)
         {
            my $set_key = $$header[$i];
            if(not(defined($selected)) or exists($$selected{$set_key}))
            {
               if(not(exists($sets{$set_key})))
               {
                  my %set;
                  $sets{$set_key} = \%set;
               }

               my $set = $sets{$set_key};

               if($tuple[$i] eq $mem_val)
               {
                  $$set{$member} = $mem_val;
               }
            }
         }
      }
   }

   if(defined($order))
   {
      for(my $i = 1; $i < scalar(@{$header}); $i++)
      {
         my $set_key = $$header[$i];
         $$order{$set_key} = $i;
      }
   }

   return \%sets;
}

#---------------------------------------------------------------------------
# setsReadTable ()
#
# Same as setsReadMatrix()
#---------------------------------------------------------------------------
sub setsReadTable
{
   return &setsReadMatrix(@_);
}

#---------------------------------------------------------------------------
# \%set setReadVec ($string file, $mem_val=1, $string delim="\t",
#                   $int key_col=0, $int set_col=0, $headers=0)
#---------------------------------------------------------------------------
sub setReadVec
{
   my ($file, $mem_val, $delim, $key_col, $set_col, $headers) = @_;
   $mem_val   = not(defined($mem_val)) ? '1' : $mem_val;
   $delim    = not(defined($delim)) ? "\t" : $delim;
   $key_col  = not(defined($key_col)) ? 0 : $key_col;
   $set_col  = not(defined($set_col)) ? 0 : $set_col;
   $headers  = not(defined($headers)) ? 0 : $headers;

   my $fp;
   open($fp, $file) or die("Could not open file '$file' in setReadVec");
   my %set;

   my $max_col = $key_col < $set_col ? $set_col : $key_col;
   while(<$fp>)
   {
      my @tuple = split($delim, $_, $max_col + 2);
      chomp($tuple[$#tuple]);
      my ($member, $in_set) = ($tuple[$key_col], $tuple[$set_col]);

      if($in_set eq $mem_val)
      {
         $set{$member} = 1;
      }
   }

   return \%set;
}

#---------------------------------------------------------------------------
# \%attrib setsJoin (\%\%sets, $int sort_members=0, $string delim="\t")
#---------------------------------------------------------------------------
sub setsJoin
{
   my ($sets, $sort_members, $delim) = @_;
   $sort_members = defined($sort_members) ? $sort_members : 0;
   $delim = defined($delim) ? $delim : "\t";

   my %joined;
   foreach my $set_key (keys(%{$sets}))
   {
      my $set           = $$sets{$set_key};
      my $members       = &setMembersList($set);
      my $members_str   = $sort_members ? join($delim, sort(@{$members})) :
                                          join($delim, @{$members});
      $joined{$set_key} = $members_str;
   }
   return \%joined;
}

#---------------------------------------------------------------------------
# \%\%sets setsRead ($string file, $string delim="\t", $int mem_col=0, $int set_col=1
#                    \%attrib alias=undef, $int bidirectional=0)
#---------------------------------------------------------------------------
sub setsRead
{
   my ($file, $delim, $mem_col, $set_col, $alias, $bidirectional) = @_;
   $delim = not(defined($delim)) ? "\t" : $delim;
   $mem_col  = not(defined($mem_col)) ? 0 : $mem_col;
   $set_col  = not(defined($set_col)) ? 0 : $set_col;
   $bidirectional  = not(defined($bidirectional)) ? 0 : $bidirectional;

   my $fp;
   open($fp, $file) or die("Could not open file '$file' in setsRead");
   my %sets;
   my $max_col = $mem_col > $set_col ? $mem_col : $set_col;
   while(<$fp>)
   {
      my @tuple = split($delim, $_, $max_col + 2);
      chomp($tuple[$#tuple]);
      my ($member, $set_key) = ($tuple[$mem_col], $tuple[$set_col]);
      if(defined($alias))
      {
         if(exists($$alias{$member}))
         {
            $member = $$alias{$member};
         }
         else
         {
            $member = undef;
         }

      }
      if(defined($member) and defined($set_key))
      {
         if(not(defined($sets{$set_key})))
         {
            my %set;
            $sets{$set_key} = \%set;
         }
         my $set = $sets{$set_key};
         $$set{$member} = 1;

         if($bidirectional)
         {
            if(not(defined($sets{$member})))
            {
               my %set;
               $sets{$member} = \%set;
            }
            my $set = $sets{$member};
            $$set{$set_key} = 1;
         }
      }
   }
   close($fp);
   return \%sets;
}

#---------------------------------------------------------------------------
# \%set setReadPairs ($string file, $string delim="\t", $int col1=0,
#                     $int col2=1, \%attrib alias=undef)
#---------------------------------------------------------------------------
sub setReadPairs
{
   my ($file, $delim, $col1, $col2, $alias) = @_;
   $delim = not(defined($delim)) ? "\t" : $delim;
   $col1  = not(defined($col1)) ? 0 : $col1;
   $col2  = not(defined($col2)) ? 1 : $col2;
   my $max_col = ($col1 < $col2) ? $col2 : $col1;
   my $fp;
   open($fp, $file) or die("Could not open file '$file' in setReadPairs");
   my %set;
   while(<$fp>)
   {
      my @tuple = split($delim, $_, $max_col + 2);
      chomp($tuple[$#tuple]);
      my $member1 = $tuple[$col1];
      my $member2 = $tuple[$col2];
      if(defined($alias))
      {
         if(exists($$alias{$member1}) and exists($$alias{$member2}))
         {
            $member1 = $$alias{$member1};
            $member2 = $$alias{$member2};
         }
         else
         {
            $member1 = undef;
            $member2 = undef;
         }

      }

      if(defined($member1) and defined($member2))
      {
         my $one = (($member1 cmp $member2) < 0) ? $member1 : $member2;
         my $two = (($member1 cmp $member2) < 0) ? $member2 : $member1;

         $set{$one . $delim . $two} = 1;
      }
   }
   close($fp);
   return \%set;
}

#---------------------------------------------------------------------------
# \%set setReadTuples ($string file,
#                      $string delim_in="\t", $string delim_out="\t",
#                      \@list cols=undef,
#                      $bool order=0, \%attrib alias=undef)
#---------------------------------------------------------------------------
sub setReadTuples
{
   my ($file, $delim_in, $delim_out, $cols, $order, $alias) = @_;
   my @default_cols = (1);
   $delim_in  = not(defined($delim_in)) ? "\t" : $delim_in;
   $delim_out = not(defined($delim_out)) ? "\t" : $delim_out;
   $cols  = not(defined($cols)) ? \@default_cols : $cols;
   my $max_col = &listMax($cols);
   my $fp;
   open($fp, $file) or die("Could not open file '$file' in setReadPairs");
   my %set;
   # print STDERR "Reading '$file' for tuples. Columns='",
   #              join(",", @{$cols}), "', max column='$max_col', delim_in='$delim_in', delim_out='$delim_out'\n";
   while(<$fp>)
   {
      my @tuple = split($delim_in, $_, $max_col + 2);
      chomp($tuple[$#tuple]);
      my $subtuple = &listSublist(\@tuple, $cols);
      my $all_exist = 1;
      if(defined($alias))
      {
         for(my $i = 0; $i < scalar(@{$subtuple}) and $all_exist; $i++)
         {
            my $member = $$subtuple[$i];
            if(exists($$alias{$member}))
            {
               $$subtuple[$i] = $$alias{$member};
            }
            else
            {
               $all_exist = 0;
            }
         }
      }
      if($all_exist)
      {
         my $entries;
         if($order)
         {
            my @sorted = @{$subtuple};
            @sorted = sort { $a cmp $b; } @sorted;
            $entries = join($delim_out, @sorted);
         }
         else
         {
            $entries = join($delim_out, @{$subtuple});
         }
         $set{$entries} = 1;
      }
   }
   return \%set;
}

#---------------------------------------------------------------------------
# \%set sets2Vectors (\%\%sets, \@set_selection=undef, \@member_selection=undef)
#
# Converts the sets into a set of vectors.  The members are the keys and
# each has a vector of 0's and 1's indicating if the member is in set i
# (where i indexes into @set_selection).
#
# @set_selection - select which sets to include (if undef uses all).
# @member_selection - select which members to use (if undef uses union).
#---------------------------------------------------------------------------
sub sets2Vectors
{
   my ($sets, $set_selection, $member_selection) = @_;

   $set_selection    = defined($set_selection) ? $set_selection : [ keys(%{$sets}) ];
   $member_selection = defined($member_selection) ? $member_selection : [ keys(%{&setsUnionSelf($sets)}) ];

   my %vectors;

   foreach my $member (@{$member_selection})
   {
      my @vector;
      foreach my $set_key (@{$set_selection})
      {
         my $set = $$sets{$set_key};
         push(@vector, exists($$set{$member}));
      }
      $vectors{$member} = \@vector;
   }
   return \%vectors;
}

#---------------------------------------------------------------------------
# \@list sets2List(\%\%sets, $string delim="\t")
#---------------------------------------------------------------------------
sub sets2List
{
   my ($sets, $delim) = @_;
   $delim = defined($delim) ? $delim : "\t";

   my @list;

   if(defined($sets))
   {
      foreach my $set_key (keys(%{$sets}))
      {
         if(exists($$sets{$set_key}))
         {
            my $set = $$sets{$set_key};
            foreach my $member (keys(%{$set}))
            {
               my $pair = $set_key . $delim . $member;
               push(@list, $pair);
            }
         }
      }
   }

   return \@list;
}

#---------------------------------------------------------------------------
# \%set setsGetDistinct(\%\%sets, \@selection)
#---------------------------------------------------------------------------
sub setsGetDistinct
{
   my ($sets, $selection) = @_;

   my %selected_sets;
   foreach my $set_key (@{$selection})
   {
      if(exists($$sets{$set_key}))
      {
         $selected_sets{$set_key} = $$sets{$set_key};
      }
   }
   my $intersection = &setsIntersectionSelf(\%selected_sets);

   my %not_selected_sets;
   foreach my $set_key (keys(%{$sets}))
   {
      my $is_selected = 0;
      for(my $i = 0; $i < scalar(@{$selection}) and not($is_selected); $i++)
      {
         if($$selection[$i] eq $set_key)
         {
            $is_selected = 1;
         }
      }
      if(not($is_selected))
      {
         $not_selected_sets{$set_key} = $$sets{$set_key};
      }
   }
   my $union = &setsUnionSelf(\%not_selected_sets);

   my $difference = &setDifference($intersection, $union);

   return $difference;
}

#---------------------------------------------------------------------------
# \%\%sets setsInvert(\%\%sets, \%selection=undef)
#---------------------------------------------------------------------------
sub setsIntert
{
   my ($sets, $selection) = @_;

   my %inverted;

   foreach my $set_key (keys(%{$sets}))
   {
      if(not(defined($selection)) or $$selection{$set_key})
      {
         my $set = $$sets{$set_key};

         foreach my $member (keys(%{$set}))
         {
            if(not(exists($inverted{$member})))
            {
               my %new_set;
               $inverted{$member} = \%new_set;
            }
            my $inverted = $inverted{$member};
            $$inverted{$member} = $set_key;
         }
      }
   }

   return \%inverted;
}

#---------------------------------------------------------------------------
# $int setsCoMembers(\%\%sets, $string x, $string y)
#---------------------------------------------------------------------------
sub setsCoMembers
{
   my ($sets, $x, $y) = @_;

   my $result = 0;

   if(defined($sets) and defined($x) and defined($y))
   {
      foreach my $set_key (keys(%{$sets}))
      {
         my $set = $$sets{$set_key};

         if(&setExists($set, $x) and &setExists($set, $y))
         {
            $result = 1;
            last;
         }
      }
   }
   return $result;
}

##-----------------------------------------------------------------------------
## \%\@list setListsPaste(\%\@list x, \%\@list y, $string filler=undef)
#
#  $filler - what to fill in when a vector has no data.
#
##-----------------------------------------------------------------------------
sub setListsPaste
{
   my ($x, $y, $filler) = @_;

   my %z;

   if(not(defined($x)))
   {
      %z = %{$y};
   }
   elsif(not(defined($y)))
   {
      %z = %{$x};
   }
   else
   {
      my $n = scalar(@{$$x{splice(@{&setMembers($x)}, 0, 1)}});

      my $m = scalar(@{$$y{splice(@{&setMembers($y)}, 0, 1)}});

      my $y_not_seen = &setMembers($y);

      my @z;

      foreach my $key (keys(%{$x}))
      {
         my @x = $$x{$key};

         if(exists($$y{$key}))
         {
            my @y = $$y{$key};

            @z = (@x, @y);

            delete($$y_not_seen{$key});
         }
         else
         {
            @z = (@x, @{&duplicate($m, $filler)});
         }

         $z{$key} = \@z;
      }

      foreach my $key (keys(%{$y_not_seen}))
      {
         my @y = $$y{$key};

         @z = (@{&duplicate($n, $filler)}, @y);

         $z{$key} = \@z;
      }
   }
   return \%z;
}

sub printSetOfLists
{
   my ($set_of_lists, $filep) = @_;

   $filep = defined($filep) ? $filep : \*STDOUT;

   foreach my $id (keys(%{$set_of_lists}))
   {
      if(exists($$set_of_lists{$id}))
      {
         my $list = $$set_of_lists{$id};

         print $filep $id, "\t", join("\t", @{$list}), "\n";
      }
   }
}

1


