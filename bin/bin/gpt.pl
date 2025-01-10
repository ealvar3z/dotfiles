#!/usr/bin/env perl

use v5.40;

sub have($cmd) {
	return scalar grep { -x "$_/$cmd" } split /:/, $ENV{PATH};
}

sub read_api_key {
	my $key_file = "$ENV{HOME}/.config/gpt/key";
	open my $fh, '<', $key_file
		or die "Error: Can't read or $key_file does not exit: $!\n";
	chomp(my $k = <$fh>);
	close $fh;
	return $k;
}

sub main {
	unless (have("mods")) {
		print "requires charmbracelet/mods\n";
		exit 1;
	}

	$ENV{OPENAPI_API_KEY} = read_api_key();
	my @args = ("mods", "--continue-last", @ARGV);
	exec @args
		or die "Error: Failed to exec commands: $!\n";
}

main();
