#!/bin/bash
script_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
args="$@"
$script_dir/brevity eval "ChorerApp.Release.check_config()"
