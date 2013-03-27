package
    t::lib::AppMongo;

use strict;
use Dancer ':syntax';
use Dancer::Plugin::Mongo;

get '/' => sub {  __PACKAGE__ };

prefix '/mongo';

get '/' => sub  {
    42;
};

get '/get/?:profile?/?' => sub  {
    mongo(params->{profile})
};

1;
