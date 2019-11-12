#!/usr/bin/perl
use File::Basename;
use strict;

require "EXE_BASE_DIR/lib/load_args.pl";
require "EXE_BASE_DIR/lib/genie_helpers.pl";
require "EXE_BASE_DIR/lib/format_number.pl";

if ($ARGV[0] eq "--help")
{
  print STDOUT <DATA>;
  exit;
}

my %args = load_args(\@ARGV);

my $NUCLEO_LEN = 147;
my $title = get_arg("t", "", \%args);
my $sequence_file = get_arg("s", "", \%args);
my $nucleo_concentration = get_arg("c", "0.1", \%args);
my $temperature = get_arg("temp", "1", \%args);
my $tab = get_arg("tab", "", \%args);
my $gxp = get_arg("gxp", "", \%args);
my $output_prefix = get_arg("p", "$$", \%args);
my $published_version = get_arg("published", 0, \%args);
my $raw_binding = get_arg("raw_binding", 0, \%args);

my @legend = ("Coverage (p>0.2)", "P. Start", "Avg. Occupancy", "Raw Binding (log ratio)");
my @track_colors = ("43,69,255,1", "0,0,0,1", "51,153,255,1", "51,153,255,1");
my @track_styles = ("Filled oval", "Filled box", "Filled box", "Filled box");

my $model_file = "EXE_BASE_DIR/models/nucleosome_model_1208.gxw";

my $gxp_header = "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n<GeneXPress>\n\n<TSCRawData>\nUID\tNAME\tGWEIGHT\tE1\nG2\tG2\t1\t1\n</TSCRawData>\n\n<GeneXPressAttributes>\n<Attributes Id=\"0\">\n<Attribute Name=\"g_module\" Id=\"0\" Value=\"1 2\">\n</Attribute>\n</Attributes>\n</GeneXPressAttributes>\n\n<GeneXPressObjects>\n<Objects Type=\"Genes\" URLPrefix=\"genome-www4.stanford.edu/cgi-bin/SGD/locus.pl?locus=\">\n<Gene Id=\"0\" ORF=\"G2\" Desc=\"G2\">\n<Attributes AttributesGroupId=\"0\" Type=\"Full\" Value=\"1\">\n</Attributes>\n</Gene>\n</Objects>\n<Objects Type=\"Experiments\">\n<Experiment Id=\"0\" name=\"E1\">\n</Experiment>\n</Objects>\n</GeneXPressObjects>\n<TSCHierarchyClusterData NumClusters=\"1\">\n<Root ClusterNum=\"0\" NumChildren=\"0\">\n</Root>\n</TSCHierarchyClusterData>\n";

if (length($title) == 0) {print STDERR "Error: No title was given.\n";  exit 1;}
if (!(-e $model_file)) {print STDERR "Error: Model file $model_file not found.\n"; exit 1;}
if (!(-e $sequence_file)) {print STDERR "Error: Fasta file $sequence_file not found.\n"; exit 1;}
if ($nucleo_concentration < 0) {print STDERR "Error: Nucleosomes concentration can not be negative.\n"; exit 1;}
if ($temperature < 0) {print STDERR "Error: Temperature can not be negative.\n"; exit 1;}
if (!(-e "EXE_BASE_DIR/models/uniform.gxw")) {print STDERR "Error: Model file EXE_BASE_DIR/models/uniform.gxw not found.\n"; exit 1;}

my $specific_params = "";
my $additional_flags = "";
my $post_process = "";

my $basic_cmd = "EXE_BASE_DIR/lib/gxw2stats.pl -m $model_file -n Nucleosome -s tmp_${sequence_file}_$$ -bck EXE_BASE_DIR/models/uniform.gxw -temp $temperature -rsf $nucleo_concentration -norc ";

if ($raw_binding == 1)
{
   $specific_params = "-t WeightMatrixPositions -all -dontSort";
   $post_process = "cut -f 2,4,5 | sort -k 1,1 -k 2,2n";
}
else
{
   $specific_params = "-start_avg -t WeightMatrixAverageOccupancy ";
   $post_process = "EXE_BASE_DIR/lib/body.pl 2 -1 | EXE_BASE_DIR/lib/cut.pl -f 1,2,5 | EXE_BASE_DIR/lib/modify_column.pl -c 2 -p 3";   
}

my $illegal_chars = `EXE_BASE_DIR/lib/fasta2stab.pl $sequence_file | cut -f 2 | EXE_BASE_DIR/lib/to_upper_case.pl | sed 's/[ACGT]//g' | EXE_BASE_DIR/lib/filter.pl -c 0 -ne -q`;
if (length($illegal_chars) > 0)
{
   print STDERR "\nERROR: Illegeal characters found in the input sequence, expecting only A/C/G/T.\n";
   exit 1;
}

print STDERR "Calculating predictions...\n";

system ("EXE_BASE_DIR/lib/fasta2stab.pl $sequence_file | EXE_BASE_DIR/lib/stab2fasta.pl | EXE_BASE_DIR/lib/to_upper_case.pl > tmp_${sequence_file}_$$");

my $pid = $$;

my $pred_cmd = "$basic_cmd $specific_params $additional_flags | $post_process > tmp_output_$pid";

system ("$pred_cmd");

my @r;

if ($tab == 1)
{
   open (OUTPUT_FILE, ">${output_prefix}.tab");
   if ($raw_binding == 1)
   {
      print OUTPUT_FILE "Sequence\tPosition\tRaw Binding (log ratio)\n";
   }
   else
   {
      print OUTPUT_FILE "Sequence\tPosition\tP start\tP occupied\n";
   }
}
else
{
   if ($raw_binding == 1)
   {
      print "Sequence\tPosition\tRaw Binding (log ratio)\n";
   }
   else
   {
      print "Sequence\tPosition\tP start\tP occupied\n";
   }
}

if ($gxp == 1)
{
   if ($raw_binding == 1)
   {
      open (DATA_OUT_FILE, ">tmp_${pid}_3.tab");
   }
   else
   {
      open (DATA_OUT_FILE, ">tmp_${pid}_1.tab");
      open (AVG_OUT_FILE, ">tmp_${pid}_2.tab");
   }
}
my $k = 0;
my $raw_binding_min = 1000;
my $raw_binding_max = -1000;

my @starts;
my $curr_starts_sum = 0;

my $avg;

open (RAW_OUTPUT, "<tmp_output_$pid");
while (<RAW_OUTPUT>)
{
   chop;
   @r = split(/\t/);

   push (@starts, $r[2]);

   $curr_starts_sum += $r[2];
   if ($#starts >= $NUCLEO_LEN)
   {
      $curr_starts_sum -= $starts[0];
      shift (@starts);
   }

   my $data = format_number($r[2], 3);

   if ($data > $raw_binding_max)
   {
      $raw_binding_max = $data;
   }
   if ($data < $raw_binding_min)
   {
      $raw_binding_min = $data;
   }

   $avg = format_number($curr_starts_sum, 3);

   if ($tab == 1)
   {
      if ($raw_binding == 1)
      {
	 print OUTPUT_FILE "$r[0]\t$r[1]\t$data\n";
      }
      else
      {
	 print OUTPUT_FILE "$r[0]\t$r[1]\t$data\t$avg\n";
      }
   }
   else
   {
      if ($raw_binding == 1)
      {
      print "$r[0]\t$r[1]\t$data\n";
      }
      else
      {
	 print "$r[0]\t$r[1]\t$data\t$avg\n";
      }
   }
   if ($gxp == 1)
   {
      if ($raw_binding == 1)
      {
	 print DATA_OUT_FILE "$r[0]\t$k\t$r[1]\t".($r[1]+1)."\t$title: $legend[3]\t$data\n";
      }
      else
      {
	 print DATA_OUT_FILE "$r[0]\t$k\t$r[1]\t".($r[1]+1)."\t$title: $legend[1]\t$data\n";
	 print AVG_OUT_FILE "$r[0]\t$k\t$r[1]\t".($r[1]+1)."\t$title: $legend[2]\t$avg\n";
      }
   } 
   $k++;
}
close RAW_OUTPUT;

if ($tab == 1) 
{
   close OUTPUT_FILE;
}
if ($gxp == 1)
{
   close DATA_OUT_FILE;
   if ($raw_binding != 1)
   {
      close AVG_OUT_FILE;
   }
}

print STDERR "Done.\n";

if ($gxp == 1)
{
   print STDERR "Creating gxp file...\n";

   my @LINES;
   open(FASTA_FILE, "tmp_${sequence_file}_$$") or die("Error: Could not open file $sequence_file.\n");
   my $fasta_file_ref = \*FASTA_FILE;
   
   while (<$fasta_file_ref>) {
      chop;
      push (@LINES, $_);
   }
   close (FASTA_FILE);
   
   open (SEQ_LIST_FILE, ">${output_prefix}.chr") or print STDERR "Error: Failed to open file for writing.\n";
   
   my $curr_seq_name;
   my $curr_seq_len;
   my $n_line = 1;
   foreach my $line (@LINES) 
   {
      if ($line =~ /^>/) 
      {
	 $curr_seq_name = substr($line, index($line, ">")+1);
      } 
      else 
      {
	 if (length($line) < $NUCLEO_LEN) {
	    print STDERR "Error: One of the sequences is too short (".length($line)."bp). Minimum length is $NUCLEO_LEN bp.\n";
	    exit 1; 
	 } 
	 
	 $curr_seq_len = length ($line);
	 print SEQ_LIST_FILE "$curr_seq_name\t$n_line\t0\t$curr_seq_len\tRegion\t1\n";
	 $n_line++;
      }
   }
   close SEQ_LIST_FILE;
   open (GXP_FILE, ">${output_prefix}.gxp");
   print GXP_FILE $gxp_header;
   close GXP_FILE;
   
   system "cat ${output_prefix}.chr | EXE_BASE_DIR/lib/tab2feature_gxt.pl -n 'Sequences' >> ${output_prefix}.gxp";
   
   if ($raw_binding == 1)
   {
      my $track_name = &removeIllegalXMLChars("$title: $legend[3]");
      my $temp_cmd = "EXE_BASE_DIR/lib/tab2feature_gxt.pl tmp_${pid}_3.tab -n '${track_name}' -c '$track_colors[3]'  -lh 50 -minc '\"$raw_binding_min\"' -maxc '$raw_binding_max' -zeroc '0' -l '$track_styles[3]'  >> ${output_prefix}.gxp";
      system $temp_cmd;
      system "rm tmp_${pid}_3.tab";
   }
   else
   {
      open (START_FILE, ">${output_prefix}_start.txt");
      open (RAW_OUTPUT, "<tmp_output_$pid");
      while (<RAW_OUTPUT>) 
      {
	 chop;
	 @r = split (/\t/);
	 
	 if ($r[2] >= 0.2) 
	 {
	    my $nuc_end = $r[1] + $NUCLEO_LEN - 1;
	    print START_FILE "$r[0]\t$r[1]\t$nuc_end\t$title: $legend[0]\t1\n";
	 } 
      }
      close START_FILE;
      close RAW_OUTPUT;

      for (my $j = 2; $j >= 0; $j--) 
      {
	 my $track_name = &removeIllegalXMLChars("$title: $legend[$j]");
	 
	 if ($j == 0) 
	 {
	    system "EXE_BASE_DIR/lib/body.pl 2 -1 ${output_prefix}_start.txt | EXE_BASE_DIR/lib/lin.pl | EXE_BASE_DIR/lib/cut.pl -f 2,1,3- | EXE_BASE_DIR/lib/tab2feature_gxt.pl -n '${track_name}' -c '$track_colors[$j]' -minc '0' -maxc '1'  -lh 30 -l '$track_styles[$j]' >> ${output_prefix}.gxp";
	 } 
	 else 
	 {
	    system "EXE_BASE_DIR/lib/tab2feature_gxt.pl tmp_${pid}_${j}.tab -n '${track_name}' -c '$track_colors[$j]'  -lh 50 -minc '0' -maxc '1' -l '$track_styles[$j]'  >> ${output_prefix}.gxp";
	    
	    system "rm tmp_${pid}_${j}.tab";
	 }
      }
   }
   

   open (GXP_FILE, ">>${output_prefix}.gxp");
   print GXP_FILE "<GeneXPressTable Type=\"ChromosomeTrack\" Name=\"Sequences Track\" TrackNames=\"Sequences\">\n</GeneXPressTable>\n";

   my $track_name;
   if ($raw_binding == 1)
   {
      $track_name = &removeIllegalXMLChars("$title: $legend[3]");
      print GXP_FILE "<ChromosomeDisplay ChromosomeTracks=\"$track_name\" DisplayLeadingTrackLocationNames=\"true\" MaxChromosomePixelWidth=\"800\" ChromosomeFont=\"SansSerif.bold,1,10\" BackgroundColor=\"255,255,255,255\" UserSelectedRegionBorderColor=\"255,0,0,255\" LeftBorderWidth=\"300\" UserSelectedRegionBorderSize=\"2\" HorizontalPaddingColor=\"192,192,192,255\" HorizontalPaddingWidth=\"0\" VerticalPaddingColor=\"192,192,192,255\" VerticalPaddingWidth=\"0\" LeadingTrackLocationNamesHeight=\"200\" LeadingTrackLocationWidth=\"10\" LocationNamesDisplay=\"Description\">\n</ChromosomeDisplay>\n";

   }
   else
   {
      $track_name = &removeIllegalXMLChars("$title: $legend[0]");
   }
   
   print GXP_FILE "<GeneXPressTable Type=\"ChromosomeTrack\" Name=\"$track_name Track\" TrackNames=\"$track_name\">\n</GeneXPressTable>\n<TableDisplay TableDataModel=\"$track_name Track\">\n</TableDisplay>\n";
   print GXP_FILE "\n\n<TableDisplay TableDataModel=\"Sequences Track\">\n</TableDisplay>\n<GeneXPressClusterLists>\n</GeneXPressClusterLists>\n</GeneXPress>\n";   
   close GXP_FILE;

   system "rm ${output_prefix}.chr"; 

   if ($raw_binding != 1)
   {
      system "rm ${output_prefix}_start.txt";
   }
   
   print STDERR "Done.\n";
}

system "rm map.log tmp_${sequence_file}_$$ tmp_output_$pid";

sub removeIllegalXMLChars
{
   my $str = $_[0];
   
   my $res_str = "";
   for (my $i = 0; $i < length($str); $i++) {
      my $char = substr($str, $i, 1);
      if ((ord($char) >= 32 and ord($char) <= 126) or ord($char) == 10 or ord($char) == 9) {
	 $res_str .= $char;
	 }
   }
   
   $res_str =~ s/\&/&amp;/g;
   $res_str =~ s/\"/&quot;/g;
   $res_str =~ s/\'/&apos;/g;
   $res_str =~ s/\</&lt;/g;
   $res_str =~ s/\>/&gt;/g;
   
   return $res_str;
}

__DATA__

kaplan08_nucleosome_prediction.pl 

   Takes a gxw file and a sequence fasta file and finds
   all positions of the matrices above the background

   -raw_binding: Output the raw nucleosome binding log-ratio per basepair instead of the default average occupancy probabilities.

   -t <str>:    Title.
   -s <str>:    Sequence file (fasta format).

   -c <num>:    Nucleosomes concentration (default: 0.1).
   -temp <num>: (Inverse) Temperature scaling (default: 1).

   -p <str>:    Prefix of output files to use (default: the process id).
   -tab:        Produce a tab delimited output file (otherwise, print output to STDOUT).
   -gxp:        Produce a gxp (Genomica project file) output file.




