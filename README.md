# PlugAuth::Plugin::Finger [![Build Status](https://secure.travis-ci.org/clustericious/PlugAuth-Plugin-Finger.png)](http://travis-ci.org/clustericious/PlugAuth-Plugin-Finger)

(Deprecated) Add a finger protocol interface to your PlugAuth server

# SYNOPSIS

In your PlugAuth.conf:

    plugins:
      - PlugAuth::Plugin::Finger:
          port: 8079

Then from the command line, to list all users/groups:

    % finger @localhost

and from the command line, to query a user or group:

    % finger foo@localhost

and to see the granted permissions:

    % finger -l foo@localhost

# DESCRIPTION

**NOTE**: This module has been deprecated, and may be removed on or after 31 December 2018.
Please see [https://github.com/clustericious/Clustericious/issues/46](https://github.com/clustericious/Clustericious/issues/46).

This plugin provides a finger protocol interface to PlugAuth.  Through
it you can see the users, groups and their permissions through the finger
interface.

By default this plugin will listen to port 79 on Windows, or when the user
is privileged under Unix.  Otherwise it will listen to port 8079.  Many
finger clients cannot be configured to connect to a different port, but
you can use `iptables` on Linux, or use an equivalent tool on other operating
systems to forward port 79 to port 8079.

# PLUGIN OPTIONS

## port

Specify the port.  This is will default to 79 or 8079 if you do not specify it.

# CAVEATS

This plugin won't work as currently implemented if you are using a start\_mode
which forks, such as hypnotoad.  Until that is solved this plugin will probably
prevent you from scaling your PlugAuth deployment.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
