use strict;
use warnings;
use Test::More;
use DBIx::RecordFactory;
use DBIx::RecordFactory::RuleSet::ActiveRecord;

my $dbh = DBI->connect('dbi:SQLite:', {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
});

my $factory = DBIx::RecordFactory->new(dbh => $dbh);
isa_ok($factory, "DBIx::RecordFactory");

$dbh->do(q{CREATE TABLE foo ( id int unsigned not null, name varchar(255) not null, cnt int unsigned not null, primary key (id) ); });
DBIx::RecordFactory::RuleSet::ActiveRecord->apply(factory => $factory);

my $rule = $factory->rule('foo');
ok($rule, "define rule foo OK");
subtest "rule foo" => sub {
    ok($rule->{id}, "id OK");
    ok($rule->{name}, "name OK");
    ok($rule->{cnt}, "name OK");
};

for my $count (1..2) {
    subtest "iteration : $count" => sub {
        my $row = $factory->build("foo");
        is(ref $row, "HASH", "row should be HashRef");
        is($row->{id}, $count, "id OK");
        cmp_ok(length $row->{name}, '<', 255, "name OK");
        cmp_ok($row->{cnt}, '>=', 0, "cnt should greater than 0");
        cmp_ok($row->{cnt}, '<', 12345678, "cnt should less than 12345678");
    };
}

done_testing;
