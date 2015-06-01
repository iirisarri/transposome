#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# comp_4_transposome_annotations_by_seq_depth.pl
# Modification of comp_2_transposome_annotations_by_seq_depth.pl to compare 4 files
# <2 files can also be compared; but warnings will be printed (these can be ignored)

# Iker Irisarri, University of Konstanz. Jun 2015

# reads summary annotation files from transposome (obtained with != #reads) 
# and prints out, for each TE family, the % read hits and estimated % of the genome

my $usage = "transposome_annotations_by_seq_depth.pl depth1/t_cluster_report_annotations_summary.tsv depth2/t_cluster_report_annotations_summary.tsv etc. > stdout\n";
#my $infiles = @ARGV;
my $in0 = $ARGV[0];
my $in1 = $ARGV[1];
my $in2 = $ARGV[2];
my $in3 = $ARGV[3];


# get annotation info for each infile
print STDERR "\nget annotations from files...\n";
# subroutine returns hash of arrays
my $annotations0 = get_annotations( $in0 );
my $annotations1 = get_annotations( $in1 );
my $annotations2 = get_annotations( $in2 );
my $annotations3 = get_annotations( $in3 );

my %annotations0 = % { $annotations0 };
my %annotations1 = % { $annotations1 };
my %annotations2 = % { $annotations2 };
my %annotations3 = % { $annotations3 };

#print Dumper $annotations0;

# find intersections between files
print STDERR "\nfind intersections between files...\n\n";

my %all_annotations;

foreach my $ann0 ( keys %annotations0 ) {

    my $supfam;
    my $fam;
    my $hitperc0;
    my $gmfract0;
    my $hitperc1;
    my $gmfract1;
    my $hitperc2;
    my $gmfract2;
    my $hitperc3;
    my $gmfract3;

    if ( exists $annotations0{$ann0}[1] ) {	
	$supfam = $annotations0{$ann0}[0];
	$fam = $annotations0{$ann0}[1];
	$hitperc0 = $annotations0{$ann0}[2];
	$gmfract0 = $annotations0{$ann0}[3];
    }
    else {
	$hitperc0 = "N/A";
	$gmfract0 = "N/A";
    }
    if ( exists $annotations1{$ann0} ) {
   	$hitperc1 = $annotations1{$ann0}[2];
	$gmfract1 = $annotations1{$ann0}[3];
    }
    else {
	$hitperc1 = "N/A";
	$gmfract1 = "N/A";
    }
    if ( exists $annotations2{$ann0} ) {
   	$hitperc2 = $annotations2{$ann0}[2];
	$gmfract2 = $annotations2{$ann0}[3];
    }
    else {
	$hitperc2 = "N/A";
	$gmfract2 = "N/A";
    }
    if ( exists $annotations3{$ann0} ) {
   	$hitperc3 = $annotations3{$ann0}[2];
	$gmfract3 = $annotations3{$ann0}[3];
    }
    else {
	$hitperc3 = "N/A";
	$gmfract3 = "N/A";
    }

    $all_annotations{$ann0} = [$supfam, $fam, $hitperc0, $gmfract0, $hitperc1, $gmfract1, $hitperc2, $gmfract2, $hitperc3, $gmfract3];

}

#print Dumper \%all_annotations;

# print out table with all the infos

print "#SUPERFAM\tFAM\tHit%\tGm%\tHit%\tGm%\tHit%\tGm%\tHit%\tGm%\n";
print "\t\t\t$in0\t\t$in1\t\t$in2\t\t$in3\n";

foreach my $key ( sort keys %all_annotations ) {

#    print "$key\t";
    print join ("\t",  @{ $all_annotations{$key} } ), "\n";

}


print STDERR "\ndone!\n\n";

# SUBROUTINES

sub get_annotations {
    
    my %annotations = ();

    my $infile = shift;

    open (IN, "<", $infile);
    
    while ( my $line = <IN> ) {
	chomp $line;

	# skip header
	next if ( $line =~ /ReadNum.+/);

	my @cols = split ("\t", $line);
	my $superfamily = $cols[1];
	my $family = $cols[2];
	#my ($readCt, $reads_with_hit) = split /\// $cols[3];
	my $hit_percent = $cols[4];
	my $gm_fract = $cols[5];

	# save in data structure    
	if ( !exists $annotations{$family} ) {

	    $annotations{$family} = [$superfamily, $family, $hit_percent, $gm_fract];

	} else {

	    next;
	    print STDERR "File: $infile\n";
	    print STDERR  "Family $family already present! Skipping this record...\n";

	}
    }

    return \%annotations;

}
