#version:0.1
use strict;
use File::Basename;

my $flag = shift;
#my $id = shift;
my $id = basename($flag,".flagstat");

open A,$flag || die $!;
while(<A>){
	chomp;
	if ($_ =~ /(\S+)\s\+\s0\sin\stotal\s\(QC\-passed\sreads\s\+\sQC\-failed\sreads\)/){
		print "$id\t$1\n";
	}

}
