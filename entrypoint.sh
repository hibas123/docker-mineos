#!/bin/bash
set -eo pipefail

if [[ ! -f /root/password ]]; then
  if [ -z "$USER_PASSWORD" ] || [ "$USER_PASSWORD" = "random_see_log" ]; then
    echo >&2 'USER_PASSWORD not specified, generating random password.'
    USER_PASSWORD=$(date +%s | sha256sum | base64 | head -c 20 ; echo)
    echo >&2 '*******************************************************'
    echo >&2 'Password set to: ' $USER_PASSWORD
    echo >&2 '*******************************************************'

    echo 'Password set to: ' $USER_PASSWORD > /root/password

  fi
  else
  echo >&2 "Password already set by entrypoint.sh, at /root/password"
  cat /root/password
fi

if [ "$USER_NAME" ]; then
  # username specifically provided, will overwrite 'mc'
  if [[ "$USER_NAME" =~ [^a-zA-Z0-9] ]]; then
    echo >&2 'USER_NAME must contain only alphanumerics [a-zA-Z0-9]'
    exit 1
  fi
else
  echo >&2 'USER_NAME not provided; defaulting to "mc"'
  USER_NAME=mc
fi

if [ "$GROUP_NAME" ]; then
  # group name specifically provided, will overwrite 'mc'
  if [[ "$GROUP_NAME" =~ [^a-zA-Z0-9] ]]; then
    echo >&2 'GROUP_NAME must contain only alphanumerics [a-zA-Z0-9]'
    exit 1
  fi
else
  echo >&2 'GROUP_NAME not provided; defaulting to "mc"'
  GROUP_NAME=mc
fi

if [ "$USER_UID" ]; then
  # uid specifically provided, will overwrite 1000 default
  if [[ "$USER_UID" =~ [^0-9] ]]; then
    echo >&2 'USER_UID must contain only numerics [0-9]'
    exit 1
  fi
else
  USER_UID=1000
fi

if [ "$GROUP_GID" ]; then
  # gid specifically provided, will overwrite 1000 default
  if [[ "$GROUP_GID" =~ [^0-9] ]]; then
    echo >&2 'GROUP_GID must contain only numerics [0-9]'
    exit 1
  fi
else
  GROUP_GID=1000
fi

if getent group $GROUP_NAME >/dev/null 2>&1; then
  echo "a group named $GROUP_NAME already exists."
else
  groupadd -og $GROUP_GID $GROUP_NAME
  echo >&2 "Created group: $GROUP_NAME (gid: $GROUP_GID)"
fi

if id -u $USER_NAME >/dev/null 2>&1; then
  echo "a user named $USER_NAME already exists."
else
  useradd -Mos /bin/false -u $USER_UID -g $GROUP_GID $USER_NAME
  echo >&2 "Created user: $USER_NAME (uid: $USER_UID, gid: $GROUP_GID)"
fi

echo >&2 "Setting user password for '$USER_NAME'"
echo "$USER_NAME:$USER_PASSWORD" | chpasswd -c SHA512


if [ ! -f /etc/ssl/certs/mineos.crt ]; then
  echo >&2 "Generating Self-Signed SSL..."
  sh /usr/games/minecraft/generate-sslcert.sh
fi

exec "$@"