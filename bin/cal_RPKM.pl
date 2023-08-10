use strict;

my $list = shift;
my $count = shift;
my $id = shift;

my %hash;
open A,$list || die $!;
while(<A>){
	chomp;
	my @a = split /\t/,$_;
	$hash{$a[0]} = $a[1];
}
close A;

open B,$count || die $!;
while(<B>){
	chomp;
	my @b = split /\t/,$_;
	my $len = $b[2] - $b[1];
	my $rpkm = $b[4]*1000000000/($hash{$id}*$len);
	print "$_\t$len\t$hash{$id}\t$rpkm\n";
}
