use strict;

my $virus_pfam_list = shift;
my $pfam_out = shift;

my %hash;

open A,$virus_pfam_list || die $!;
while(<A>){
	chomp;
	my @a = split /\t/,$_;
	$hash{$a[0]} = $a[1];
}
close A;

open B,$pfam_out || die $!;
while(<B>){
	chomp;
	my @b = split /\s+/,$_;
	my @pf = split /\./,$b[5];
#	if (exists $hash{$b[5]}){
		print "$b[0]\t$b[5]\t$hash{$pf[0]}\n";
#	}
}
