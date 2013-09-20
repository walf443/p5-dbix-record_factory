use strict;
use warnings;
use Test::More;
use DBIx::RecordFactory;
use DBI;
use Teng;

my $dbh = DBI->connect('dbi:SQLite:', {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
});

$dbh->do(q{CREATE TABLE foo ( id int unsigned not null, name varchar(255) not null, cnt int unsigned not null, primary key (id) ); });

my $teng = Teng::Schema::Loader->load(
    dbh => $dbh,
    namespace => "Test::Teng01",
    suppress_row_objects => 1,
);

my $factory = DBIx::RecordFactory->new(teng => $teng);
isa_ok($factory, "DBIx::RecordFactory");

$factory->define("foo" => +{
    id => sub { $_[0]->sequence('foo_id') },
    name => sub { $_[0]->string(255) },
    cnt  => sub { $_[0]->uint(12345678) },
});

for my $count (1..1000) {
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
