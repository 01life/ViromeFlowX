use strict;
use Data::Dumper;

my %hash;
while(<>){
	chomp;
	my @a = split /\t/,$_;
	my @b = split /_/,$a[0];
	my $contig = $b[0]."_".$b[1]."_".$b[2];
	$hash{$contig} .= $a[1]."______";
}
#print Dumper (\%hash);

my %tax;
foreach my $contig (sort keys %hash){
	my @t = split /______/,$hash{$contig};
	for (my $i=0;$i<=$#t;$i++){
		if ($t[$i] =~ /f__Myoviridae/){
			$tax{$contig} = "k__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales;f__Myoviridae";
		}
		elsif ($t[$i] =~ /f__Microviridae/){
			$tax{$contig} = "k__Viruses;p__Phixviricota;c__Malgrandaviricetes;o__Petitvirales;f__Microviridae";
		}
		else{
			$tax{$contig} = "k__Viruses;p__Uroviricota;c__Caudoviricetes;o__Caudovirales";
		}
	}
}

foreach my $contig (sort keys %tax){
	print "$contig\t$tax{$contig}\n";
}
