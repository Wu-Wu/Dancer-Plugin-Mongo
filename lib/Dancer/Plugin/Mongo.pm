# ABSTRACT: MongoDB plugin for the Dancer micro framework
package Dancer::Plugin::Mongo;

use strict;
use warnings;
use Dancer::Plugin;
use MongoDB 0.502;
use Carp ();

our $VERSION = 0.03;

my $settings;
my $handles;

my $croak = sub { Carp::croak $_[0] };

## return a connected MongoDB object
register mongo => sub {
    my (undef, $profile) = plugin_args(@_);

    $profile ||= '_default';

    return $handles->{$profile} if exists $handles->{$profile};

    $settings ||= plugin_setting;

    my $options = $profile eq '_default' ? $settings : $settings->{connections}->{$profile};
    $croak->("Options for '$profile' not found") unless ref $options eq 'HASH';

    my $_handle;
    eval { $_handle = MongoDB::MongoClient->new(_slurp_settings($options)) };
    $croak->("Cannot get mongo handle: $@") if $@;

    $handles->{$profile} = $_handle;

    return $_handle;
};

register_plugin for_versions => [1, 2];

sub _slurp_settings {
    my ($settings) = @_;

    my $args = {};
    my @allowed = qw(
        host
        w
        wtimeout
        j
        auto_reconnect
        auto_connect
        timeout
        username
        password
        db_name
        query_timeout
        max_bson_size
        find_master
        ssl
        dt_type
    );

    for (@allowed) {
        $args->{$_} = $settings->{$_} if exists $settings->{$_};
    }

    return $args;
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Dancer;
    use Dancer::Plugin::Mongo;

    get '/widget/view/:id' => sub {
        my $widget = mongo->database->collection->find_one({ id => params->{id} });
    }

    get '/hosts/get' => sub {
        to_json(mongo('live')->hosts->profiles->find->all);
    }

=head1 DESCRIPTION

Dancer::Plugin::Mongo provides a wrapper around L<MongoDB>. Add the appropriate
configuraton options to your config.yml and then you can access a MongoDB database
using the 'mongo' keyword.

To query the database, use the standard MongoDB syntax, described in
L<MongoDB::Collection>.

=head1 CONFIGURATION

Connection details will be taken from your Dancer application config file, and
should be specified as follows:

    plugins:
        Mongo:
            host: 'mongodb://mongo.example.com:27017'
            db_name: 'test'
            connections:
                devel:
                    host: 'mongodb://devel.example.com:27017'
                    db_name: 'foo_devel'
                live:
                    host: 'mongodb://live.example.com:27017'
                    db_name: 'foo_live'
                    username: 'appuser'
                    password: 'apppassword'

All these configuration values are optional, full details are in the
L<MongoDB::MongoClient> documentation.

=cut
