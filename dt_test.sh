#!/bin/ksh

HOSTS="$1";
[ -z "$HOSTS" ]  && echo "The first parameter must be full name of the file with list of hosts!" && exit;

TXRATE="$2";
[ -z "$TXRATE" ] && echo "The 2-d parametet must be number of txRate option (like 500)" && exit;

TXDURATION="$3";
[ -z "$TXRATE" ] && echo "The 3-d parametet must be number of txDurationMs option (like 600000 = 10min)" && exit;

DOMAIN="$4";
[ -z "$DOMAIN" ] && echo "The 4-th parameter must be DOMAIN name (like \"uk.db.com\") !" && exit;

JAVA_HOME=/local/apps/cache/JRE_LINUX_7;
JAVA=$JAVA_HOME/bin/java;
RUN_DIR=/home/dfluser/datagram/;
WGET_CMD="wget http://gmrepo.gslb.db.com:8481/nexus-webapp/content/groups/gtrepositories/com/oracle/coherence/coherence/3.7.1.12/coherence-3.7.1.12.jar -O coherence-3.7.1.12.jar";
DT_RXTX_OPT="-txDurationMs $TXDURATION -txRate $TXRATE -rxBufferSize 250 -packetSize 8192";
DT_JAVA_OPT="-cp coherence-3.7.1.12.jar -server com.tangosol.net.DatagramTest";

HN=0;
LAST=`cat $HOSTS | wc -l `;
#
for host in `cat $HOSTS`
do
        DT_LOCAL_OPT="-local $host-pri:9999";
        DT_HOSTS=`cat $HOSTS | grep -v $host | awk '{print $1"-pri:9999"}'| tr '\n' ' '`;
        CMD="mkdir -p $RUN_DIR; cd $RUN_DIR; $WGET_CMD; export JAVA_HOME=$JAVA_HOME; $JAVA $DT_JAVA_OPT $DT_LOCAL_OPT $DT_RXTX_OPT -log dt_table_$host.log";
        HN=$(($HN+1));
        if [ "$HN" != "$LAST" ]
        then
                CMD="$CMD -polite";
        fi
                CMD="$CMD $DT_HOSTS";
        ssh $host.$DOMAIN "$CMD" >/dev/null 2>dt_$host.log &;
                echo "$!" > dt_$host.pid;
        echo "Started on $host";
done
#
echo "Waiting for test to complete....";
for host in `cat $HOSTS`
do
        wait `cat dt_$host.pid`;
        rm dt_$host.pid;
done;
#
rm report.html
for host in `cat $HOSTS`
do
grep -e "Clients have stopped." -e "Lifetime:" -e "Rx from publisher" -e "success rate" dt_$host.log | grep "Lifetime" -A 11 | tail -n 11 | awk '{getline a; printf "%-s\n", $0 " " a}' | sort | uniq | awk '{print $4,":",$7}' | tr -d ' '| tr -d '/' | tr -d 'success' | awk -F":" '{print "'"$host"'","#",$1,"#",$3}'| tr -d ' ' >> report.html;
done;
