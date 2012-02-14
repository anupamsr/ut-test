package Log::BasicLogger;

use strict;
use warnings;

use Carp;
use Data::Dumper;
use IO::File;
use Term::ANSIColor;
use Time::Local;

sub new
{
    my $class = shift;
    my $config = shift;

    my $path       = $config->{PATH};
    my $level_file = $config->{FILE_LEVEL};
    my $level_scr  = $config->{SCREEN_LEVEL};
    my $append     = $config->{APPEND};
    my $max_err    = $config->{MAX_ERRORS};

    my $self = {};
    $self->{LOG_LEVELS}{DEBUG} = 10;
    $self->{LOG_LEVELS}{INFO}  = 20;
    $self->{LOG_LEVELS}{WARN}  = 30;
    $self->{LOG_LEVELS}{ERROR} = 40;
    $self->{LOG_LEVELS}{FATAL} = 50;
    $self->{SEPERATOR} = ': ';
    $self->{NUM_ERRORS} = 0;
    $self->{MAX_ERRORS} = $max_err;

    if (exists $self->{LOG_LEVELS}{$level_file})
    {
        $self->{FILE_LEVEL} = $self->{LOG_LEVELS}{$level_file};
    }
    else
    {
        $self->{FILE_LEVEL} = 0;
    }

    if (exists $self->{LOG_LEVELS}{$level_scr})
    {
        $self->{SCREEN_LEVEL} = $self->{LOG_LEVELS}{$level_scr};
    }
    else
    {
        $self->{SCREEN_LEVEL} = 0;
    }

    $self->{PATH} = $path;
    local (*HANDLE);
    if ($append == 1)
    {
        open (\*HANDLE, ">>$path");
    }
    else
    {
        open (\*HANDLE, ">$path");
    }
    $self->{FL_HANDLE} = *HANDLE;

    bless $self, $class;
    return $self;
}

sub _log_to_file
{
    my $self = shift;
    my $msg  = shift;
    local (*HANDLE);
    *HANDLE = $self->{FL_HANDLE};
    print HANDLE "$msg\n";
}

sub debug
{
    my $self   = shift;
    my $msg    = shift;
    my $prefix = shift;
    $prefix   = '' unless defined $prefix;
    my $label = 'DEBUG';

    $msg = "$label$self->{SEPERATOR}$msg";
    if ($self->{FILE_LEVEL} <= $self->{LOG_LEVELS}{$label})
    {
        $self->_log_to_file(localtime() . "$self->{SEPERATOR}$msg");
    }
    if ($self->{SCREEN_LEVEL} <= $self->{LOG_LEVELS}{$label})
    {
        print color 'reset';
        print "$prefix$msg\n";
    }
}

sub info
{
    my $self   = shift;
    my $msg    = shift;
    my $prefix = shift;
    $prefix   = '' unless defined $prefix;
    my $label = 'INFO';

    # Info is special - it's behaviour depends on the log level
    if ($self->{FILE_LEVEL} <= $self->{LOG_LEVELS}{$label})
    {
        $self->_log_to_file(localtime() .
            "$self->{SEPERATOR}$label$self->{SEPERATOR}$msg");
    }
    if ($self->{SCREEN_LEVEL} < $self->{LOG_LEVELS}{$label})
    {
        print color 'green';
        print "$prefix$label$self->{SEPERATOR}$msg\n";
        print color 'reset';
    }
    elsif ($self->{SCREEN_LEVEL} == $self->{LOG_LEVELS}{$label})
    {
        print "$prefix$msg\n";
    }
}

sub warn
{
    my $self   = shift;
    my $msg    = shift;
    my $prefix = shift;
    $prefix   = '' unless defined $prefix;
    my $label = 'WARN';

    $msg = "$label$self->{SEPERATOR}$msg";
    if ($self->{FILE_LEVEL} <= $self->{LOG_LEVELS}{$label})
    {
        $self->_log_to_file(localtime() . "$self->{SEPERATOR}$msg");
    }
    if ($self->{SCREEN_LEVEL} <= $self->{LOG_LEVELS}{$label})
    {
        print color 'yellow';
        print "$prefix$msg\n";
        print color 'reset';
    }
    if ($self->{MAX_ERRORS} < 0)
    {
        fatal($self, "warnings are fatal ($self->{max_errors})", $prefix);
    }
}

sub error
{
    my $self   = shift;
    my $msg    = shift;
    my $prefix = shift;
    $prefix   = '' unless defined $prefix;
    my $label = 'ERROR';

    $msg = "$label$self->{SEPERATOR}$msg";
    if ($self->{FILE_LEVEL} <= $self->{LOG_LEVELS}{$label})
    {
        $self->_log_to_file(localtime() . "$self->{SEPERATOR}$msg");
    }
    if ($self->{SCREEN_LEVEL} <= $self->{LOG_LEVELS}{$label})
    {
        print color 'red';
        print "$prefix$msg\n";
        print color 'reset';
    }
    if ($self->{MAX_ERRORS} > 0)
    {
        ++$self->{NUM_ERRORS};
        if ($self->{NUM_ERRORS} >= $self->{MAX_ERRORS})
        {
            fatal($self,
                "Maximum allowed errors encountered ($self->{MAX_ERRORS})",
                $prefix);
        }
    }
}

sub fatal
{
    my $self   = shift;
    my $msg    = shift;
    my $prefix = shift;
    $prefix   = '' unless defined $prefix;
    my $label = 'FATAL';

    $msg = "$label$self->{SEPERATOR}$msg";
    if ($self->{FILE_LEVEL} <= $self->{LOG_LEVELS}{$label})
    {
        $self->_log_to_file(localtime() . "$self->{SEPERATOR}$msg");
    }
    if ($self->{SCREEN_LEVEL} <= $self->{LOG_LEVELS}{$label})
    {
        print color 'bold red';
        print "$prefix$msg\n";
        print color 'reset';
    }
    destroy($self, $msg);
    croak $!;
}


sub destroy
{
    my $self = shift;
    local *HANDLE = $self->{FL_HANDLE};
    close (*HANDLE);
}

1;

