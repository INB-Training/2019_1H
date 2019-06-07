#!/bin/bash

numusers=$1
expiry="2019-05-29"
WORDS="/usr/share/dict/words"
SSL="/usr/bin/openssl"
numV='^[0-9]+$'
#if [ ! $numusers ] ; then
#       echo -n "How many users to add? "
#       read N
#fi
if [ $# -eq 0 ] ; then
        OK=false
        while (! $OK) ; do
                echo -n "How many users to add? "
                read N
                if [[ $N =~ $numV ]]; then
                        OK=true
                        numUsers=$N
                else
                        echo "$N is not a number.  Try again."
                fi
        done
else
        numUsers=$1
fi

name1=`shuf -n1 $WORDS`
#name1='lovery'
OK=false
while (! $OK) ; do
        # make sure we are not reusing a password
        #while  `grep -q $name1 /etc/passwd `; do
        #       name1=`shuf -n1 $WORDS`
        #done

        # have user verify the username is acceptable
        name=`echo $name1 | tr '[:upper:]' '[:lower:]'`
        echo -n "is $name ok for use (y/n)? "
        read A
        if [ $A = "y" -o $A = "Y" ] ;  then
                OK=true
        else
                name1=`shuf -n1 $WORDS`
        fi
done

for U in `seq -w 1 $numUsers` ; do
        TMPFILE=mktemp
        pass=`$SSL rand -base64 6`
        useradd -s /bin/bash $name${U}
        echo "Setting expiry $expiry to $name${U}"
        chage -d $expiry $name${U}
        echo $pass | passwd --stdin $name${U} > /dev/null 2>&1
        echo "$name${U}  $pass" >> $TMPFILE
        #echo "Username: $name${U}  Password: $pass" >> $TMPFILE
done
cat $TMPFILE
rm -f $TMPFILE
