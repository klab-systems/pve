#!/bin/sh

# Puppet Task Name: delete_vm
# Validate that vmid exists
vmidcheck=$(qm list | grep "$PT_vmid")
if [ -n "$vmidcheck" ]; then
    qm destroy $PT_vmid --destroy-unreferenced-disks --purge --skiplock
    exit 0
else
    echo "VMID not found"
    exit 1
fi