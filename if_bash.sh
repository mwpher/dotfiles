#!/bin/sh

if type "zsh"; then
	exec zsh;
elif type "bash"; then
	exec bash;
elif type "tcsh"; then
	exec tcsh;
elif type "csh"; then
	exec csh;
elif type "ksh"; then
	exec csh;
else
	exec sh;
fi

return 1;

