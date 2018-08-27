#!/usr/bin/perl

use strict;
use warnings;
no warnings 'experimental::smartmatch';
use Data::Dumper;
use DirHandle;


my $dir = "d:/00/";




use File::Find;

#$dir = shift || '.';

my (@files, @dirs, %_files);
my $d;
my $dold;
my $count = 0;
find( sub{
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
}, $dir );

print Dumper(@dirs);
print "\n\n";
print Dumper(@files);
print "\n\n";
print Dumper(\%_files);


my $match = '.pl';



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
	
	print $file, " |\n" if ( $ext eq 'txt' and ! grep { $_file.$match ~~ /$_/g } @files );

	#print $_file, " |+\n" if ( $file ne $_file.$match );
#	print $_file.$match."\n";
}
#=cut
=comm
foreach my $num ( sort { $a cmp $b } keys %_files ) {
#	print $_files{$num}{'dir'}, "\n";
	if (	$_files{$num}{'dir'}.$_files{$num}{'file'}.'.'.$_files{$num}{'ext'} ne $match and
			grep { $_files{$num}{'dir'}.$_files{$num}{'file'}.'.'.$_files{$num}{'ext'} ne $_files{$_}{'dir'}.$_files{$_}{'file'}.'.'.$_files{$_}{'ext'} and
				#$_files{$_}{'dir'}.$_files{$_}{'file'} and
				$_files{$num}{'ext'} ne "txt"
				#$_files{$_}{'file'}.".".$_files{$_}{'ext'} ne $_files{$num}{'file'}.".".$match
				#$_files{$num}{'dir'}.$_files{$num}{'file'} eq $_files{$_}{'dir'}.$_files{$_}{'file'} and
				#$_files{$_}{'dir'}.$_files{$_}{'file'}.".".$_files{$_}{'ext'} ne $_files{$num}{'dir'}.$_files{$num}{'file'}.".".$match
				#$_files{$num}{'ext'} ne "pl"
				#and
				#$_files{$_}{'dir'}.$_files{$_}{'file'}.".".$_files{$_}{'ext'} !~ /$match/
				#$_files{$_}{'ext'} ne $match
		} keys %_files)
	{
#		print $_files{$num}{'dir'}.$_files{$num}{'file'}.".".$match, " |\n";
#		print $_files{$num}{'dir'}.$_files{$num}{'file'}.".".$_files{$num}{'ext'}, " ||\n";
		print $_files{$num}{'dir'}, $_files{$num}{'file'}, ".", $_files{$num}{'ext'}, " - files \n";
	}
}
=cut
exit;


serve_path($dir);


sub serve_path {
    my($dir) = @_;

    if (-f $dir) {
        return serve_path($dir);
    }

    my @files;# = ([ "../", "Parent Directory", '', '', '' ]);
    my $dh = DirHandle->new($dir);
    my @children;
    while (defined(my $ent = $dh->read)) {
        next if $ent eq '.' or $ent eq '..';
        push @children, $ent;
		print $ent;
    }

    for my $basename (sort { $a cmp $b } @children) {
        my $file = "$dir/$basename";
#        my $url = $dir_url . $basename;
        my $url = $basename;

        my $is_dir = -d $file;
        my @stat = stat _;

#        $url = join '/', map {uri_escape($_)} split m{/}, $url;

        if ($is_dir) {
            $basename .= "/";
            $url      .= "/";
			serve_path($dir.$is_dir);
        }

=comm
        my $mm = new File::MMagic;
        Plack::MIME->add_type( ".7z" => "application/x-7zip",
                               ".txz" => "application/x-xz",
                               ".mkv" => "video/x-matroska",
                               ".ac3" => "audio/ac3",
                              );

        my $mime_type = $is_dir ? 'directory' : ( Plack::MIME->mime_type($file) || 'text/plain' );
#        my $mime_type = $is_dir ? 'directory' : ( $mm->checktype_filename($file) || 'text/plain' );

        if ( ! grep { "$basename" ~~ /(^\.)|($_)\//g } @{$self->{denied}} ) {
            $basename = decode_utf8($basename) if ! utf8::is_utf8($basename);
            push @files, [ $url, $basename, $self->get_size($stat[7], $basename), $mime_type, strftime("%Y-%m-%d %H:%M:%S", localtime $stat[9]) ];
        }
=cut
    }

#    my $page = $self->prepare_files($env, @files);

	print Dumper(@files);
	return @files;
#    return [ 200, ['Content-Type' => 'text/html; charset=utf8'], [ $page ] ];
}




