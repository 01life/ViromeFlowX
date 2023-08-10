use strict;

while(<>){
	chomp;
	next if /Sequence_ID/;
	my @a = split /\t/,$_;
	if ($a[3] eq "Unassigned"){
		print "$a[0]\t$a[1]\n";
	}
	else{
		print "$a[0]\t$a[3]\n";
	}
}
