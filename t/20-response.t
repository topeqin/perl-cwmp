#!/usr/bin/perl
use strict;
use warnings;

my $debug = shift @ARGV;

use Test::More tests => 12;
use Data::Dump qw/dump/;
use Cwd qw/abs_path/;
use File::Slurp;
use blib;

BEGIN {
	use_ok('CWMP::Response');
}

ok(my $abs_path = abs_path($0), "abs_path");
$abs_path =~ s!/[^/]*$!/!;	#!fix-vim

ok( my $response = CWMP::Response->new({ debug => $debug }), 'new' );
isa_ok( $response, 'CWMP::Response' );

sub check_response {
	my $command = shift || die "no command?";

	ok( my $xml = $response->$command({ ID => 42 }), "generate response for $command" );

	my $file = "$abs_path/response/$command.xml";

	if ( ! -e $file ) {
		diag "creating $file";
		write_file( $file, $xml );
	}

	my $template_xml = read_file( $file ) || die "can't read template xml $file: $!";

	is( $xml, $template_xml, "compare $command" );
}

check_response( 'InformResponse' );
check_response( 'GetRPCMethods' );
check_response( 'Reboot' );
check_response( 'GetParameterNames' );
