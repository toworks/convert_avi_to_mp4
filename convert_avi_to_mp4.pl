#!/usr/bin/perl

 use strict;
 use warnings;
 no warnings 'experimental::smartmatch';
 use lib 'libs';
 use logging;
 use configuration;
 use File::Find;
 use Data::Dumper;

 
 $| = 1;  # make unbuffered

 my $log = LOG->new();
 my $conf = configuration->new($log);

 my $DEBUG = $conf->get('app')->{'debug'};
 

my $dir = $conf->get('find')->{'directory'};

#print Dumper($conf);
print $conf->get('find')->{'ext'};

find(\&wanted, $dir);

my (@files, @dirs, %_files);
my $d;
my $dold;
my $count = 0;

sub wanted {
			$d = $_ if -d $_;
			if ( $d ne $dold ) {
				$dold = $d;
				print $d, " | ", $dold," n \n";
				-d $_ and push @dirs, $File::Find::dir;
				-f $_ and push @files, $File::Find::name;
#				$_files{$count}{'dir'} = $File::Find::dir if -d $_;
			} else {
				$dold = $d;
				print $d, " | ", $dold, " o \n";
				-d $_ and push @dirs,  $File::Find::dir;
				-f $_ and push @files, $File::Find::name;
				#-f $_ and push @files, $File::Find::name =~ /(.*)\/(.*)$/;
#				$_files{$count}{'dir'} = $File::Find::dir if -d $_;
#				$File::Find::name =~ /(.*)\/(.*)\.(.*)$/ if -f $_;
#				$_files{$count}{'dir'} = "$1/";
#				$_files{$count}{'file'} = $2;
#				$_files{$count}{'ext'} = $3;
#				print $_files{$count}{'file'}, " | \n";
#				-f $_ and $_files{'file'} = $File::Find::name =~ /(.*)\/(.*)$/;
#				-f $_ and $_files{'ext'} = $File::Find::name =~ /(.*)\/(.*).(.*)$/;
			}
			$count++;
#			print $d," n \n" if defined $d;
#			print $dold, " o \n"; # if defined $dold and $dold eq 1;
#            -f $_ and push @files, $File::Find::name;
#            -f $_ and push @files, $File::Find::name;
#            -d $_ and push @dirs,  $File::Find::name;
};

print Dumper(@dirs);
print "\n\n";
print Dumper(@files);
print "\n\n";
print Dumper(\%_files);


my $match = $conf->get('find')->{'match_ext'};



#=comm
foreach my $file ( sort { $a cmp $b } @files ) {
#if (my ($matched) = grep $_ =~ /$match/, @files) {
#	print $file, "\n";
	$file =~ /^(.*)\.(.*)$/;
	my $_file = $1;
	my $ext = $2;
#	print my $ext = $2, "\n";
#	if ( grep $file =~ /\.txt/ and ! $_ =~ /$match/, @files) {
#		print $file, " |\n";
#	}
	#print $file, " |\n" if ($ext eq 'txt' and grep { $_file.$match ne $_ } @files );
	
	#print $file, " |\n" if ( $ext eq 'txt' and ! grep { $_file.$match ~~ /$_/g } @files );
	&convert($_file) if ( $ext eq $conf->get('find')->{'ext'} and ! grep { $_file.$match ~~ /$_/g } @files );

	#print $_file, " |+\n" if ( $file ne $_file.$match );
#	print $_file.$match."\n";
}


sub convert {
	my($file) = @_;
	
	print $file, " |+\n";
	#system("ffmpeg.exe", "-i $file.avi", "-vcodec copy $file.mp4");
	#D:\videoimages\ffmpeg>ffmpeg.exe -i D:\videoimages\video\2018\08\20\3503\cam1.avi -vcodec copy  D:\videoimages\video\2018\08\20\3503\cam1.mp4
}

