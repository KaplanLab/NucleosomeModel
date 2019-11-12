#!/usr/bin/perl

use strict;

my $space = "___SPACE___";
my $semicolon = "___SEMI_COLON___";

#---------------------------------------------------------------------
#
#---------------------------------------------------------------------
sub AddBooleanProperty
{
    my ($property_name, $property) = @_;

    return (length($property) > 0 and $property == 1) ? "$property_name=true " : "$property_name=false ";
}

#---------------------------------------------------------------------
#
#---------------------------------------------------------------------
sub AddStringProperty
{
    my ($property_name, $property) = @_;

    return length($property) > 0 ? "$property_name=$property " : "";
}

#---------------------------------------------------------------------
#
#---------------------------------------------------------------------
sub AddTemplate
{
    my ($template) = @_;

    return "EXE_BASE_DIR/lib/bind.pl $template ";
}

#---------------------------------------------------------------------
#
#---------------------------------------------------------------------
sub RunGenie
{
    my ($exec_str, $print_xml, $xml_file, $output_file, $run_file, $save_xml_file) = @_;

    #print STDERR "$exec_str\n";

    if (length($ENV{"LD_LIBRARY_PATH"}) > 0)
    {
       $ENV{"LD_LIBRARY_PATH"} .= ":EXE_BASE_DIR/lib/";
    }
    else
    {
        $ENV{"LD_LIBRARY_PATH"} .= "EXE_BASE_DIR/lib/";
    }

    my $error_output = ">/dev/null 2>&1";
    if ($ENV{"SEGAL_LAB_DEBUG"} == 1)
    {
       $error_output = "";
    }

    system("$exec_str | sed 's/$space/ /g' | sed 's/$semicolon/;/g' > $xml_file");


    if ($print_xml == 1)
    {
	system("cat $xml_file");
    }
    else
    {
	if (length($run_file) > 0) { `EXE_BASE_DIR/bin/map_learn_static $xml_file >& $run_file`; }
	else { `EXE_BASE_DIR/bin/map_learn_static $xml_file $error_output`; }

	if (length($output_file) > 0)
	{
	    system("cat $output_file");

	    `rm $output_file`;
	}
    }

    if (length($save_xml_file) > 0) { `mv $xml_file $save_xml_file`; }
    else { `rm $xml_file`; }
}
