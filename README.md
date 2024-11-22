# Solaris Redis SMF
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://github.com/yvoinov/redis_smf/blob/master/LICENSE)

This service was originally developed for the [CSWredis](https://www.opencsw.org/packages/CSWredis) package, which does not include the SMF service.

It was later redesigned for custom Redis builds from source (versions up to and including 5.0.14 are built on Solaris 10).

The package includes a basic Redis config that is functional starting from at least version 2.6.

The installation script creates the service and copies the configuration file to /etc.

By default, Redis binaries are supposed to be located in /usr/local (the build from sources assumes this prefix by default).

Make sure that the socket file is in the path corresponding to the configuration file - it is necessary for interaction with the Redis daemon.

When deleting the service, the Redis daemon stops. Make sure that the Redis configuration is configured to save the contents of the database (by default /var/lib/redis).

Follow these steps to enable Redis SMF:

1. Build (if nesessary) and install Redis if not already installed.

2. Adjust redis configuration redis.conf as part of the package.

3. Run the redis_smf_inst.sh script, which will perform all installation steps and install the Redis SMF service and Redis config.

3. Run `svcadm enable redis` command to enable and start the Redis service.

To deactivate and remove the Redis SMF service, follow these steps:

1. Run the redis_smf_rmv.sh  script. The script stops all running redis processes, unregisters the SMF service, completely removes the Redis SMF and rolls back the operations performed earlier when the service was activated.

Note: Removing the Redis SMF service does not remove the installed Redis software.
