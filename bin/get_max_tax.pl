use strict;
use Data::Dumper;

my %hash;
my %all;

while(<>){
	chomp;
	my @a = split /\t/,$_;
	my $tax = $a[1];
	my @b = split /;/,$tax;
	$all{$a[0]} += 1;
	for (my $i=0;$i<=6;$i++){
		if ($b[$i] =~ /__$/){
			next;
		}
		else{
			$hash{$a[0]}{$i}{$b[$i]} += 1;
		}
	}
}

my %level;
foreach my $id (sort keys %all){
	for (my $i=0;$i<=6;$i++){
		foreach my $j (sort keys %{$hash{$id}{$i}}){
			if ($hash{$id}{$i}{$j}/$all{$id}> 0.5){
				$level{$id} .= $j.";";
			}
		}
	}
}

foreach my $k (sort keys %level){
	print "$k\t$level{$k}\n";
}
