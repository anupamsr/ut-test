package Modifier::H;

use File::Copy;
use Log::BasicLogger;
use Time::Local;

sub protected_to_private
{
    my $file_backup = shift;
    my $file   = shift;
    my $log    = shift;
    my $prefix = shift;
    $prefix = '' unless defined $prefix;

    my $temp_ext = '.tmp.' . timelocal(gmtime());
    my $file_new = $file . $temp_ext;
    $log->debug("Temporary file: $file_new", $prefix);

    open $FH_file_backup, '<', $file_backup or $log->error("Couldn't open " .
        'original file for parsing', $prefix);
    open $FH_file_new, '>', $file_new or $log->error("Couldn't open " .
        'temporary file for writing', $prefix);

    # Make changes
    $log->info('Changing "protected" to "private"...', $prefix);
    while (my $line = <$FH_file_backup>)
    {
        chomp ($line);
        if ($line =~ m/protected\s*:.*/)
        {
            $log->debug("OLD: $line");
            $line =~ s/protected/private/;
            $log->debug("NEW: $line");
        }
        print $FH_file_new "$line\n";
    }

    close $FH_file_new;
    close $FH_file_backup;

    # Copy modified file back to original location
    copy($file_new, $file) or $log->error("Couldn't copy modified file " .
        " back modified file back to the original file");
}

1;

