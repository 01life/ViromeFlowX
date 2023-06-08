#!/usr/bin/perl

=head1 Name

fishInWinter.pl  -- get out all the fishes which match to the given baits 

=head1 Usage
  
  % fishInWinter.pl <bait_file> <fish_file>
  --bformat <str>     set bait file format, fasta|table|gff|fq
  --fformat <str>     set fish file format, fasta|table|gff|fq
  --bcolumn <num>     set bait file column, default=1
  --fcolumn <num>     set fish file column, default=1
  --except            get things not in the bait file
  --patternmode       change to pattern mode, do not need exact same
  --genemode          change to gene mode, get things belonged to same gene
  --verbose           output running information to screen  
  --help              output help information to screen  

=head1 Exmple

  perl ./fishInWinter.pl -bf table -bc 10 -ff fasta  test-data/wanted.psl test-data/chr2.cds > test-data/chr2.cds.wanted
  perl ./fishInWinter.pl -bf table -bc 10 -ff gff test-data/wanted.psl test-data/chr2.gff > test-data/chr2.gff.wanted

  perl ./fishInWinter.pl -bf table -ff fasta -gene  test-data/needed.list test-data/chr2.cds > test-data/chr2.cds.needed
  perl ./fishInWinter.pl -bf table -ff fasta -gene -except test-data/needed.list test-data/chr2.cds > test-data/chr2.cds.not.needed
  perl ./fishInWinter.pl -bf table -bc 1 -ff table -fc 1 test-data/wanted.psl test-data/all.psl >test-data/exists.psl


=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;

my $BaitSeperator = '\t+'; ## default seperator of bait file
my $FishSeperator = '\s+'; ## default seperator of fish file
my ($Baitformat,$FishFormat,$BaitColumn,$FishColumn,$Except,$PatternMode,$GeneMode);
my ($Verbose,$Help);
GetOptions(
	"bformat:s"=>\$Baitformat,
	"fformat:s"=>\$FishFormat,
	"bcolumn:s"=>\$BaitColumn,
	"fcolumn:s"=>\$FishColumn,
	"except"=>\$Except,
	"patternmode"=>\$PatternMode,
	"genemode"=>\$GeneMode,
	"verbose"=>\$Verbose,
	"help"=>\$Help
);
$BaitColumn ||= 1;
$FishColumn ||= 1;
die `pod2text $0` if (@ARGV < 2 || $Help);

my $bait_file=shift;
my $fish_file=shift;

my %Bait;

if ($Baitformat eq "fasta" || (!$Baitformat && $bait_file=~/\.fa$/)) {
	read_fasta($bait_file,\%Bait,$BaitColumn,$BaitSeperator);
}elsif($Baitformat eq "gff" || (!$Baitformat && $bait_file=~/\.gff$/)) {
	read_gff($bait_file,\%Bait);
}elsif($Baitformat eq "fq" || (!$Baitformat && $bait_file=~/\.fq$/)) {
	read_fq($bait_file,\%Bait,$BaitColumn,$BaitSeperator);
}else{
	read_table($bait_file,\%Bait,$BaitColumn,$BaitSeperator);
}

##print Dumper \%Bait;

print STDERR "read bait done\n" if ($Verbose);

if ($FishFormat eq "fasta" || (!$FishFormat && $fish_file=~/\.fa$/)) {
	output_fasta($fish_file,\%Bait,$FishColumn,$FishSeperator);
}elsif($FishFormat eq "gff" || (!$FishFormat && $fish_file=~/\.gff$/)) {
	output_gff($fish_file,\%Bait);
}elsif($FishFormat eq "fq" || (!$FishFormat && $fish_file=~/\.fq$/)) {
	output_fq($fish_file,\%Bait,$FishColumn,$FishSeperator);
}else{
	output_table($fish_file,\%Bait,$FishColumn,$FishSeperator);
}

print STDERR "Fish out done\n" if ($Verbose);


####################################################
################### Sub Routines ###################
####################################################


sub read_fq{
	my ($file,$bait_hp,$bait_colum,$bait_seperator) = @_;
	open(IN,$file)||die("fail to open $file\n");
	while (<IN>) {
		if (/^\@(\S+)/) {
			my $id = $1;
			<IN>;<IN>;<IN>;
			my @temp=split(/$bait_seperator/,$id);
			$$bait_hp{$temp[$bait_colum-1]}=1;	## the fq file do not has gene mode, in fact
		}
	}
	close(IN);
}

sub read_gff{
	my ($file,$bait_hp) = @_;
	open(IN,$file)||die("fail to open $file\n");
	while (<IN>) {
		chomp;
		s/^\s+//g;
		my @temp=split(/\t/,$_);
		my $id = $2 if($temp[8] =~ /(ID|Parent)=([^;]+);*/);

		if (!$GeneMode) {
			$$bait_hp{$id}=1;
		}else{
			$id = $1 if($id =~ /^(\w+)-\w+$/);
			$$bait_hp{$id} = 1;
		}
		
	}
	close(IN);
	
}


sub read_table{
	my ($file,$bait_hp,$bait_colum,$bait_seperator) = @_;
	open(IN,$file)||die("fail to open $file\n");
	while (<IN>) {
		chomp;
		s/^\s+//g;
		my @temp=split(/$bait_seperator/,$_);
		my $id = $temp[$bait_colum-1];

		if (!$GeneMode) {
			$$bait_hp{$id}=1;
		}else{
			$id = $1 if($id =~ /^(\w+)-\w+$/);
			$$bait_hp{$id} = 1;
			
		}
		
	}
	close(IN);
}


sub read_fasta{
	my ($file,$bait_hp,$bait_colum,$bait_seperator) = @_;
	open(IN,$file)||die("fail to open $file\n");
	$/=">";<IN>;$/="\n";
	while (<IN>) {
		my $title=$_;
		chomp $title;
		$/=">";
		my $seq=<IN>;
		chomp $seq;
		$/="\n";
		my @temp=split(/$bait_seperator/,$title);
		my $id = $temp[$bait_colum-1];

		if (!$GeneMode) {
			$$bait_hp{$id}=1;
		}else{
			$id = $1 if($id =~ /^(\w+)-\w+$/);
			$$bait_hp{$id} = 1;
		}
	}
	close(IN);
}

## do not have gene mode in fq format
sub output_fq{
	my ($file,$fish_hp,$fish_colum,$fish_seperator) = @_;
	open(IN,$file)||die("fail to open $file\n");
	while (<IN>) {
		if (/^\@(\S+)/) {
			my $id = $1;
			my $content = $_;
			$content .= <IN>;
			$content .= <IN>;
			$content .= <IN>;

			my @temp=split(/$fish_seperator/,$id);
			
			if (!$Except) {
				print $content if (!$PatternMode && exists $$fish_hp{$temp[$fish_colum-1]});
				print $content if ($PatternMode && word_pattern_hash($temp[$fish_colum-1],$fish_hp));

			}else{
				print $content if (!$PatternMode && !exists $$fish_hp{$temp[$fish_colum-1]});
				print $content if ($PatternMode && !word_pattern_hash($temp[$fish_colum-1],$fish_hp));
			}

		}
		
	}
	close(IN);
}


sub output_gff{
	my ($file,$fish_hp) = @_;
	open(IN,$file)||die("fail to open $file\n");
	while (<IN>) {
		chomp;
		s/^\s+//g;
		my @temp=split(/\t/,$_);
		my $id = $2 if($temp[8] =~ /(ID|Parent)=([^;]+);*/);
		$id = $1 if($GeneMode && $id =~ /^(\w+)-\w+$/);

		if (!$Except) {
			print $_."\n" if (!$PatternMode && exists $$fish_hp{$id});
			print $_."\n" if ($PatternMode && word_pattern_hash($id,$fish_hp));

		}else{
			print $_."\n" if (!$PatternMode && !exists $$fish_hp{$id});
			print $_."\n" if ($PatternMode && !word_pattern_hash($id,$fish_hp));
		}
		
	}
	close(IN);
}


sub output_table{
	my ($file,$fish_hp,$fish_colum,$fish_seperator) = @_;
	open(IN,$file)||die("fail to open $file\n");
	while (<IN>) {
		chomp;
		s/^\s+//g;
		my @temp=split(/$fish_seperator/,$_);
		my $id = $temp[$fish_colum-1];
		$id = $1 if($GeneMode && $id =~ /^(\w+)-\w+$/);

		if (!$Except) {
			print $_."\n" if (!$PatternMode && exists $$fish_hp{$id});
			print $_."\n" if ($PatternMode && word_pattern_hash($id,$fish_hp));

		}else{
			print $_."\n" if (!$PatternMode && !exists $$fish_hp{$id});
			print $_."\n" if ($PatternMode && !word_pattern_hash($id,$fish_hp));
		}
		
	}
	close(IN);
}


sub output_fasta{
	my ($file,$fish_hp,$fish_colum,$fish_seperator) = @_;
	open(IN,$file)||die("fail to open $file\n");
	$/=">";<IN>;$/="\n";
	while (<IN>) {
		my $title=$_;
		$/=">";
		my $seq=<IN>;
		chomp $seq;
		$/="\n";
		my @temp=split(/$fish_seperator/,$title);
		my $id = $temp[$fish_colum-1];
		$id = $1 if($GeneMode && $id =~ /^(\w+)-\w+$/);
		
		if (!$Except) {
			print ">".$title.$seq if (!$PatternMode && exists $$fish_hp{$id});
			print ">".$title.$seq if ($PatternMode && word_pattern_hash($id,$fish_hp));

		}else{
			print ">".$title.$seq if (!$PatternMode && !exists $$fish_hp{$id});
			print ">".$title.$seq if ($PatternMode && !word_pattern_hash($id,$fish_hp));
		}
	}
	close(IN);
}


sub word_pattern_hash{
	my $word = shift;
	my $hash_p = shift;
	my $value = 0;
	foreach my $hash_key (keys %$hash_p) {
		if ($word =~ /$hash_key/){
			$value = 1;
			last;
		}
	}
	return $value;
}
