#!/usr/bin/env perl
# Copyright (c) 2014 The Linux Foundation. All rights reserved.
use strict;
use warnings;
use File::Temp qw/ :POSIX /;
use File::Copy;
use File::Basename;
use Excel::Writer::XLSX;
use Excel::Writer::XLSX::Utility;
use FindBin;
use lib "$FindBin::Bin";
use metadata;

# @CONFIGS
# Each element in CONFIGS contains a hash storing a config file content
my @CONFIGS;

# %QSDKPKGS
# Each element is a package from metadata enabled at least in one of the
# config files specified as an argument
my %QSDKPKGS;

sub load_config($) {
    my $defconfig = shift;
    my $dotconfig = tmpnam();

    # Create a temporary file and extrapolate it with default values
    copy( $defconfig, $dotconfig ) or die "Copy failed: $!";
    system( "./scripts/config/conf "
          . "-D $dotconfig "
          . "-w $dotconfig "
          . "Config.in "
          . "> /dev/null 2>&1" );

    # Load the content in a config hash
    my %config;
    open FILE, "<$dotconfig" or return;
    while (<FILE>) {
        /^CONFIG_DEFAULT_(.+?)=y$/ and push( @{ $config{default} },  $1 );
        /^CONFIG_PACKAGE_(.+?)=y$/ and push( @{ $config{packages} }, $1 );
    }
    close FILE;
    $config{name} = basename( $defconfig, ".config" );

    # Ok; so now we have this:
    # %config = {
    #   packages => [ pkgA, pkgB, pkgC, ...]
    #   default => [ pkgA, pkgC, ...]
    #   name => "configname",
    # };
    # and we want to convert it into this (to process is easily):
    # %hashed_config = [
    #   name => "configname",
    #   pkgA => { default => 1 },
    #   pkgB => {},
    #   pkgC => { default => 1 },
    #   ...
    # ];
    my %hashed_config = ( name => $config{name} );
    foreach my $pkg ( @{ $config{packages} } ) {
        $hashed_config{$pkg} = {};
    }
    foreach my $pkg ( @{ $config{default} } ) {
        $hashed_config{$pkg} = { default => 1 };
    }

    # Store the config hash in @CONFIGS and clean-up the FS
    push( @CONFIGS, \%hashed_config );
    unlink $dotconfig;
}

sub xref_packages() {
    foreach my $config (@CONFIGS) {
        foreach my $pkg ( keys %{$config} ) {

            # Some config options created through "Package/config" still
            # match the CONFIG_PACKAGE_ namespace so we'll ignore them here
            # It's the case for LuCI, as an example
            # (PACKAGE_luci-lib-core_source, PACKAGE_luci-lib-core_compiled...)
            next if !exists( $package{$pkg} );

            $QSDKPKGS{$pkg} = {
                src     => $package{$pkg}->{src},
                name    => $package{$pkg}->{name},
                variant => $package{$pkg}->{variant},

          # Feeds (subdir) is set to an empty string for packages in openwrt.git
                subdir => length( $package{$pkg}->{subdir} )
                ? basename( $package{$pkg}->{subdir} )
                : "openwrt",
                version     => $package{$pkg}->{version},
                description => $package{$pkg}->{description},
                source      => $package{$pkg}->{source},
              }
              unless exists( $QSDKPKGS{$pkg} );

            push( @{ $QSDKPKGS{$pkg}->{configs} },    $config->{name} );
            push( @{ $QSDKPKGS{$pkg}->{defconfigs} }, $config->{name} )
              if ( exists( $config->{$pkg}->{default} ) );
        }
    }
}

sub write_output_xlsx() {

    # Create a new workbook and add a worksheet
    my $workbook  = Excel::Writer::XLSX->new('openwrt.xlsx');
    my $worksheet = $workbook->add_worksheet();

    # Init the worksheet (set columns width, create colors & formats)
    $worksheet->set_column( 0, 1, 28 );    # Column A,B width set to 28
    $worksheet->set_column( 2, 3, 14 );    # Column C,D width set to 14
    $worksheet->set_column( 4, 4, 28 );    # Column E width set to 28
    $worksheet->set_column( 5, 5, 14 );    # Column E width set to 14
    $worksheet->set_column( 6, 6, 12 );    # Column F width set to 12
    my $c_orange = $workbook->set_custom_color( 40, 247,  150, 70 );
    my $c_green = $workbook->set_custom_color(41, 196, 215, 155);
    my $c_red = $workbook->set_custom_color(42, 218, 150, 148);
    my $f_title = $workbook->add_format(
        align  => 'center',
        valign => 'vcenter',
        bold   => 1,
        border => 2,                       # Continuous, Weight=2
        bg_color => $c_orange,
    );
    my $f_data = $workbook->add_format(
        align => 'center',
        valign => 'vcenter',
        border => 1,
    );
    my $f_green_data = $workbook->add_format(
        align => 'center',
        valign => 'vcenter',
        border => 1,
        bg_color => $c_green,
    );
    my $f_red_data = $workbook->add_format(
        align => 'center',
        valign => 'vcenter',
        border => 1,
        bg_color => $c_red,
    );
    my $f_desc = $workbook->add_format(
        align => 'fill',
        border => 1,
    );

    # Fill-in the titles
    my @col = (
        "SRC",     "PACKAGE", "VARIANT", "FEED",
        "TARBALL", "VERSION", "DESCRIPTION"
    );
    my $colid = 0;
    foreach (@col) {
        $worksheet->write( 0, $colid, $col[$colid], $f_title );
        $colid++;
    }
    foreach (sort { $a->{name} cmp $b->{name} } @CONFIGS) {
        $worksheet->write( 0, $colid, $_->{name}, $f_title);
        $worksheet->set_column( $colid, $colid, 20);
        $colid++;
    }

    # Now we're ready. Let's start adding the data
    my $row = 1;
    my $prevpkg, my $start_merge = 0;
    foreach my $cur (
        sort { $QSDKPKGS{$a}->{src} cmp $QSDKPKGS{$b}->{src} }
        keys %QSDKPKGS
      )
    {
        my $col    = 0;
        my $curpkg = $QSDKPKGS{$cur};

        $worksheet->write( $row, $col++, $curpkg->{src},     $f_data );
        $worksheet->write( $row, $col++, $curpkg->{name},    $f_data );
        $worksheet->write( $row, $col++, $curpkg->{variant}, $f_data );
        $worksheet->write( $row, $col++, $curpkg->{subdir},  $f_data );
        $worksheet->write( $row, $col++, $curpkg->{source},  $f_data );
        $worksheet->write_string( $row, $col++, $curpkg->{version}, $f_data )
          unless !exists( $curpkg->{version} );

        $worksheet->write( $row, $col++, $curpkg->{description}, $f_desc );

        my %pkgconfigs = map { $_ => 1 } @{ $curpkg->{configs} };
        foreach my $conf ( sort { $a->{name} cmp $b->{name} } @CONFIGS ) {
            $worksheet->write( $row, $col++, "x", $f_green_data )
              if exists( $pkgconfigs{ $conf->{name} } );
            $worksheet->write_blank( $row, $col++, $f_red_data )
              if !exists( $pkgconfigs{ $conf->{name} } );
        }

        # If the same package defines multiple BuildPackage/KernelPackage,
        # we want to merge the src cells over multiple rows.
        if (    $start_merge == 0
            and exists( $prevpkg->{src} )
            and $curpkg->{src} eq $prevpkg->{src} )
        {
            $start_merge = $row - 1;
        }
        if ( $start_merge != 0 and $curpkg->{src} ne $prevpkg->{src} ) {

            # We want to merge the src, version and feeds columns
            $worksheet->merge_range( $start_merge, 0, $row - 1, 0,
                $prevpkg->{src}, $f_data );
            $worksheet->merge_range( $start_merge, 3, $row - 1, 3,
                $prevpkg->{subdir}, $f_data );
            $worksheet->merge_range( $start_merge, 4, $row - 1, 4,
                $prevpkg->{source}, $f_data );
            $worksheet->merge_range( $start_merge, 5, $row - 1, 5,
                $prevpkg->{version}, $f_data );
            $start_merge = 0;
        }
        $prevpkg = $curpkg;
        $row++;
    }
}

sub parse_command() {
    foreach (@ARGV) {
        load_config($_);
    }
}

parse_command();
parse_package_metadata("tmp/.packageinfo");
xref_packages();
write_output_xlsx();
