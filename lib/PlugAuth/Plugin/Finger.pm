package PlugAuth::Plugin::Finger;

use strict;
use warnings;
use v5.10;
use Role::Tiny::With;
use YAML::XS qw( Dump );
use AnyEvent::Finger::Server;
use Log::Log4perl qw( :easy );

with 'PlugAuth::Role::Plugin';

# ABSTRACT: Add a finger protocol interface to your PlugAuth server
# VERSION

=head1 SYNOPSIS

In your PlugAuth.conf:

 plugins:
   - PlugAuth::Plugin::Finger: {}

Then from the command line, to list all users/groups:

 % finger @localhost

and from the command line, to query a user or group:

 % finger foo@localhost

and to see the granted permissions:

 % finger -l foo@localhost

=head1 DESCRIPTION

This plugin provides a finger protocol interface to PlugAuth.  Through
it you can see the users, groups and their permissions through the finger
interface.

By default this plugin will listen to port 79 on Windows, or when the user
is privileged under Unix.  Otherwise it will listen to port 8079.  Many
finger clients cannot be configured to connect to a different port, but
you can use C<iptables> on Linux, or use an equivalent tool on other operating
systems to forward port 79 to port 8079.

=cut

sub init
{
  my($self) = @_;
  my $port = ($> && $^O !~ /^(cygwin|MSWin32)$/) ? 8079 : 79;
  
  INFO "finger binding to port $port";
  
  my $server = $self->{server} = AnyEvent::Finger::Server->new(
    port => $port,
  );
  
  $server->start(sub {
    my($req, $res) = @_;
    $self->app->refresh;
    if($req->listing_request)
    {
      $res->say("users: ");
      $res->say("  $_") for $self->app->auth->all_users;
      $res->say("groups: ");
      $res->say("  $_") for $self->app->authz->all_groups;
      if($req->verbose)
      {
        $res->say("grants: ");
        $res->say("  $_") for @{ $self->app->authz->granted };
      }
    }
    else
    {
      my $name = lc "$req"; # stringifying gets the user and the hostname, but not the verbosity
      my $found = 0;
      if(my $groups = $self->app->authz->groups_for_user($name))
      {
        $res->say("user: " . $name);
        $res->say("belongs to: ");
        $res->say("  " . join(', ', sort @$groups));
        $found = 1;
      }
      elsif(my $users = $self->app->authz->users_in_group($name))
      {
        $res->say("group: " . $name);
        $res->say("members: ");
        $res->say("  " . join(', ', sort @$users));
        $found = 1;
      }
      else
      {
        $res->say("no such user or group");
      }
      if($req->verbose && $found)
      {
        $res->say("granted: ");
        foreach my $grant (@{ $self->app->authz->granted })
        {
          $res->say("  $grant") 
            if $grant =~ /:(.*)$/ && grep { $name eq lc $_ || $_ eq '#u' } map { s/^\s+//; s/\s+$//; $_ } split /,/, $1;
        }
      }
    }
    $res->done;
  });
}

1;