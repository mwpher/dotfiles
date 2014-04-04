if [ "$PS1" ]; then
  if [ "$BASH" ] && [ "$BASH" != "/bin/sh" ]; then
    if [ -f /usr/local/etc/bash.bashrc ]; then
      . /usr/local/etc/bash.bashrc
    fi
  fi
fi
