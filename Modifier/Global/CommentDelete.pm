package Modifier::Global::CommentThrow;

use Carp;
use Data::Dumper;
use File::Copy;
use Log::Log4perl qw(get_logger);
use Time::Local;

sub examine
{
    $file = shift;
    croak 'No argument passed' unless defined $file;

    my $logger = get_logger('modifier');

    if ($file =~ m/cpp$/)
    {
        $logger->debug("$file detected as CPP");
        return 'cpp';
    }
    elsif ($file =~ m/h$/)
    {
        $logger->debug("$file detected as H");
        return 'h';
    }
}

sub modify
{
    my $self = shift;
    my $file = shift;
    my @file_content = @{(shift)};
    croak 'No argument passed for file' unless defined $file;
    croak 'No argument passed for file_content' unless scalar @file_content !=
    0;
    my $logger = get_logger('modifier');
    my $file_type = examine($file);

    my $file_tmp = $file . '.tmp.' . timelocal(gmtime());
    my $changes_made = -1;
    if ($file_type eq 'cpp')
    {
        open FH, '>', $file_tmp or $logger->fatal('Error writing to the ' .
            'temporary file... skipping');

        $changes_made = 0;

        # Make changes
        $logger->debug("Cannot run $self on $file, currently not supported");
        close FH;
    }

    # Copy temp file back to original location
    if ($changes_made > 0)
    {
        $logger->debug("Copying back changes from $file_tmp to $file");
        copy($file_tmp, $file) or $logger->fatal("Couldn't copy temporary " .
            'file to the original location... skipping');
    }
    return $changes_made;
}

1;

