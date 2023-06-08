#version:0.1
use strict;
use Data::Dumper;

my %all;
my %cov;
my ($input) = @ARGV;

if ($input =~ /\.gz$/) {
	open IN, "gzip -dc $input |" or die $!;
	} else { 
	open IN, $input or die $!;
}


while(<IN>){
	chomp;
	my @a = split;
	$all{$a[0]} += $a[2]-$a[1];
	if ($a[3] != 0){
		$cov{$a[0]} += $a[2]-$a[1];
	}
}
#print Dumper (\%all);

foreach my $contig (sort keys %all){
	if ($all{$contig} < 5000){
		if ( $cov{$contig}/$all{$contig} >= 0.7){
			print "$contig\t$cov{$contig}\t$all{$contig}\n";
		}
	}
	else{
		if ($cov{$contig} >= 5000){
			print "$contig\t$cov{$contig}\t$all{$contig}\n";
		}
	}
	
}
