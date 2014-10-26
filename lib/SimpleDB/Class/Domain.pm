package SimpleDB::Class::Domain;
our $VERSION = '0.0502';

=head1 NAME

SimpleDB::Class::Domain - A schematic representation of a SimpleDB domain.

=head1 VERSION

version 0.0502

=head1 DESCRIPTION

A subclass of this class is created for each domain in SimpleDB with it's name, attributes, and relationships.

=head1 METHODS

The following methods are available from this class.

=cut

use Moose;
use SimpleDB::Class::SQL;
use SimpleDB::Class::ResultSet;
use SimpleDB::Class::Exception;


#--------------------------------------------------------

=head2 new ( params ) 

Constructor. Normally you should never call this method yourself, instead use the domain() method in L<SimpleDB::Class>.

=head3 params

A hash containing the parameters needed to construct this object.

=head4 simpledb

Required. A reference to a L<SimpleDB::Class> object.

=head4 name

Required. The SimpleDB domain name associated with this class.

=cut


#--------------------------------------------------------

=head2 item_class ( )

Returns the L<SimpleDB::Class::Item> subclass name passed into the constructor.

=cut

has item_class => (
    is          => 'ro',
    required    => 1,
    trigger     => sub {
        my ($self, $item, $old) = @_;
        $self->name($item->domain_name);
    },
);

#--------------------------------------------------------

=head2 name ( )

Returns the name determined automatically by the item_class passed into the constructor.

=cut

has name => (
    is          => 'rw',
    default     => undef,
);

#--------------------------------------------------------

=head2 simpledb ( )

Returns the L<SimpleDB::Class> object set in the constructor.

=cut

has simpledb => (
    is          => 'ro',
    required    => 1,
);

#--------------------------------------------------------

=head2 create 

Creates this domain in the SimpleDB.

=cut

sub create {
    my ($self) = @_;
    $self->simpledb->http->send_request('CreateDomain', {
        DomainName => $self->name,
    });
}

#--------------------------------------------------------

=head2 delete

Deletes this domain from the SimpleDB.

=cut

sub delete {
    my ($self) = @_;
    $self->simpledb->http->send_request('DeleteDomain', {
        DomainName => $self->name,
    });
}

#--------------------------------------------------------

=head2 find ( id )

Retrieves an item from the SimpleDB by ID and then returns a L<SimpleDB::Class::Item> object.

=head3 id

The unique identifier (called ItemName in AWS documentation) of the item to retrieve.

=cut

sub find {
    my ($self, $id) = @_;
    SimpleDB::Class::Exception::InvalidParam->throw(name=>'id', value=>undef) unless defined $id;
    my $cache = $self->simpledb->cache;
    my $attributes = eval{$cache->get($self->name, $id)};
    my $e;
    if (SimpleDB::Class::Exception::ObjectNotFound->caught) {
        my $result = $self->simpledb->http->send_request('GetAttributes', {
            ItemName    => $id,
            DomainName  => $self->name,
        });
        my $item = SimpleDB::Class::ResultSet
            ->new(simpledb=>$self->simpledb, item_class=>$self->item_class)
            ->handle_item($id, $result->{GetAttributesResult}{Attribute});
        if (defined $item) {
            $cache->set($self->name, $id, $item->to_hashref);
        }
        return $item;
    }
    elsif (my $e = SimpleDB::Class::Exception->caught) {
        warn $e->error;
        return $e->rethrow;
    }
    elsif (defined $attributes) {
        return $self->item_class->new(id=>$id, simpledb=>$self->simpledb)
            ->update($attributes);
    }
    else {
        SimpleDB::Class::Exception->throw(error=>"An undefined error occured while fetching the item.");
    }
}

#--------------------------------------------------------

=head2 insert ( attributes, [ id ] ) 

Adds a new item to this domain.

=head3 attributes

A hash reference of name value pairs to insert as attributes into this item.

=head3 id

Optionally specify a unqiue id for this item.

=cut

sub insert {
    my ($self, $attributes, $id) = @_;
    my %params = (simpledb=>$self->simpledb);
    if (defined $id && $id ne '') {
        $params{id} = $id;
    }
    return $self->item_class->new(\%params)
        ->update($attributes)
        ->put;
}

#--------------------------------------------------------

=head2 count ( [ where ] ) 

Returns an integer indicating how many items are in this domain.

WARNING: With this method you need to be aware that SimpleDB is eventually consistent. See L<SimpleDB::Class/"Eventual Consistency"> for details.

=head3 where

A where clause as defined in L<SimpleDB::Class::SQL> if you want to count only a certain number of items in the domain.

=cut

sub count {
    my ($self, $clauses) = @_;
    my $select = SimpleDB::Class::SQL->new(
        item_class  => $self->item_class,
        where       => $clauses,
        output      => 'count(*)',
    );
    my $result = $self->simpledb->http->send_request('Select', {
        SelectExpression    => $select->to_sql,
    });
    return $result->{SelectResult}{Item}{Attribute}{Value};
}

#--------------------------------------------------------

=head2 search ( where )

Returns a L<SimpleDB::Class::ResultSet> object. 

WARNING: With this method you need to be aware that SimpleDB is eventually consistent. See L<SimpleDB::Class/"Eventual Consistency"> for details.

=head3 where

A where clause as defined by L<SimpleDB::Class::SQL>.

=cut

sub search {
    my ($self, $where) = @_;
    return SimpleDB::Class::ResultSet->new(
        simpledb    => $self->simpledb,
        item_class  => $self->item_class,
        where       => $where,
        );
}

=head1 LEGAL

SimpleDB::Class is Copyright 2009 Plain Black Corporation (L<http://www.plainblack.com/>) and is licensed under the same terms as Perl itself.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;