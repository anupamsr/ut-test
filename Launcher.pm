package Launcher;

use strict;
use warnings;

use IPC::Open3 qw(open3);
use Log::Log4perl qw(get_logger);

sub sync
{
    my $cmd = shift;

    my $logger = get_logger("launcher");

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
        $logger->debug("$cmd returned $?");
    }

    my %output;
    $output{STDOUT} = \@out;
    $output{STDERR} = \@err;
    $output{rc}     = $rc;

    return \%output;
}

1;

