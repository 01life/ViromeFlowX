use strict;

my %hash;
while(<>){
	chomp;
	my @a = split;
	$hash{$a[0]} .= $a[1]." ";
}

foreach my $contig (sort keys %hash){
	print "$contig\t$hash{$contig}\n";
}
