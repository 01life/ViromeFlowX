use strict;

my $protID2taxid = shift;
my $blastout = shift;

my %hash;
open A,$protID2taxid || die $!;
while(<A>){
	chomp;
	my @a = split;
	$hash{$a[0]} = $a[1];
}
close A;

open B,$blastout || die $!;
while(<B>){
	chomp;
	my @b = split /\t/,$_;
	print "$_\t$hash{$b[1]}\n";
}
close B;
