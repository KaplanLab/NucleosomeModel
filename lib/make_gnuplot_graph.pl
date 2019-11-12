#!/usr/bin/perl

use strict;

require "EXE_BASE_DIR/lib/load_args.pl";

if ($ARGV[0] eq "--help")
{
  print STDOUT <DATA>;
  exit;
}


my $data_file = $ARGV[0];

my %args = load_args(\@ARGV);

my $debug = get_arg("debug", 0, \%args);

my $output_file = get_arg("o", "", \%args);
my $output_format = get_arg("f", "png", \%args);

my $key = get_arg("key", "", \%args);

my $no_key = get_arg("no_key", "", \%args); # supress keys

my $extra_plot_string = get_arg("ep", "", \%args);
my $additional_commands = get_arg("c", "", \%args);
my $data_style = get_arg("ds", "point", \%args);
my $point_size = get_arg("ps", 0.6, \%args);
my $point_size = get_arg("pt", 0.6, \%args);

my $log_scale_x = get_arg("lsx", 0, \%args);
my $log_scale_y = get_arg("lsy", 0, \%args);

my $skiprows = get_arg("skip", 0, \%args);

my $grid_on = get_arg("grid", 0, \%args);
my $gridx_on = get_arg("gridx", 0, \%args);
my $gridy_on = get_arg("gridy", 0, \%args);

my $x_label = get_arg("xl", "", \%args);
my $y_label = get_arg("yl", "", \%args);
my $x2_label = get_arg("x2l", "", \%args);
my $y2_label = get_arg("y2l", "", \%args);

my $x_label_column =  get_arg("xlc", "", \%args);
my $y_label_column =  get_arg("ylc", "", \%args);

my $x_zero = get_arg("xz", "", \%args);
my $y_zero = get_arg("yz", "", \%args);

my $x_range = get_arg("xr", "", \%args);
my $y_range = get_arg("yr", "", \%args);
my $x2_range = get_arg("x2r", "", \%args);
my $y2_range = get_arg("y2r", "", \%args);

my $title = get_arg("t", "", \%args);

my $noborder = get_arg("noborder", 0, \%args);
my $half_border = get_arg("half_border", 0, \%args);

my $make_png = get_arg("png", 0, \%args);
my $make_postscript = get_arg("postscript", 0, \%args);
my $colors   = get_arg("colors", "xffffff x000000 x404040 xff0000 xffa500 x66cdaa xcdb5cd x1ea4ff x0000ff xdda0dd x9500d3", \%args);
my $fontsize = get_arg("fontsize", "small", \%args);
my $font = get_arg("font", "", \%args);
my $image_size = get_arg("image_size", "", \%args);

my $set_ratio = get_arg("ratio", 0, \%args);
my $set_logscale = get_arg("logscale", "", \%args);

my $xtics = get_arg("xtics", "", \%args);
my $ytics = get_arg("ytics", "", \%args);
my $x2tics = get_arg("x2tics", "", \%args);
my $y2tics = get_arg("y2tics", "", \%args);

my $multiplot = get_arg("multiplot", "", \%args);
my $all_columns = get_arg("all", 0, \%args);
my $error_all_columns = get_arg("e_all", 0, \%args);
my $compare_to_last = get_arg("compare_to_last", 0, \%args);

if ($x_label_column ne ""){ $x_label_column=":xtic(".$x_label_column.")" }
if ($y_label_column ne ""){ $y_label_column=":ytic(".$y_label_column.")" }
if ($make_postscript) { $output_format = "postscript eps enhanced color solid"; }

my $r = int(rand(100000));

my $tmp_data_file="tmp_make_gnuplot_graph_data_file.".int(rand(100000000000));
if (length($data_file) < 1 or $data_file =~ /^-/)
{
  open (TMP,">$tmp_data_file");
  while(<STDIN>){
    print TMP $_;
  }
  close(TMP);
  $data_file=$tmp_data_file;
}
else{
  if (!(-e $data_file)) { die "file $data_file does not exist !\n" }
}

my @all_columns_special_cmds;
if($all_columns){
  @all_columns_special_cmds=split /\n/,(`grep '^#' $data_file`),-1;
}

my @x_columns;
my $x_counter = 0;
my $done = 0;
while ($done == 0)
{
    $x_counter++;
    my $x_column = get_arg("x$x_counter", "", \%args);
    if (length($x_column) > 0) { @x_columns[$x_counter - 1] = $x_column; }
    else { $done = 1; }
}

my @y_columns;
my $y_counter = 0;
my $done = 0;
while ($done == 0)
{
    $y_counter++;
    my $y_column = get_arg("y$y_counter", "", \%args);
    if (length($y_column) > 0) { @y_columns[$y_counter - 1] = $y_column; }
    else { $done = 1; }
}

my @error_bar_columns;
my $counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $error_bar_column = get_arg("e$counter", "", \%args);
    if (length($error_bar_column) > 0) { $error_bar_columns[$counter - 1] = $error_bar_column; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @key_data_styles;
my $ds_counter = 0;
my $done = 0;
while ($done == 0)
{
    $ds_counter++;
    my $key_data_style = get_arg("ds$ds_counter", "", \%args);
    if (length($key_data_style) > 0) { $key_data_styles[$ds_counter - 1] = $key_data_style; }
    elsif ($ds_counter >= $x_counter and $ds_counter >= $y_counter) { $done = 1; }
}

my @plot_keys;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $key = get_arg("k$counter", "", \%args);
    if ($key eq "notitle") { $plot_keys[$counter - 1] = "notitle"; }
    elsif (length($key) > 0) { $plot_keys[$counter - 1] = "t '$key'"; }
    if($key eq ""){ $plot_keys[$counter - 1] = "notitle";}
    if ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @keys_params;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $key = get_arg("key$counter", "", \%args);
    if (length($key) > 0) { $keys_params[$counter - 1] = "$key"; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @xtics_array;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $tics = get_arg("xtics$counter", "", \%args);
    if (length($tics) > 0) { $xtics_array[$counter - 1] = $tics; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @ytics_array;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $tics = get_arg("ytics$counter", "", \%args);
    if (length($tics) > 0) { $ytics_array[$counter - 1] = $tics; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @x2tics_array;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $tics = get_arg("x2tics$counter", "", \%args);
    if (length($tics) > 0) { $x2tics_array[$counter - 1] = $tics; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @y2tics_array;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $tics = get_arg("y2tics$counter", "", \%args);
    if (length($tics) > 0) { $y2tics_array[$counter - 1] = $tics; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}



my @x_ranges;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $xrange = get_arg("xr$counter", "", \%args);
    if (length($xrange) > 0) { $x_ranges[$counter - 1] = $xrange; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @y_ranges;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $yrange = get_arg("yr$counter", "", \%args);
    if (length($yrange) > 0) { $y_ranges[$counter - 1] = $yrange; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @x2_ranges;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $x2range = get_arg("x2r$counter", "", \%args);
    if (length($x2range) > 0) { $x2_ranges[$counter - 1] = $x2range; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @y2_ranges;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $y2range = get_arg("y2r$counter", "", \%args);
    if (length($y2range) > 0) { $y2_ranges[$counter - 1] = $y2range; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @axes;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $ax = get_arg("ax$counter", "", \%args);
    if (length($ax) > 0) { $axes[$counter - 1] = $ax; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @positions;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $pos = get_arg("pos$counter", "", \%args);
    if (length($pos) > 0) { $positions[$counter - 1] = $pos; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @sizes;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $size = get_arg("size$counter", "", \%args);
    if (length($size) > 0) { $sizes[$counter - 1] = $size; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @line_types;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $lt = get_arg("lt$counter", "", \%args);
    if (length($lt) > 0) { $line_types[$counter - 1] = $lt; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @point_types;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $pt = get_arg("pt$counter", "", \%args);
    if (length($pt) > 0) { $point_types[$counter - 1] = $pt; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @point_sizes;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $ps = get_arg("ps$counter", "", \%args);
    if (length($ps) > 0) { $point_sizes[$counter - 1] = $ps; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @line_widths;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $lw = get_arg("lw$counter", "", \%args);
    if (length($lw) > 0) { $line_widths[$counter - 1] = $lw; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @fill_styles;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $fs = get_arg("fs$counter", "", \%args);
    if (length($fs) > 0) { $fill_styles[$counter - 1] = $fs; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @smoothes;
$counter = 0;
my $done = 0;
while ($done == 0)
{
    $counter++;
    my $smooth = get_arg("smooth$counter", "", \%args);
    if (length($smooth) > 0) { $smoothes[$counter - 1] = $smooth; }
    elsif ($counter >= $x_counter and $counter >= $y_counter) { $done = 1; }
}

my @data_file_names;
$counter = 1;
$done = 0;
while ($done == 0)
{
    $counter++;
    my $data_file_name = get_arg("d$counter", "", \%args);
    if (length($data_file_name) > 0) { @data_file_names[$counter - 1] = $data_file_name; }
    else { $done = 1; }
}




my @header ;
if($all_columns){
  my $line=`head -n 1 $data_file`;
  chomp $line;
  @header=split/\t/,$line,-1;
  for my $h (1..$#header){
    if ($error_all_columns and $h>=1+$#header/2){
      $error_bar_columns[$h-$#header/2-1]=$h+1;
      $plot_keys[$h-1]="notitle";
      $x_columns[$h-1]=1;
      $y_columns[$h-1]=$h-$#header/2+1;
    }
    else{
      if ($multiplot ne ""){
	$plot_keys[$h-1]="notitle";
      }
      elsif ($no_key ne ""){
	$plot_keys[$h-1]="notitle";
      }
      else{
	$plot_keys[$h-1]="t '".$header[$h]."'";
      }
      $x_columns[$h-1]=1;
      $y_columns[$h-1]=$h+1;
    }
  }
  if ($skiprows<1){$skiprows=1}
}

# color fix for error_all_columns
if ($all_columns and $error_all_columns){
  my @tmp_colors=split/ /,$colors;
  if($multiplot ne ""){
    $colors=$tmp_colors[0]." ".$tmp_colors[1]." ".$tmp_colors[2];
    for my $i (3..$#tmp_colors){
      $colors.=" ".$tmp_colors[$i]." ".$tmp_colors[$i];
    }
  }
  else{
    $colors=$tmp_colors[0]." ".$tmp_colors[1]." ".$tmp_colors[2];
    for my $i (0..scalar(@x_columns)/2-1){
      $colors.=" ".$tmp_colors[$i+3];
    }
    for my $i (0..scalar(@x_columns)/2-1){
      $colors.=" ".$tmp_colors[$i+3];
    }
  }
}

open(OUTFILE, ">tmp_$r");

print OUTFILE "set term $output_format";
if ($make_png == 1)
{ 
   if ($font ne "")
   {
     if ($font eq "1"){ $font="Tahoma.ttf" }
     if ($fontsize eq "small"){ $fontsize=10 }
     print OUTFILE " font \"/storage/appl/gnuplot-4.2.2/share/fonts/$font\" $fontsize ";
   }
   else{
     print OUTFILE " $fontsize ";
   }
   if (length($image_size) > 0)
   {
      print OUTFILE "size $image_size ";
   }
   print OUTFILE "$colors"; 
}

if ($make_postscript == 1) 
{ 
   if (length($image_size) > 0)
   {
      print OUTFILE "\nset size $image_size ";
   }
}

print OUTFILE "\nset datafile separator \",\"\n";
print OUTFILE "\nset output \"$output_file\"\n"; 

if ($noborder)
{
   print OUTFILE "set noborder\n";
}
print OUTFILE "set data style $data_style\n";
print OUTFILE "set pointsize $point_size\n";
#print OUTFILE "set size square\n";
#print OUTFILE "set noborder\n";

if ($log_scale_x) { print OUTFILE "set logscale x\n"; }
if ($log_scale_y) { print OUTFILE "set logscale y\n"; }

if ($grid_on == 1) { print OUTFILE "set grid\n"; }
if ($gridx_on == 1) { print OUTFILE "set grid xtics noytics\n"; }
if ($gridy_on == 1) { print OUTFILE "set grid noxtics ytics\n"; }

if (length($key) > 0) 
{ 
   print OUTFILE "set key $key\n"; 
}
if (length($xtics) > 0) { print OUTFILE "set xtics nomirror $xtics\n"; }
if (length($ytics) > 0) { print OUTFILE "set ytics nomirror $ytics\n"; }
if (length($x2tics) > 0) { print OUTFILE "set x2tics nomirror $2xtics\n"; }
if (length($y2tics) > 0) { print OUTFILE "set y2tics nomirror $y2tics\n"; }

if (length($x_label) > 0) { print OUTFILE "set xlabel \"$x_label\"\n"; }
if (length($y_label) > 0) { print OUTFILE "set ylabel \"$y_label\"\n"; }
if (length($x2_label) > 0) { print OUTFILE "set x2label \"$x2_label\"\n"; }
if (length($y2_label) > 0) { print OUTFILE "set y2label \"$y2_label\"\n"; }

if (length($x_zero) > 0) { print OUTFILE "set xzeroaxis lt " . ($x_zero eq "1" ? "-1" : $x_zero) . "\n"; }
if (length($y_zero) > 0) { print OUTFILE "set yzeroaxis lt " . ($y_zero eq "1" ? "-1" : $y_zero) . "\n"; }

if (length($x_range) > 0) { print OUTFILE "set xrange [$x_range]\nset noautoscale x\n"; }
if (length($y_range) > 0) { print OUTFILE "set yrange [$y_range]\nset noautoscale y\n"; }
if (length($x2_range) > 0) { print OUTFILE "set x2range [$x2_range]\nset noautoscale x\n"; }
if (length($y2_range) > 0) { print OUTFILE "set y2range [$y2_range]\nset noautoscale y\n"; }

if (length($title) > 0) { print OUTFILE "set title \"$title\"\n"; }
if ($multiplot ne "") {
  print OUTFILE "set multiplot";
  if($multiplot ne "1"){
    if($multiplot=~/(layout \d+,\d+)/){print OUTFILE " $1"}
    elsif($all_columns){
      print OUTFILE " layout ",$error_all_columns?scalar(@x_columns)/2:scalar(@x_columns),",1";
    }
    if($multiplot=~/title (.+)/){
      print OUTFILE " title \"$1\"";
    }
  }
  elsif ($all_columns){
    print OUTFILE " layout ",$error_all_columns?scalar(@x_columns)/2:scalar(@x_columns),",1";
  }
  print OUTFILE "\n";
}
if ($set_ratio) { print OUTFILE "set size ratio $set_ratio\n"; }
if ($set_logscale) { print OUTFILE "set logscale $set_logscale\n"; }
if ($half_border) { print OUTFILE "set xtics nomirror\nset ytics nomirror\nset border 3\n"; }

if ($additional_commands ne "") {
  $additional_commands=~s/\\n/\n/g;
  print OUTFILE "$additional_commands\n";
}

my $plot_string = "";

my $temp_deletion_command="rm";

my $num_of_data_points;
if ($all_columns and $error_all_columns and $multiplot ne ""){
    $num_of_data_points = scalar(@x_columns)/2;
}
elsif ($all_columns and $compare_to_last and $multiplot ne "") {
    $num_of_data_points = scalar(@x_columns) - 1;
}
else {
    $num_of_data_points = scalar(@x_columns);
}

for (my $i = 0; $i < $num_of_data_points ; $i++)
{
  if ($multiplot ne "")
  {
    if (length($keys_params[$i]) > 0) { print OUTFILE "set key ".$keys_params[$i]."\n"; }
    if (length($xtics_array[$i]) > 0) { print OUTFILE "set xtics nomirror ".$xtics_array[$i]."\n"; }
    if (length($ytics_array[$i]) > 0) { print OUTFILE "set ytics nomirror ".$ytics_array[$i]."\n"; }
    if (length($x2tics_array[$i]) > 0) { print OUTFILE "set x2tics nomirror ".$x2tics_array[$i]."\n"; }
    if (length($y2tics_array[$i]) > 0) { print OUTFILE "set y2tics nomirror ".$y2tics_array[$i]."\n"; }
    if (length($x_ranges[$i]) > 0) { print OUTFILE "set xrange [".$x_ranges[$i]."]\n"; }
    if (length($y_ranges[$i]) > 0) { print OUTFILE "set yrange [".$y_ranges[$i]."]\n"; }
    if (length($x2_ranges[$i]) > 0) { print OUTFILE "set x2range [".$x2_ranges[$i]."]\n"; }
    if (length($y2_ranges[$i]) > 0) { print OUTFILE "set y2range [".$y2_ranges[$i]."]\n"; }
    if (length($positions[$i]) > 0) { print OUTFILE "set origin ".$positions[$i]."\n"; }
    if (length($sizes[$i]) > 0) { print OUTFILE "set size ".$sizes[$i]."\n"; }
  }

  my $data_file_name = length($data_file_names[$i]) > 0 ? $data_file_names[$i] : $data_file;
   
  my $error_bar = length($error_bar_columns[$i]) > 0 ? ":$error_bar_columns[$i]" : "";
  my $error_bar_plot = length($error_bar_columns[$i]) > 0 ? "w errorbars" : "";

  my $key_data_style = length($key_data_styles[$i]) > 0 ? "w $key_data_styles[$i]" : "";
  my $line_type = length($line_types[$i]) > 0 ? "lt $line_types[$i]" : "";
  my $point_type = length($point_types[$i]) > 0 ? "pt $point_types[$i]" : "";
  my $point_size = length($point_sizes[$i]) > 0 ? "ps $point_sizes[$i]" : "";
  my $line_width = length($line_widths[$i]) > 0 ? "lw $line_widths[$i]" : "";
  my $fill_style = length($fill_styles[$i]) > 0 ? "fs $fill_styles[$i]" : "";
  my $smooth = length($smoothes[$i]) > 0 ? "smooth $smoothes[$i]" : "";
  my $axis = length($axes[$i]) > 0 ? "axes $axes[$i]":"";

  my $temp_data_file = "tmp_".rand(int(10000000));

  system("EXE_BASE_DIR/lib/body.pl ".(1+$skiprows)." -1 $data_file_name | tr \"\t\" \",\" | grep -v '^#' > $temp_data_file");

  if ($multiplot ne "")
  {
    if ($all_columns){
      print OUTFILE  "set title \"".$header[$i+1]."\"\n";
    }
    for my $cmd (@all_columns_special_cmds){
      my @tmp=split /\t/,$cmd,-1;
      if($tmp[$i+1] ne ""){
	$tmp[0]=~/^#(.+)/;
	print OUTFILE "set $1 ",$tmp[$i+1],"\n";
      }
    }
    print OUTFILE  "plot $extra_plot_string \"$temp_data_file\" using $x_columns[$i]:$y_columns[$i]$error_bar$x_label_column$y_label_column $axis $plot_keys[$i] $error_bar_plot $key_data_style $line_type $point_type $point_size $line_width $fill_style $smooth ";
    if($all_columns and $error_all_columns){
      print OUTFILE ", \"$temp_data_file\" using $x_columns[$i]:$y_columns[$i]$x_label_column$y_label_column notitle $axis $key_data_style $line_type $point_type $point_size $line_width $fill_style $smooth";
    }
    if($all_columns and $compare_to_last){
      print OUTFILE ", \"$temp_data_file\" using $x_columns[$i]:$y_columns[scalar(@y_columns)-1] notitle  $key_data_style $line_type $point_type $point_size $line_width $smooth";
    }
    if (length($extra_plot_string) > 0)
    {
      print OUTFILE ",$extra_plot_string";
    }
    print OUTFILE "\n";
  }
  else
  {
    if ($i == 0) { print OUTFILE "plot "; }
    else { print OUTFILE ", "; }

    print OUTFILE  "\"$temp_data_file\" using $x_columns[$i]:$y_columns[$i]$error_bar$x_label_column$y_label_column $axis $plot_keys[$i] $error_bar_plot $key_data_style $line_type $point_type $point_size $line_width $fill_style $smooth";
  }
  $temp_deletion_command.=" $temp_data_file";
  
}
if ($multiplot eq "" and length($extra_plot_string) > 0)
{
  print OUTFILE  ",$extra_plot_string";
}

print OUTFILE "\n";

close(OUTFILE);

if ($make_png or $make_postscript)
{
    system("gnuplot tmp_$r;");
    if ($debug) { system("cat tmp_$r"); }
}
else
{
    system("cat tmp_$r");
}
system($temp_deletion_command);

unlink $tmp_data_file;
unlink "tmp_$r";

__DATA__

EXE_BASE_DIR/lib/make_gnuplot_graph.pl <data file>

   Make a gnuplot graph

   -x1 <num>:       Index of the x column (x-axis). NOTE: 1-based. NOTE: use -x2... to specify more indices to plot
   -y1 <num>:       Index of the y column (y-axis). NOTE: 1-based. NOTE: use -y2... to specify more indices to plot
   -e1 <num>:       Index of the error bar column (y-axis). NOTE: 1-based. NOTE: use -e2... to specify more indices to plot
   -k1 <num>:       Key of the plot (default: printed on the upper right-hand side). NOTE: use -k2... to specify more key names to plot; use "notitle" for no key
   -ds1 <str>:      Data style for the column. NOTE: 1-based. NOTE: use -ds2... to specify more data styles to plot
   -fs1 <str>:      Fill style for the column. NOTE: 1-based. NOTE: use -fs2... to specify more fill styles to plot
   -pos1 <str>:     Position of the first plot (e.g. "screen 0.35,0.14"). NOTE: Use -org2... to specify more positions (default: screen 0,0)
   -size1 <x,y>:    Size of the first plot (e.g. "0.5,0.5"). NOTE: Use -size2... to specify more sizes (default: 1,1).
   -ps1 <num>:      Point size of the first plot. NOTE: Use ps2... to specify point sizes of other plots
   -lt1 <num>:      Line type of the first plot. NOTE: Use lt2... to specify line types of other plots. If none are specified random types will be allocated. 
   -lw1 <num>:      Line width of the first plot. NOTE: Use lw2... to specify line widths of other plots (default: 1).
   -smooth1 <str>:  Type of smoothing to apply to plotted data. Options are: 'unique', 'frequency', 'acsplines', 'csplines', 'bezier' or 'sbezier'. 
   -key <str>:      Global key features: <location> [ samplen <len> ] [ [no]box] [off]
   -key1 <str>:     Features of key to the first plot. NOTE: use -key2... for more plots.

   -ep <str>:       Extra string to plot (e.g., <str> = 'exp(-x)')

   -d2 <str>:       Name of second data file to plot. NOTE: 1-based. NOTE: use -d3... to specify more data files
                                                      NOTE: if not specified, uses the same file for all plots

   -o <file>:       The name of the output file to produce
   -f <name>:       Output format for the output file (default: png)

   -ds <style>:     Data style (boxes/line/point/linespoint/imp default: point)
   -ps <num>:       Point size (default: 0.2)

   -lsx             Log scale for x-axis (obsolete, use -logscale)
   -lsy             Log scale for y-axis (obsolete, use -logscale)

   -xlc <num>       Use column <num> as labels for x-axis (one-based)
   -ylc <num>       Use column <num> as labels for y-axis (one-based)

   -xl <label>      Label for x-axis
   -yl <label>      Label for y-axis
   -x2l <label>     Label for x2-axis
   -y2l <label>     Label for y2-axis

   -xz <str>:       Draw an x-zero axis. Use <str> to define the line width (default: same as border)
   -yz <str>:       Draw an y-zero axis. Use <str> to define the line width (default: same as border)

   -xr <num:num>    global x-axis range (format 'Low:High', e.g., 1:141)
   -yr <num:num>    global y-axis range (format 'Low:High')
   -xr1 <num:num>   x-axis range of first plot. NOTE: use -xr2... to specify x-axis of other plots
   -yr1 <num:num>   y-axis range of first plot. NOTE: use -yr2... to specify y-axis of other plots

   -ax1 <axes>      specify which axes to use (x1y1, x1y2, x2y1 or x2y2). use -ax2 ... to specify axes
                    for other plots.

   -x2r <num:num>   global x2-axis range (format 'Low:High', e.g., 1:141)
   -y2r <num:num>   global y2-axis range (format 'Low:High')
   -x2r1 <num:num>  x2-axis range of first plot. NOTE: use -x2r2... to specify x2-axis of other plots
   -y2r1 <num:num>  y2-axis range of first plot. NOTE: use -y2r2... to specify y2-axis of other plots

   -xtics <num>     Global tics frequency on the x range (or specify autofreq)
   -ytics <num>     Global tics frequency on the y range (or specify autofreq)
   -xtics1 <num>    xtics for the first plot. NOTE: use -xtics2... to specify xtics of more plots
   -ytics1 <num>    ytics for the first plot. NOTE: use -ytics2... to specify ytics of more plots

   -x2tics <num>     Global tics frequency on the x2 range (or specify autofreq)
   -y2tics <num>     Global tics frequency on the y2 range (or specify autofreq)
   -x2tics1 <num>    x2tics for the first plot. NOTE: use -x2tics2... to specify x2tics of more plots
   -y2tics1 <num>    y2tics for the first plot. NOTE: use -y2tics2... to specify y2tics of more plots

   -logscale <axis> Sets the given axis to logscale. axis can be x, y ,x2 ,y2 or any combination (e.g. xyx2)
   
   -c <command>     Additional commands for gnuplot. \n will be made into newline

   -t <title>       Title for the graph (default: no title)

   -multiplot <str> Use multiplot mode (<str> can be left empty or be given layout and title commands).

   -grid:           Sets on grid for the plot
   -gridx:          Sets on grid only for x-axis
   -gridy:          Sets on grid only for y-axis

   -noborder:       Create plots with no border
   -half_border:    Create plots with only left and bottom borders (and tics)

   -png:            Create a png as the output file and not plotting commands
   -postscript:     Create a postscript as the output file

   -colors:         (only for -png) Colors pallete to use. A list of xrrggbb format where the elements are: 
                          background, border, x/y axis, line type 1, line type 2 ...
                    Default pallete is: "xffffff x000000 x404040 xff0000 xffa500 x66cdaa xcdb5cd x1ea4ff x0000ff xdda0dd x9500d3"
   -fontsize:       (only for -png) Fontsize for nonscalable font use tiny/small/medium/large/giant (default small).
                    For scalable font specify a pointsize (default 10).
   -font <str>:     (only for -png) Use a scalable ttf/pfa font (choose from /storage/appl/gnuplot-4.2.2/share/fonts/ , default Tahoma.ttf when -font is used)

   -image_size:     In png mode -- output png size in pixels (not supported on all machines).
                    In postscript mode -- output size of the figure. Font is not affected. Use -image_size 0.8 to increase font by 20%
                    
   -ratio <num>:    Set the ratio of the graph (width / height). Default is 1. Use 0.5 to make image wide, 2 to make it tall etc.
                    
   -skip <num>:     amount of header rows to skip

   -all:            plot all columns: 1st column is x axis, other columns are various y axis data series.
                    first line is assumed to have keys of the y columns.
                    lines (other than first) that start with # will not be plotted. such lines can give
                    column-specific commands in -all multiplot mode, e.g. set a different range for each column.
                    a sample line should look like this: #yrange<tab>[0:3]<tab>[2:4]<tab>[0:2]

   -e_all:          Use with -all to add errorbars to the data series. error value columns should appear
                    by respective order after all y value columns, e.g. [x] [y1]...[y5] [e1]...[e5] .

   -compare_to_last Use with -all and -multiplot in order to add the last column of the data file to every plot in the multiplot
                    and NOT as a seperate plot

   -no_key          Supress printing of keys in a -all plot

   -debug:          Print the resulting commands to STDOUT
   
