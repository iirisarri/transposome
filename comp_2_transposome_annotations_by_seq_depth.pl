#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# comp_2_transposome_annotations_by_seq_depth.pl

# Iker Irisarri, University of Konstanz. Mar 2015

# reads summary annotation files from transposome (obtained with != #reads) 
# and prints out the estimated % of the genome for that TE


my $usage = "transposome_annotations_by_seq_depth.pl depth1/t_cluster_report_annotations_summary.tsv depth2/t_cluster_report_annotations_summary.tsv etc. > stdout\n";
my $in0 = $ARGV[0];
my $in1 = $ARGV[1];
#my $in2 = $ARGV[2];
#my $in3 = $ARGV[3];



# get annotation info for each infile
print STDERR "\nget annotations from files...\n";
my $annotations0 = get_annotations( $in0 );
my $annotations1 = get_annotations( $in1 );
#my $annotations2 = get_annotations( $in2 );
#my $annotations3 = get_annotations( $in3 );

my %annotations0 = % { $annotations0 };
my %annotations1 = % { $annotations1 };

#print Dumper $annotations0;

# find intersections between files
print STDERR "\nfind intersections between files...\n\n";

my %all_annotations;

foreach my $ann0 ( keys %annotations0 ) {

    if ( exists $annotations0{$ann0} && exists $annotations1{$ann0} ) {

	$all_annotations{$ann0} = [ $annotations0{$ann0}, $annotations1{$ann0} ];
	next;
	
    }

    elsif ( !exists $annotations1{$ann0} && !exists $annotations1{$ann0} ) {

	$all_annotations{$ann0} = [ $annotations0{$ann0}, "N/A" ];
	next;

    }

    elsif ( !exists $annotations0{$ann0} && exists $annotations1{$ann0} ) {

	$all_annotations{$ann0} = [ "N/A", $annotations1{$ann0} ];
	next;

    }

    else {

	print "something went wrong...\n";

    }

}

#print Dumper \%all_annotations;

# print out table with all the infos

print "#TE_FAM\tGenome% $in0\tGenome% $in1\n";

foreach my $key ( sort keys %all_annotations ) {

    print "$key\t";
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
	#my $superfamily = $cols[1];
	my $family = $cols[2];
	#my ($readCt, $reads_with_hit) = split /\// $cols[3];
	#my $hit_percent = $cols[4];
	my $gm_fract = $cols[5];

	# save in data structure    
	if ( !exists $annotations{$family} ) {

	    $annotations{$family} = $gm_fract;

	} else {

	    next;
	    print STDERR "File: $infile\n";
	    print STDERR  "Family $family already present! Skipping this record...\n";

	}
    }

    return \%annotations;

}
