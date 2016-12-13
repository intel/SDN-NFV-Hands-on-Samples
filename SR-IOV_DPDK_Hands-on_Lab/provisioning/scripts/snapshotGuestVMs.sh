#!/bin/bash

# Copyright (c) 2016 Intel Corporation

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Author: Clayne B. Robison <clayne dot b dot robison at intel dot com>

# Portions of this code are used with permission under the following license:

#   Copyright (c) 2016 Kumina, https://kumina.nl/

#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
#   1. Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.

#   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
#   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
#   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.



#The snapshotGuestVMs.sh script starts all of the domains on the system, and then creates a snapshot labelling it with the current date.

# Configure timeout (in seconds).
TIMEOUT=300
VIRSH=/usr/bin/virsh
exitVal=0
SNAPSHOT_CMD=snapshot-create-as
SNAPSHOT_NAME=$(date --rfc-3339=date)

if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you are not root."
	exit 1
fi


# List running domains.
list_domains() {
	$VIRSH list --all | grep "$1" | awk '{ print $2}'
}

#The start_domains function
start_domains() {

	local retVal=0

	echo "Try to start all  KVM domains..."

	# Create some sort of semaphore.
	touch /tmp/start-kvm-guests

	# Try to start each domain, one by one.
	list_domains "shut off" | while read DOMAIN; do
		# Try to shutdown given domain.
		$VIRSH start $DOMAIN
	done

	# Wait until all domains are shut down or timeout has reached.
	END_TIME=$(date -d "$TIMEOUT seconds" +%s)
	
	while [ $(date +%s) -lt $END_TIME ]; do
		# Break while loop when no domains are left.
		test -z "$(list_domains "shut off")" && break
		# Wait a litte, we don't want to DoS libvirt.
		sleep 1
	done
	
	# show error for domains that did not start
	list_domains "shut off" | while read DOMAIN; do
		# Try to shutdown given domain.
		echo "**Failed to start domain $DOMAIN"
		# let caller know the script failed
		retVal=1
	done
	
	return $retVal
}

#the snapshot_domains function
snapshot_domains() {
	list_domains "running" | while read DOMAIN; do
		echo "creating snapshot for $DOMAIN with name=$SNAPSHOT_NAME"
		$VIRSH $SNAPSHOT_CMD --domain $DOMAIN --name $SNAPSHOT_NAME
	done

}

start_domains
retVal=$?

#only run the snapshot function if all of the domains are running; 
#otherwise, we get an error from libvirt
if [ $retVal -eq 0 ]; then
	snapshot_domains
else
	echo "Failed to start all Domains. Aborting Snapshot process..."
fi

exit $retVal
