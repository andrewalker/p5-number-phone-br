package Number::Phone::BR;
use Moo;
use Number::Phone::BR::Areas qw/code2name mobile_phone_digits_by_area/;
extends 'Moo::Object', 'Number::Phone';

sub country { 'BR' }
sub country_code { 55 }

has subscriber    => ( is => 'ro' );

has areacode      => ( is => 'ro' );
has areaname      => ( is => 'ro' );

has is_mobile     => ( is => 'ro' );
has is_valid      => ( is => 'ro' );
has is_fixed_line => ( is => 'ro' );

has _original_number => ( is => 'ro' );

sub BUILDARGS {
    my ($class, $number) = @_;
    my ($areacode, $subscriber);

    my %args = ( _original_number => $number );

    my $number_sane = _sanitize_number($number)
      or return \%args;

    $number_sane =~ s{ \( ([0-9]+) \) }{}x;

    if ( $areacode = $1 ) {
        $areacode =~ s/^0//;
        $subscriber = $number_sane;
    }
    else {
        $number_sane =~ s{^0}{};

        $areacode   = substr $number_sane, 0, 2;
        $subscriber = substr $number_sane, 2;
    }

    my $areaname = code2name($areacode)
      or return \%args;

    my $is_mobile     = _validate_mobile( $areacode, $subscriber );
    my $is_fixed_line = $is_mobile ? 0 : _validate_fixed_line( $subscriber );
    my $is_valid      = $is_mobile || $is_fixed_line;

    %args = (%args,
        areacode         => $areacode,
        areaname         => $areaname,
        subscriber       => $subscriber,
        is_mobile        => $is_mobile,
        is_fixed_line    => $is_fixed_line,
        is_valid         => $is_valid,
    ) if $is_valid;

    return \%args;
}

sub BUILD {
    my $self = shift;

    # Breaks compat with Number::Phone
    $self->is_valid
      or die "Not a valid Brazilian phone number: " . $self->_original_number;
}

sub _sanitize_number {
    my $number = shift;

    return '' unless $number;

    my $number_sane = $number;

    # remove stuff we don't need
    $number_sane =~ s{[\- \s]}{}gx;

    # strip country code
    $number_sane =~ s{^\+55}{}gx;

    return '' if $number_sane =~ m|\+|;

    return $number_sane;
}

sub _validate_mobile {
    my ($code, $number) = @_;

    my $digits = mobile_phone_digits_by_area($code);

    my $f = substr $number, 0, 1;

    if ($digits == 9 && $f ne '9') {
        return 0;
    }

    if ($f ne '6' && $f ne '8' && $f ne '9') {
        return 0;
    }

    return $number =~ m|^[0-9]{$digits}$| ? 1 : 0;
}

sub _validate_fixed_line {
    my ($number) = @_;

    return $number =~ m|^[2-5][0-9]{7}$| ? 1 : 0;
}

# TODO: 0800, 0300 ?
sub is_tollfree { }

# TODO: 190, etc
sub is_network_service { }

# XXX: all of these return undef, because I have no idea how to implement them,
# or even if it is possible at all in Brazil.
sub is_allocated { }
sub is_in_use { }
sub is_geographic { }
sub is_pager { }
sub is_ipphone { }
sub is_isdn { }
sub is_specialrate { }
sub is_adult { }
sub is_international { }
sub is_personal { }
sub is_corporate { }
sub is_government { }

1;
