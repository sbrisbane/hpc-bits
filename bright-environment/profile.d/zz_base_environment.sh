ME=$(whoami)
#always allow root logins even if NFS is down
if [ "$ME" != "root" ]; then
  test -f /install/scripts/securelinx.sh && source /install/scripts/securelinx.sh
  test -f /install/scripts/site.sh && source /install/scripts/site.sh
fi
