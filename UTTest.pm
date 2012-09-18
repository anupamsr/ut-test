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
    my %files_by;
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
        elsif ($line =~ m/^\s*-\s*\S+/)
        {
            $logger->fatal('File specified without mentioning unit test case ' .
                "($line) $!") unless $ut ne '';

            my $file = $line;
            $file =~ s/^\s*-\s*(\S+)\s*$/$1/;

            my @files;
            if (defined $files_by{$ut})
            {
                @files = @{$files_by{$ut}};
            }
            push @files, $file;
            $files_by{$ut} = \@files;
        }

        # This is just a blank file
        elsif ($line =~ m/^\s*$/)
        {
        }

        # Nothing else is allowed
        else
        {
            $logger->fatal("Problem parsing $file, encountered '$line' $!");
        }
    }
    
    print "DONE\n";
    close $file;
    return \%files_by;
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

1;
