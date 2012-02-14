package UTTest;

use strict;
use warnings;

use Carp;
use Data::Dumper;
use Log::BasicLogger;

sub help()
{
    print "Usage: $0 [INPUT_FILE]\n";
    print "\n";
    print "This tool should be run from the buildtop.\n";
    print "\n";
    print 'IMPORTANT: Take a backup before you run this tool. You might ' .
    "lose your changes.\n";
}

sub compile_and_check
{
    my $ut  = shift;
    my $log = shift;
    my $prefix = shift;
    croak unless defined $ut;

    my $rc = MM::compile($ut, $log, $prefix);
    if ($rc != 0)
    {
        $log->debug('Compilation failed', $prefix);
    }
    else
    {
        $log->debug('Compilation passed', $prefix);
        $rc = MM::check($ut, $log, $prefix);
        if ($rc != 0)
        {
            $log->debug('Unit test failed', $prefix);
        }
        else
        {
            $log->debug('Unit test passed', $prefix);
        }
    }
    return $rc;
}

sub parse_input
{
    my $file = shift;
    my $log = shift;
    my $prefix = shift;

    if (-f $file)
    {
        open FILE, '<', $file or croak "Error opening $file for reading$!";
    }
    else
    {
        croak "$file is not a file.";
    }

    $log->info("Parsing input file $file...", $prefix);
    my $ut = '';
    my %parsed_hash;
    while (my $line = <FILE>)
    {
        chomp ($line);
        if ($line =~ m/^\s*#/)
        {
            $log->debug("COMMENT: $line", $prefix);
        }
        elsif ($line =~ m/tst\s*:\s*$/)
        {
            $ut = $line;
            $ut =~ s/:\s*$//;
        }
        elsif ($line =~ m/^\s*-\s*\w+/)
        {
            $log->fatal('File specified without mentioning unit test case ' .
                "($line)$!", $prefix) unless defined $ut;
            my $file = $line;
            $file =~ s/^\s*-\s*//;
            my @files;
            if (defined $parsed_hash{$ut})
            {
                @files = @{$parsed_hash{$ut}};
            }
            push @files, $file;
            $parsed_hash{$ut} = \@files;
        }
        elsif ($line =~ m/^\s*$/)
        {
            $log->debug('Ignoring blank line', $prefix);
        }
        else
        {
            $log->fatal("Problem parsing $file, encountered '$line'$!", $prefix);
        }
    }
    
    close $file;
    return \%parsed_hash;
}

1;

