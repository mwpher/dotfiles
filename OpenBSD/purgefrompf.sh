#!/bin/sh

cat /etc/bruteforcers | sed "s/$1//g" > /etc/bruteforcers
