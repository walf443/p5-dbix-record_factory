package DBIx::RecordFactory::RuleSet::ActiveRecord;
use 5.008_001;
use strict;
use warnings;
use DBI qw(:sql_types);

our $VERSION = '0.01';

sub apply {
    my ($class, %args) = @_;
    my $factory = $args{factory};

    my $schema = $factory->teng->schema;
    for my $table_name ( keys %{ $schema->{tables} } ) {
        my $table = $schema->get_table($table_name);
        my $columns = {};
        my $primary_keys = $table->primary_keys;
        my $primary_key;
        if ( @$primary_keys == 1 ) {
            $primary_key = $primary_keys->[0];
        } else {
        }
        for my $col ( @{ $table->columns } ) {
            if ( $primary_key && $col eq $primary_key ) {
                $columns->{$col} = sub { $_[0]->sequence($table_name . '.' . $col) };
            } elsif ( $col =~ /^(.+)_id$/ ) {
                my $relation_table = $1;
                if ( defined $args{$relation_table} && ref $args{$relation_table} eq "HASH" ) {
                    $columns->{$col} = sub { my $relation = $_[0]->insert($relation_table, %{$args{$relation_table}}); return $relation->{id} };
                } else {
                    $columns->{$col} = sub { my $relation = $_[0]->insert($relation_table); return $relation->{id} };
                }
            } else {
                my $type = $table->get_sql_type($col);
                if ( $type == SQL_INTEGER ) {
                    $columns->{$col} = sub { $_[0]->uint(1000) };
                } elsif ( $type == SQL_VARCHAR ) {
                    $columns->{$col} = sub { $_[0]->string(10, 20) };
                } else {
                    # does not support. you should define manually,
                }
            }
        }
        $factory->define($table_name => $columns);
    }
}


1;
__END__

=head1 NAME

DBIx::RecordFactory::RuleSet::ActiveRecord - Perl extension to do something

=head1 VERSION

This document describes DBIx::RecordFactory::RuleSet::ActiveRecord version 0.01.

=head1 SYNOPSIS

    use DBIx::RecordFactory::RuleSet::ActiveRecord;
    my $factory = DBIx::RecordFactory->new(dbh => $dbh);
    $factory->apply_rule("ActiveRecord");
    DBIx::RecordFactory::RuleSet::ActiveRecord->apply(factory => $factory);
    $factory->redefine(xxx => { yyy_id => sub { my $r = $_[0]->insert('yyy'); $r->{id} } });

=head1 DESCRIPTION


=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

<<YOUR NAME HERE>> E<lt><<YOUR EMAIL ADDRESS HERE>>E<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013, <<YOUR NAME HERE>>. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
