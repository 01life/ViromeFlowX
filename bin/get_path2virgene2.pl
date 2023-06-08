use strict;

my $txt = shift;
my $map = shift;

my %hash;
open A,$txt || die $!;
while(<A>){
	chomp;
	my @a = split /\t/,$_;
	$hash{$a[1]} .= $a[0]."__";

}
close A;

open B,"gzip -dc $map |" || die $!;
while(<B>){
	chomp;
	my @b = split /\t/;
	for (my $i=1;$i<=$#b;$i++){
		if (exists $hash{$b[$i]}){
			my @tmp = split /__/,$hash{$b[$i]};
			for (my $j=0;$j<=$#tmp;$j++){
				print "$tmp[$j]\t$b[0]\t$b[$i]\n";
			}
		}
	}
}
close B;
