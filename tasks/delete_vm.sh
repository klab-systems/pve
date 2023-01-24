#!/bin/sh

# Puppet Task Name: delete_vm
# Validate that vmid exists
vmidcheck=$(qm list | grep "$PT_vmid")
if [ -n "$vmidcheck" ]; then
    qm destroy $PT_vmid --destroy-unreferenced-disks --purge --skiplock
else
    echo "VMID not found"
fi