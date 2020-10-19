yum check-update > /dev/null

UPDATES_COUNT=$(yum check-update --quiet | grep -v "^$" | wc -l)

if [[ $UPDATES_COUNT -gt 0 ]]; then
   echo "${UPDATES_COUNT} Updates available, installing"
   yum -y upgrade
else
   echo "${UPDATES_COUNT} updates available"
fi