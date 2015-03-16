#!/system/bin/sh

# Uage:
#       procleak.sh procname

if [ $# != 1 ]; then
  echo "Uage: $0 procname"
  exit 1
fi

OUTPUT='/sdcard/procleak.log'

echo 'timestamp\tPID\tVss\tRss\tPss\tUss\tcmdline' >> $OUTPUT

while true; do
  timestamp=`date '+%Y-%m-%d %H:%M:%S'`
  key=$1'$'
  meminfo=`procrank | busybox grep ${key}`

  echo $timestamp'\t'$meminfo >> $OUTPUT

  sleep 5
done
