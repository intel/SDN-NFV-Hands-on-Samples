#!/bin/bash

watch -n 1 $OVS_DIR/utilities/ovs-ofctl dump-flows br0
