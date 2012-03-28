package UTTest;

use strict;
use warnings;

use Carp;
use Data::Dumper;
use File::Copy;
use Log::Log4perl qw(get_logger);
use MM;
use Modifier;

sub parse_conf
{
    my $file = shift;
    croak unless defined $file;

    my $logger = get_logger('ut_test');

    croak "Error opening $file for reading$!" unless open FILE, '<', $file;

    print "Parsing configuration file $file ... ";
    my $ut = '';
    my %parsed_hash;
    while (my $line = <FILE>)
    {
        chomp $line;

        # This is a comment
        if ($line =~ m/^\s*#/)
        {
            $logger->debug("COMMENT: $line");
        }

        # This is a UT
        elsif ($line =~ m/tst\s*:\s*$/)
        {
            $ut = $line;
            $ut =~ s/^\s*(\S+)\s*:\s*$/$1/;
        }

        # This is a file, which should correspond to a UT
        elsif ($line =~ m/^\s*-\s*\S+\s*$/)
        {
            $logger->fatal('File specified without mentioning unit test case ' .
                "($line)$!") unless defined $ut;

            my $file = $line;
            $file =~ s/^\s*-\s*(\S+)\s*$/$1/;

            my @files;
            if (defined $parsed_hash{$ut})
            {
                @files = @{$parsed_hash{$ut}};
            }
            push @files, $file;
            $parsed_hash{$ut} = \@files;
        }

        # This is just a blank file
        elsif ($line =~ m/^\s*$/)
        {
        }

        # Nothing else is allowed
        else
        {
            $logger->fatal("Problem parsing $file, encountered '$line'$!");
        }
    }
    
    print "DONE\n";
    close $file;
    return \%parsed_hash;
}

sub compile
{
    my $ut = shift;
    croak 'No argument passed' unless defined $ut;

    my $logger = get_logger('ut_test');

    $logger->debug("Compiling $ut");
    print 'Compiling... ';
    my $rc = MM::compile($ut);
    if ($rc != 0)
    {
        print "FAIL\n";
        $logger->debug("Compilation failed with rc = $rc");
        return $rc;
    }
    print "OK\n";
    $logger->debug('Compilation passed');
    return $rc;
}

sub recompile
{
    my $ut = shift;
    croak 'No argument passed' unless defined $ut;

    my $logger = get_logger('ut_test');

    $logger->debug("Recompiling $ut");
    print 'Recompiling... ';
    my $rc = MM::recompile($ut);
    if ($rc != 0)
    {
        print "FAIL\n";
        $logger->debug("Recompilation failed with rc = $rc");
        return $rc;
    }
    print "OK\n";
    $logger->debug('Recompilation passed');
    return $rc;
}

sub check
{
    my $ut = shift;
    croak 'No argument passed' unless defined $ut;

    my $logger = get_logger('ut_test');

    $logger->debug("Checking $ut");
    print 'Checking... ';
    my $rc = MM::check($ut);
    if ($rc != 0)
    {
        print "FAIL\n";
        $logger->debug("Check failed with rc = $rc");
        return $rc;
    }
    print "OK\n";
    $logger->debug('Check passed');
    return $rc;
}

sub recheck
{
    my $ut = shift;
    croak 'No argument passed' unless defined $ut;

    my $logger = get_logger('ut_test');

    $logger->debug("Rechecking $ut");
    print 'Rechecking... ';
    my $rc = MM::recheck($ut);
    if ($rc != 0)
    {
        print "FAIL\n";
        $logger->debug("Recheck failed with rc = $rc");
        return $rc;
    }
    print "OK\n";
    $logger->debug('Recheck passed');
    return $rc;
}

sub get_modifiers
{
    my $logger = get_logger('ut_test');

    my $mod_obj = Modifier->new();
    my @modifiers = $mod_obj->list;
    $logger->debug('List of modifiers detected:');
    $logger->debug(Dumper \@modifiers);

    return \@modifiers;
}

sub test
{
    my $ut = shift;
    my @files = @{(shift)};
    croak 'No argument passed for ut' unless defined $ut;
    croak 'No argument passed for file-list' unless scalar @files != 0;
    my $logger = get_logger('ut_test');

    my @modifiers = @{get_modifiers()};

    foreach my $file (@files)
    {
        # Read file contents into an array
        open FH, '<', $file or $logger->fatal("Error opening $file for " .
            'reading... skipping!');
        my @file_content = <FH>;
        close FH;

        foreach my $modifier (sort {uc($a) cmp uc($b)} @modifiers)
        {
            # Skip if cannot be used
            next unless $modifier->can('modify');

            my $rc = $modifier->modify($file, \@file_content);
            if ($rc == 0)
            {
                $logger->debug('Nothing to modify');
            }
            elsif ($rc > 0)
            {
                $rc = recompile($ut);
                if ($rc == 0)
                {
                    $rc = recheck($ut);
                    if ($rc == 0)
                    {
                        $logger->error("PROBLEM: $ut did't catch this type of bug");
                    }
                }

                # Restore original
                $logger->debug("Restoring original $file");
                open FH, '>', $file or $logger->fatal("Couldn't restore, " .
                    ' please do it manually.');
                print FH @file_content;
                close FH;
            }
        }
    }
}

1;

