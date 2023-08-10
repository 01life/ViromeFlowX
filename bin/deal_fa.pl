#version:0.1
use strict;

my $fa = shift;
my $id = shift;

open A,$fa || die $!;
while(<A>){
	chomp;
	if ($_ =~ />(\S+)_length\S+/){
		print ">${id}_$1\n";
	}
	else{
		print "$_\n";
	}
}
close A;
