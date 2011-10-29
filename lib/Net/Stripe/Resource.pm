package Net::Stripe::Resource;
use Moose;
use methods;

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;

    # Break out the JSON::XS::Boolean values into 1/0
    for my $field (keys %args) {
        next unless ref($args{$field}) eq 'JSON::XS::Boolean';
        $args{$field} = $args{$field} ? 1 : 0;
    }

    for my $f (qw/card active_card/) {
        next unless $args{$f};
        next unless ref($args{$f}) eq 'HASH';
        $args{$f} = Net::Stripe::Card->new($args{$f});
    }

    $class->$orig(%args);
};

method card_form_fields {
    return unless $self->can('card');
    my $card = $self->card;
    return unless $card;
    return $card->form_fields if ref $card;
    return (card => $card);
}

1;
