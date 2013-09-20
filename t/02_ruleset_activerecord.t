use strict;
use warnings;
use Test::More;
use DBIx::RecordFactory;
use DBIx::RecordFactory::RuleSet::ActiveRecord;
use Test::mysqld;

my $mysqld = Test::mysqld->new(
    my_cnf => {
        'skip-networking' => '',
    }
)
    or plan skip_all => $Test::mysqld::errstr;

my $dbh = DBI->connect($mysqld->dsn(dbname => 'test'), {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
});

$dbh->do(q{CREATE TABLE foo ( id int unsigned not null, name varchar(255) not null, cnt int unsigned not null, primary key (id) ); });
$dbh->do(q{CREATE TABLE bar ( id int unsigned not null, foo_id int unsigned not null, primary key (id) ); });

my $teng = Teng::Schema::Loader->load(
    dbh => $dbh,
    namespace => "Test::Teng01",
    suppress_row_objects => 1,
);

my $factory = DBIx::RecordFactory->new(teng => $teng);
isa_ok($factory, "DBIx::RecordFactory");
DBIx::RecordFactory::RuleSet::ActiveRecord->apply(factory => $factory);

subtest "foo" => sub {
    my $rule = $factory->rule('foo');
    ok($rule, "define rule foo OK");
    subtest "rule foo" => sub {
        ok($rule->{id}, "id OK");
        ok($rule->{name}, "name OK");
        ok($rule->{cnt}, "name OK");
    };

    for my $count (1..100) {
        subtest "iteration : $count" => sub {
            my $row = $factory->insert("foo");
            is(ref $row, "HASH", "row should be HashRef");
            is($row->{id}, $count, "id OK");
            cmp_ok(length $row->{name}, '<', 255, "name OK");
            cmp_ok($row->{cnt}, '>=', 0, "cnt should greater than 0");
            cmp_ok($row->{cnt}, '<', 12345678, "cnt should less than 12345678");
        };
    }
};

subtest "with relation" => sub {

    for my $count ( 1..100 ) {
        subtest "iteration: $count" => sub {
            my $row = $factory->insert("bar");
            is(ref $row, "HASH", "row should be HashRef");
            is($row->{id}, $count , "id OK");
            is($row->{foo_id}, $count + 100, "foo_id OK");
            my $foo_row = $factory->teng->single(foo => { id => $row->{foo_id} });
            ok($foo_row, "foo should be able to fetch from DB");
        };
    }
};

done_testing;
