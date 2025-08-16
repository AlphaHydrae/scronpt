#!/usr/bin/env bash
set -e

#!/usr/bin/env bash
set -e

function chown_if_possible() {
  local file="$1"
  chown -h scronpt:scronpt "$file" || echo "Skipped changing ownership of ${file}."
}

function generate_cron() {
  local script="$1"
  local schedule="$2"

  cat <<EOF
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * <command to execute>
${schedule} sudo -u scronpt ${script}
EOF
}

uid_or_gid_changed=

gid=$(id -g scronpt)
if [ -n "$SCRONPT_GID" ] && [ "$gid" != "$SCRONPT_GID" ]; then
  echo
  echo "Changing scronpt group GID from ${gid} to ${SCRONPT_GID}..."
  gid="${SCRONPT_GID}"
  groupmod -g "$gid" scronpt
  uid_or_gid_changed=1
fi

uid=$(id -u scronpt)
if [ -n "$SCRONPT_UID" ] && [ "$uid" != "$SCRONPT_UID" ]; then
  echo
  echo "Changing scronpt user UID from ${uid} to ${SCRONPT_UID}..."
  uid="${SCRONPT_UID}"
  usermod -u "$uid" scronpt
  uid_or_gid_changed=1
fi

if test -n "$uid_or_gid_changed"; then
  echo

  export -f chown_if_possible
  for dir in /etc/scronpt /home/scronpt /var/lib/scronpt; do
    echo "Updating ownership of scronpt files in ${dir}..."
    find "$dir" -xdev -exec bash -c 'chown_if_possible "$@"' bash {} \;
  done

  echo
fi

scronpt_script="${SCRONPT_SCRIPT:-/usr/local/bin/script}"

scronpt_minute="${SCRONPT_MINUTE:-0}"
scronpt_hour="${SCRONPT_HOUR:-*}"
scronpt_day="${SCRONPT_DAY:-*}"
scronpt_month="${SCRONPT_MONTH:-*}"
scronpt_day_of_the_week="${SCRONPT_DAY_OF_THE_WEEK:-*}"
scronpt_cron="${SCRONPT_CRON:-"$scronpt_minute $scronpt_hour $scronpt_day $scronpt_month $scronpt_day_of_the_week"}"

printf "Configuring scronpt cron..."
generate_cron "$scronpt_script" "$scronpt_cron" | crontab -
echo " ok"

echo
crontab -l

echo

exec crond -f -l 6
