#!/bin/bash
USER=$1
while [ -z $USER ] ; do
        echo -n "User needed. Input username: "
        read USER
done
echo "Username: $USER ..."
useradd -m -s /bin/bash $USER

PASS=`openssl rand -base64 12`
echo "Password: $PASS"

echo "$USER:$PASS::::/home/$USER:/bin/bash" | newusers
echo "IP address to ssh to: 207.108.8.68"
echo "Sleeping 10 seconds to enable copy/paste of username/password above."
sleep 10

# generate the user's ssh key and add the it to root's authorized_keys file on the compute nodes
mkdir -m 700 /home/$USER/.ssh
ssh-keygen -N '' -b 4096 -f /home/$USER/.ssh/id_rsa
chown -R ${USER}:${USER} /home/$USER
# this is commented out on dln5; not all nodes are used in every training
for X in `seq -w 1 20` ; do
        ssh-copy-id -i /home/$USER/.ssh/id_rsa icn${X}
done
