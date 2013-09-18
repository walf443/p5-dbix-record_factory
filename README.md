# NAME

DBIx::RecordFactory - It's new $module

# SYNOPSIS

    use DBIx::RecordFactory;
    my $factory = DBIx::RecordFactory->new(dbh => $dbh);
    $factory->define('user' => +{
        id => sub { shift->sequence('account_id') }
        account_id => sub {
            my $account = shift->create('account');
            $account->{id};
        }
    });
    $factory->define('account' => {
        login_id => sub { shift->string() }
        password => sub { shift->string() }
    });

    my $userdata = $factory->insert('user');
    #   => {
    #     'id' => 1,
    #     'account_id' => 1,
    #   }
    my $teng = Teng->new(dbh => $dbh);
    my $account = $teng->lookup($userdata->{account_id});

# DESCRIPTION

DBIx::RecordFactory is ...

# SEE ALSO

    FactoryGirl - https://github.com/thoughtbot/factory_girl

# LICENSE

Copyright (C) Keiji, Yoshimi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Keiji, Yoshimi <walf443@gmail.com>
