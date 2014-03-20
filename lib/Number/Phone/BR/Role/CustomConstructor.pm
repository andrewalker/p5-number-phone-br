package Number::Phone::BR::Role::CustomConstructor;
use Moo::Role;

around new => sub {
    my $orig = shift;
    my $class = shift;

    # NOTE [1]:
    # This is necessary because otherwise an infinite recursion happens.
    # Number::Phone->new() would call Number::Phone::BR->new() and vice-versa.
    # So we just bless BUILDARGS' return and skip the Moo generated 'new'
    # method altogether.
    # NOTE [2]:
    # If the number is invalid, BUILDARGS will return {}. In that case,
    # Number::Phone requires the constructor to return undef.
    my $args = $class->BUILDARGS(@_);
    return keys %$args ? bless $args, $class : undef;
};

1;
