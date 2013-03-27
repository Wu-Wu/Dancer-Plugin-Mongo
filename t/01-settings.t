use strict;
use warnings;
use Test::More import => ['!pass'];
use Dancer ':syntax';
use Dancer::Test;

my $test_package = 't::lib::AppMongo';

set show_errors => 1;
set plugins     => {
    Mongo => {
        host        => 'bogus:27017',
        connections => {
            foo => { host => 'bogus:28017' },
        }
    }
};

load_app $test_package;

my @samples = (
    '/'                 => 200, $test_package,
    '/mongo'            => 200, 42,
    '/mongo/get/foo'    => 500, 'Cannot.*handle.*bogus:28017',
    '/mongo/get/bar'    => 500, 'Options.*not found',
    '/mongo/get'        => 500, 'Cannot.*handle.*bogus:27017',
);

while (my($route, $code, $content) = splice(@samples, 0, 3)) {
    my $resp = dancer_response GET => $route;
    ok   $resp,                         "response exists for GET $route";
    is   $resp->status,   $code,        "status code for GET $route is $code";
    like $resp->content,  qr/$content/, "content looks good for GET $route";
}

done_testing();
