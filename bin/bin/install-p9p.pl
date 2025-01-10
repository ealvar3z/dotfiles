#!/usr/bin/env perl

use v5.40;

my %deps = (
	debian => [qw(gcc libx11-dev libxt-dev libxext-dev lib-fontconfig1-dev)],
	rpm    => [qw(gcc libX11-devel libXt-devel libXext-devel fontconfig-devel)],
	arch   => [qw(gcc libx11 libxt libext fontconfig)],
);

sub main {
	print "Detecting distro...\n";
	my $d = detect_distro();
	unless ($d) {
		die "Error: Unsupported distro (deb, rpm, arch-based "
			. "Arch-based distros only.)\n";
	}
	print "Detected $d-based distro. Installing deps...\n";
	install_deps($d);

	print "Installing p9p...\n";
	install_p9();
	print "Plan9 Port installation completed!\n";
}
	
sub detect_distro {
	open my $fh, '<', '/etc/os-release'
		or die "Error: Cannot open /etc/os-release: $!";
	my $d = '';
	while (my $l = <$fh>) {
		chomp $l;
		if ($l =~ /ID=debian/) { $d = 'debian'; last; }
		if ($l =~ /ID=arch/) { $d = 'arch'; last; }
		if ($l =~ /ID=(fedora|centos|rhel)/) {
			$d = 'rpm';
			last;
		}
	}
	close $fh;
	return $d;
}

sub install_deps($d) {
	my $libs = join ' ', @{$deps{$d}};
	if ($d eq 'debian') {
		system("sudo apt update && sudo apt install -y $libs") == 0
			or die "Error: $!\n";
	} elsif ($d eq 'rpm') {
		system("sudo dnf install -y $libs") == 0
			or die "Error: $!\n";
	} elsif ($d eq 'arch') {
		system("sudo pacman -Syu --no-confirm $libs") == 0
			or die "Error: $!\n";
	} else {
		die "Error: Unsupported distro: $!\n";
	}
}

sub install_p9 {
	my $h = $ENV{HOME};
	my $p9_dir = "$h/plan9";

	if (!-d $p9_dir) {
		system("git clone https://github.com/9fans/plan9port $p9_dir") == 0
			or die "Error: $!\n";
	}

	my $install_dir = "$p9_dir/plan9port";
	system("cd $install_dir && ./INSTALL -r $p9_dir") == 0
		or die "Error: $!\n";
}

main();
