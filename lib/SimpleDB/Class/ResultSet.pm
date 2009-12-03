package SimpleDB::Class::ResultSet;
our $VERSION = '0.0001';



=head1 NAME

SimpleDB::Class::ResultSet - An iterator of items from a domain.

=head1 VERSION

version 0.0001

=head1 DESCRIPTION

This class is an iterator to walk to the items passed back from a query. 

=head1 METHODS

The following methods are available from this class.

=cut

use Moose;
use SimpleDB::Class::SQL;

#--------------------------------------------------------

=head2 new ( params )

Constructor.

=head3 params

A hash.

=head4 domain

Required. A L<SimpleDB::Class::Domain> object.

=head4 result

A result as returned from the send_request() method from L<SimpleDB::Class>. Either this or a where is required.

=head4 where

A where clause as defined in L<SimpleDB::Class::SQL>. Either this or a result is required.

=cut

#--------------------------------------------------------

=head2 where ( )

Returns the where passed into the constructor.

=cut

has where => (
    is          => 'ro',
    isa         => 'HashRef',
);

#--------------------------------------------------------

=head2 domain ( )

Returns the domain passed into the constructor.

=cut

has domain => (
    is          => 'ro',
    required    => 1,
);

#--------------------------------------------------------

=head2 result ( )

Returns the result passed into the constructor, or the one generated by fetch_result() if a where is passed into the constructor.

=head2 has_result () 

A boolean indicating whether a result was passed into the constructor, or generated by fetch_result().

=cut

has result => (
    is          => 'rw',
    isa         => 'HashRef',
    predicate   => 'has_result',
    default     => sub {{}},
    lazy        => 1,
);

#--------------------------------------------------------

=head2 iterator ( )

Returns an integer which represents the current position in the result set as traversed by next().

=cut

has iterator => (
    is          => 'rw',
    default     => 0,
);


#--------------------------------------------------------

=head2 fetch_result ( )

Fetches a result, based on a where clause passed into a constructor, and then makes it accessible via the result() method.

=cut

sub fetch_result {
    my ($self) = @_;
    my $select = SimpleDB::Class::SQL->new(
        domain      => $self->domain,
        where       => $self->where,
    );
    my %params = (SelectExpression => $select->to_sql);

    # if we're fetching and we already have a result, we can assume we're getting the next batch
    if ($self->has_result) { 
        $params{NextToken} = $self->result->{SelectResult}{NextToken};
    }

    my $result = $self->domain->simpledb->send_request('Select', \%params);
    $self->result($result);
    return $result;
}

#--------------------------------------------------------

=head2 next () 

Returns the next result in the result set. Also fetches th next partial result set if there's a next token in the first result set and you've iterated through the first partial set.

=cut

sub next {
    my ($self) = @_;

    # get the current results
    my $result = ($self->has_result) ? $self->result : $self->fetch_result;
    my $items = (ref $result->{SelectResult}{Item} eq 'ARRAY') ? $result->{SelectResult}{Item} : [$result->{SelectResult}{Item}];
    my $num_items = scalar @{$items};
    return undef unless $num_items > 0;

    # fetch more results if needed
    my $iterator = $self->iterator;
    if ($iterator >= $num_items) {
        if (exists $result->{SelectResult}{NextToken}) {
            $self->iterator(0);
            $iterator = 0;
            $result = $self->fetch_results;
        }
        else {
            return undef;
        }
    }

    # iterate
    my $item = $items->[$iterator];
    return undef unless defined $item;
    $iterator++;
    $self->iterator($iterator);

    # make the item object
    return $self->handle_item($item->{Name}, $item->{Attribute});
}

#--------------------------------------------------------

=head2 handle_item ( id , attributes ) 

Converts the attributes section of an item in a result set into a L<SimpleDB::Class::Item> object.

=cut

sub handle_item {
    my ($self, $id, $list) = @_;
    my $domain = $self->domain;
    my $registered_attributes = $domain->attributes;
    unless (ref $list eq 'ARRAY') {
        $list = [$list];
    }
    my %attributes;
    my $select = SimpleDB::Class::SQL->new(domain=>$self->domain); 
    foreach my $attribute (@{$list}) {
        my $value = $select->parse_value($attribute->{Name}, $attribute->{Value});
        # create expected hashref
        if (exists $attributes{$attribute->{Name}}) {
            if (ref $attributes{$attribute->{Name}} ne 'ARRAY') {
                $attributes{$attribute->{Name}} = [$attributes{$attribute->{Name}}];
            }
            push @{$attributes{$attribute->{Name}}}, $value;
        }
        else {
            $attributes{$attribute->{Name}} = $value;
        }
    }
    return SimpleDB::Class::Item->new(domain=>$domain, name=>$id, attributes=>\%attributes);
}

=head1 AUTHOR

JT Smith <jt_at_plainblack_com>

I have to give credit where credit is due: SimpleDB::Class is heavily inspired by L<DBIx::Class> by Matt Trout (and others), and the Amazon::SimpleDB class distributed by Amazon itself (not to be confused with Amazon::SimpleDB written by Timothy Appnel).

=head1 LEGAL

SimpleDB::Class is Copyright 2009 Plain Black Corporation and is licensed under the same terms as Perl itself.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;