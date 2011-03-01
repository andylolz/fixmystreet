package FixMyStreet;

use strict;
use warnings;

use Path::Class;
my $ROOT_DIR = file(__FILE__)->parent->parent->absolute->resolve;

use Readonly;

use mySociety::Config;

# load the config file and store the contents in a readonly hash
mySociety::Config::set_file( __PACKAGE__->path_to("conf/general") );
Readonly::Hash my %CONFIG, %{ mySociety::Config::get_list() };

=head1 NAME

FixMyStreet

=head1 DESCRIPTION

FixMyStreet is a webite where you can report issues and have them routed to the
correct authority so that they can be fixed.

Thus module has utility functions for the FMS project.

=head1 METHODS

=head2 path_to

    $path = FixMyStreet->path_to( 'conf/general' );

Returns an absolute Path::Class object representing the path to the arguments in
the FixMyStreet directory.

=cut

sub path_to {
    my $class = shift;
    return $ROOT_DIR->file(@_);
}

=head2 config

    my $config_hash_ref = FixMyStreet->config();
    my $config_value    = FixMyStreet->config($key);

Returns a hashref to the config values. This is readonly so any attempt to
change it will fail.

Or you can pass it a key and it will return the value for that key, or undef if
it can't find it.

=cut

sub config {
    my $class = shift;
    return \%CONFIG unless scalar @_;

    my $key = shift;
    return exists $CONFIG{$key} ? $CONFIG{$key} : undef;
}

=head2 dbic_connect_info

    $connect_info = FixMyStreet->dbic_connect_info();

Returns the array that DBIx::Class::Schema needs to connect to the database.
Most of the values are read from the config file and others are hordcoded here.

=cut

# for exact details on what this could return refer to:
#
# http://search.cpan.org/dist/DBIx-Class/lib/DBIx/Class/Storage/DBI.pm#connect_info
#
# we use the one that is most similar to DBI's connect.

sub dbic_connect_info {
    my $class  = shift;
    my $config = $class->config;

    my $dsn = "dbi:Pg:dbname=" . $config->{BCI_DB_NAME};
    $dsn .= ";host=$config->{BCI_DB_HOST}"
      if $config->{BCI_DB_HOST};
    $dsn .= ";port=$config->{BCI_DB_PORT}"
      if $config->{BCI_DB_PORT};
    $dsn .= ";sslmode=allow";

    my $user     = $config->{BCI_DB_USER} || undef;
    my $password = $config->{BCI_DB_PASS} || undef;

    my $dbi_args = {
        AutoCommit     => 1,
        pg_enable_utf8 => 1,
    };
    my $dbic_args = {};

    return [ $dsn, $user, $password, $dbi_args, $dbic_args ];
}

1;
