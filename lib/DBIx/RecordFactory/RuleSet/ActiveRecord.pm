package DBIx::RecordFactory::RuleSet::ActiveRecord;
use 5.008_001;
use strict;
use warnings;
use DBIx::Inspector;

our $VERSION = '0.01';

sub apply {
    my ($class, %args) = @_;
    my $factory = $args{factory};
    my $inspector = DBIx::Inspector->new(dbh => $factory->dbh);
    for my $table ( $inspector->tables ) {
        my $columns = {};
        for my $col ( $table->columns ) {
            if ( $col->is_nullable ne 'NO' ) {
                # pass
            } else {
                if ( $col->type_name =~ /VARCHAR/i ) {
                    $columns->{$col->name} = sub { $_[0]->string(10, 20) };
                } elsif ( $col->type_name =~ /INT/i ) {
                    $columns->{$col->name} = sub { $_[0]->uint(1000) };
                } else {
                    $columns->{$col->name} = sub { 'dummy' };
                }
            }
        }
        $factory->define($table->name => $columns);
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

=head1 DESCRIPTION

# TODO

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
