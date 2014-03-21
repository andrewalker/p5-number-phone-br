package Number::Phone::BR::Moo;

use strict;
use warnings;

use Moo ();
use Import::Into;
use base 'Exporter';

my $MooNew;

sub import {
    shift->export_to_level(1);
    Moo->import::into(1);

    $MooNew = caller->can('new');

    return;
}

our @EXPORT = qw/generate_custom_constructor/;

sub generate_custom_constructor {
    my $caller = caller;

    no warnings 'redefine';
    no strict 'refs';
    *{"${caller}::new"} = sub {
        my $class = shift;

        my $obj = $MooNew->($class, $class->BUILDARGS(@_));

        return $obj
          if $obj->is_valid;
    };

    return;
}

1;
