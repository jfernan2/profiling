#!/bin/bash
wget https://raw.githubusercontent.com/cms-sw/cms-bot/master/fix-igprof-sql.py
chmod +x fix-igprof-sql.py
for f in $(ls *.gz 2>/dev/null);do
## --For web-based report
    sqlf=${f/gz/sql3}
    sf=${f/igprof/}
    logf=${sf/gz/log}
    igprof-analyse --sqlite -v -d -g $f >$f.tmp 2> $logf 3>&2
    ./fix-igprof-sql.py $f.tmp |  sqlite3 $sqlf 2>> $logf 3>&2
## --For ascii-based report
    rf=${f/igprof/RES_}
    txtf=${rf/gz/txt}
    igprof-analyse  -v -d -g $f > $txtf 2>> $logf 3>&2
done

if [ -f RES_CPU_step3.txt ]; then
  export IGREP=RES_CPU_step3.txt
  export IGSORT=sorted_RES_CPU_step3.txt
  awk -v module=doEvent 'BEGIN { total = 0; } { if(substr($0,0,1)=="-"){good = 0;}; if(good&&length($0)>0){print $0; total += $3;}; if(substr($0,0,1)=="["&&index($0,module)!=0) {good = 1;} } END { print "Total: "total } ' ${IGREP} | sort -n -r -k1 | awk '{ if(index($0,"Total: ")!=0){total=$0;} else{print $0;} } END { print total; }' > ${IGSORT} 2>&1
fi