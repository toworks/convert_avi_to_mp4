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


# while (1) {
	my (@files, @dirs, $dir, $dir_old);
	my $count = 0;
	find(\&wanted, $conf->get('find')->{'directory'});
		
	&filter(@files);
		
    print "cycle: ",$conf->get('app')->{'cycle'}, "\n" if $DEBUG;
#    select undef, undef, undef, $conf->get('app')->{'cycle'} || 10;
# }


 sub wanted {
	$dir = $_ if -d $_;
	if ( $dir ne $dir_old ) {
		$dir_old = $dir;
		print $dir, " | ", $dir_old," n \n" if $DEBUG;
		-d $_ and push @dirs, $File::Find::dir;
		-f $_ and push @files, $File::Find::name;
	} else {
		$dir_old = $dir;
		print $dir, " | ", $dir_old, " o \n" if $DEBUG;
		-d $_ and push @dirs,  $File::Find::dir;
		-f $_ and push @files, $File::Find::name;
	}
	$count++;
 };

 sub filter {
 	my(@files) = @_;
	
	print Dumper(@dirs);
	print "\n\n";
	print Dumper(@files);
	print "\n\n";

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

}

sub convert {
	my($file) = @_;
	
	print $file, " |+\n";
#	system("ffmpeg.exe -i $file.".$conf->get('find')->{'ext'}." -vcodec copy ".$file.$conf->get('find')->{'match_ext'});
	#D:\videoimages\ffmpeg>ffmpeg.exe -i D:\videoimages\video\2018\08\20\3503\cam1.avi -vcodec copy  D:\videoimages\video\2018\08\20\3503\cam1.mp4
}

