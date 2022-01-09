#!/bin/sh

input=/config/ddclient.conf.tpl
output=/config/ddclient.conf
envsubst < $input > $output
exec "$@"