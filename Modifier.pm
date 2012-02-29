package Modifier;

use strict;
use warnings;

use Module::Pluggable search_path => 'Modifier', require => 1, inner => 0;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub list
{
    my $self = shift;
    my @file_types;
    for my $module ( $self->plugins )
    {
        push @file_types, $module;
    }
    return @file_types;
}

1;

