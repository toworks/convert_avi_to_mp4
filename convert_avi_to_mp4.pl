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
	&find(\&wanted, $conf->get('find')->{'directory'});
		
	&filter(\@files);
		
    print "cycle: ",$conf->get('app')->{'cycle'}, "\n" if $DEBUG;
#    select undef, undef, undef, $conf->get('app')->{'cycle'} || 10;
# }


 sub wanted {
	$dir = $_ if -d $_;
	$dir_old = '.' if ! defined($dir_old);
	if ( $dir ne $dir_old ) {
		$dir_old = $dir;
		#print $dir, " | ", $dir_old," new \n" if $DEBUG;
		-d $_ and push @dirs, $File::Find::dir;
		-f $_ and push @files, $File::Find::name;
	} else {
		$dir_old = $dir;
		#print $dir, " | ", $dir_old, " old \n" if $DEBUG;
		-d $_ and push @dirs,  $File::Find::dir;
		-f $_ and push @files, $File::Find::name;
	}
 };

 sub filter {
 	my($files) = @_;

	my $match = $conf->get('find')->{'match_ext'};

	foreach my $file ( sort { $a cmp $b } @{$files} ) {
		$file =~ /^(.*)\.(.*)$/;
		my $_file = $1;
		my $ext = $2;

		print $file, "\n" if ( $ext eq $conf->get('find')->{'ext'} and ! grep { $_file.$match ~~ /$_/g } @{$files} and $DEBUG);
		&convert($_file) if ( $ext eq $conf->get('find')->{'ext'} and ! grep { $_file.$match ~~ /$_/g } @{$files} );
	}
 }

 sub convert {
	my($file) = @_;
	my $execute = "ffmpeg.exe -i $file.".$conf->get('find')->{'ext'}." -vcodec copy ".$file.$conf->get('find')->{'match_ext'}." 2>nul";
	$log->save("d", $execute) if $DEBUG;
	system("$execute");
 }



