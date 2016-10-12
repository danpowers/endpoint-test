#endpoint-test.sh

This script is meant to provide a simple example test script that uses the Globus CLI to test basic endpoint functionality. 

The script will attempt to transfer the contents of a configurable source directory on a configurable source endpoint to a configurable destination directory on a configurable destination endpoint.

The script requires that the user have current activations on both endpoints being used. The script does not handle endpoint activation at this time, so this must be done manually beforehand. 

Use of this script requires that the Globus CLI be installed and configured on the system where the script will be run. The Globus CLI can be found here:

https://github.com/globus/globus-cli
