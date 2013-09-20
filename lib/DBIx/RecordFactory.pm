package DBIx::RecordFactory;
use 5.008005;
use strict;
use warnings;
use Class::Accessor::Lite ( new => 1, ro => [qw( dbh )] );
use Teng::Schema::Loader;
use POSIX qw();
use DBI;

our $VERSION = "0.01";

sub teng {
    my $self = shift;
    $self->{teng} ||= sub {
        Teng::Schema::Loader->load(
            dbh => $self->dbh || '',
            namespace => ( __PACKAGE__ . "::Teng" ),
            suppress_row_objects => 1,
        );
    }->();
}

sub define {
    my ($self, $name, $code, %args) = @_;
    $self->{__rule} ||= {};
    $self->{__rule}->{ $name } = $code;
    $self->{__table_of} ||= {};
    $self->{__table_of}->{ $name } = ( $args{'table'} || $name );

    return $code;
}

sub table_name {
    my ($self, $name) = @_;
    return $self->{__table_of}->{ $name };
}

sub rule {
    my ($self, $name) = @_;
    return $self->{__rule}->{$name};
}

sub insert {
    my ($self, $rule, %args) = @_;
    my $table = $self->table_name($rule);
    my $data = $self->build($rule, %args);
    return $self->teng->insert($table => $data);
}

sub build {
    my ($self, $rule_name, %args) = @_;
    my $rule = $self->rule($rule_name)
        or die "Can't find rule: $rule_name";

    my $row = {};
    for my $col ( keys %$rule ) {
        if ( $args{$col} ) {
            if ( ref $args{$col} && ref $args{$col} eq "CODE" ) {
                $row->{$col} = $args{$col}->($self);
            } else {
                $row->{$col} = $args{$col};
            }
        } else {
            $row->{$col} = $rule->{$col}->($self);
        }
    }
    return $row;
}

sub sequence {
    my ($self, $namespace) = @_;
    $self->{__sequence} ||= {};
    $self->{__sequence}->{$namespace} ||= 0;
    $self->{__sequence}->{$namespace}++;
    return $self->{__sequence}->{$namespace};
}

sub string {
    my ($self, $max, $min) = @_;
    $min ||= 0;
    my $count = $min + POSIX::floor(rand() * ($max - $min));
    my @alpha = qw(a b c d e f g h i j k l m n o p q r s t u v x y z 1 2 3 4 5 6 7 8 9 0 _ );
    my $result = "";
    for my $loop (1..$count) {
        my $index = POSIX::floor(rand() * scalar @alpha);
        my $choice = $alpha[$index];
        $result .= $choice;
    }
    return $result;
}

sub uint {
    my ($self, $max, $min) = @_;
    $min ||= 0;
    return $min + POSIX::floor(rand() * ($max - $min));
}

1;
__END__

=encoding utf-8

=head1 NAME

DBIx::RecordFactory - It's new $module

=head1 SYNOPSIS

    use DBIx::RecordFactory;
    my $factory = DBIx::RecordFactory->new(dbh => $dbh);
    $factory->define('user' => +{
        id => sub { shift->sequence('account_id') }
        account_id => sub {
            my $account = shift->insert('account');
            $account->{id};
        }
    });
    $factory->define('account' => {
        login_id => sub { shift->string(255) }
        password => sub { shift->string(255) }
    });

    my $userdata = $factory->insert('user');
    #   => {
    #     'id' => 1,
    #     'account_id' => 1,
    #   }
    my $teng = Teng->new(dbh => $dbh);
    my $account = $teng->lookup(account => { id => $userdata->{account_id} });

=head1 DESCRIPTION

DBIx::RecordFactory is ...

=head1 SEE ALSO

 FactoryGirl - https://github.com/thoughtbot/factory_girl

=head1 LICENSE

Copyright (C) Keiji, Yoshimi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keiji, Yoshimi E<lt>walf443@gmail.comE<gt>

=cut

