package MM;

use strict;
use warnings;

use Data::Dumper;
use Launcher;
use Log::BasicLogger;

sub compile
{
    my $ut  = shift;
    my $log = shift;
    my $prefix = shift;

    my $cmd = "mm make $ut";
    my %output = %{Launcher::sync($cmd, $log, $prefix)};
    $log->debug(Dumper \%output, $prefix);

    my $rc = $output{rc};
    return $rc;
}

sub check
{
    my $ut  = shift;
    my $log = shift;
    my $prefix = shift;

    my $cmd = "mm check $ut";
    my %output = %{Launcher::sync($cmd, $log, $prefix)};
    $log->debug(Dumper \%output, $prefix);

    my $rc = $output{rc};
    return $rc;
}

1;

