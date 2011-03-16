#!/bin/sh
tail -n +$(($2 + 1)) $1|head -n -$2
