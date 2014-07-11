#!/bin/bash
# Create a cache of all IPS of running EC2 instances

. $(dirname $(realpath $0))/../lib/bash/softec-common.sh || exit

CACHE_DIR=/var/cache/aws
CACHE_FILE=$CACHE_DIR/running-instances-ips.list
TMPFILE=/tmp/running-instances-ips.tmp

export EC2_HOME=/opt/ec2-api-tools
export EC2_USERHOME=$HOME/.ec2
export EC2_PRIVATE_KEY=$EC2_USERHOME/pk-LQSD7GMVOA7HOEIQJ6M6244P4H6TSMVU.pem
export EC2_CERT=$EC2_USERHOME/cert-LQSD7GMVOA7HOEIQJ6M6244P4H6TSMVU.pem
export EC2_URL=https://eu-west-1.ec2.amazonaws.com
export JAVA_HOME=/usr/lib/jvm/java-6-sun/
export PATH=$PATH:/opt/ec2-api-tools/bin/

ensure_dir $CACHE_DIR
ensure_bin ec2-describe-instances
ensure_bin dig

if [ -f $TMPFILE ]; then
    log_debug "Cleaning old tmpfile $TMPFILE"
    rm -f $TMPFILE
fi

EC2_HOSTNAMES=$(ec2-describe-instances | grep INSTANCE | grep -v stopped | cut -f4)

for EC2_HOSTNAME in $EC2_HOSTNAMES; do
    /usr/bin/dig +short $EC2_HOSTNAME >> $TMPFILE
    if [[ $EC2_HOSTNAME =~ ^ec2-([0-9]+)-([0-9]+)-([0-9]+)-([0-9]+).*$ ]]; then 
        echo ${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}.${BASH_REMATCH[4]} >> $TMPFILE
    else
        log_error "What the fuck is this?!?! Hostname on AWS must be ec2-bla-bla-bla... It's '$EC2_HOSTNAME'"
    fi
done

if [ ! -s $TMPFILE ]; then
    log_error "zero-sized $TMPFILE"
else
    mv $TMPFILE $CACHE_FILE
fi
