package XMM;

use strict;
use warnings;

use Data::Dumper;
use Launcher;
use Log::Log4perl qw(get_logger);

sub compile
{
    my $ut  = shift;

    my $logger = get_logger("mm");

    my $cmd = "xmm make $ut";
    my %output = %{Launcher::sync($cmd, $logger)};
    $logger->debug(Dumper \%output);

    my $rc = $output{rc};
    return $rc;
}

sub recompile
{
    my $ut  = shift;

    my $logger = get_logger("mm");

    my $cmd = "xmm remake $ut";
    my %output = %{Launcher::sync($cmd, $logger)};
    $logger->debug(Dumper \%output);

    my $rc = $output{rc};
    return $rc;
}

sub check
{
    my $ut  = shift;

    my $logger = get_logger("mm");

    my $cmd = "xmm check $ut";
    my %output = %{Launcher::sync($cmd, $logger)};
    $logger->debug(Dumper \%output);

    my $rc = $output{rc};
    return $rc;
}

sub recheck
{
    my $ut  = shift;

    my $logger = get_logger("mm");

    my $cmd = "xmm recheck $ut";
    my %output = %{Launcher::sync($cmd, $logger)};
    $logger->debug(Dumper \%output);

    my $rc = $output{rc};
    return $rc;
}

1;

