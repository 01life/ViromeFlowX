use strict;

my $gene2contig = shift;
my $gene_max = shift;

my %hash;
open A,$gene2contig || die $!;
while(<A>){
	chomp;
	my @a = split;
	$hash{$a[0]} = $a[1];
}
close A;

open B,$gene_max || die $!;
while(<B>){
	chomp;
	my @b = split /\t/,$_;
	print "$_\t$hash{$b[0]}\n";
}
close B;
