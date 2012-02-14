package Launcher;

use strict;
use warnings;

use IPC::Open3 qw(open3);
use Log::BasicLogger;

sub sync
{
    my $cmd = shift;
    my $log = shift;
    my $prefix = shift;

    local (*chld_wrt, *chld_rdr, *chld_err);
    my $pid = open3(*chld_wrt, *chld_rdr, *chld_err, $cmd);

    close(chld_wrt); # Nothing to write

    my @out = <chld_rdr>;
    chomp @out;

    my @err = <chld_err>;
    chomp @err;

    waitpid($pid, 0);
    my $rc = $?;
    if ($rc == 0)
    {
        $log->debug("$cmd returned $?", $prefix);
    }

    my %output;
    $output{STDOUT} = \@out;
    $output{STDERR} = \@err;
    $output{rc}     = $rc;

    return \%output;
}

1;

