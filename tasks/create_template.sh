#!/bin/sh
# Puppet Task Name: create_template
if [ "$vmid" -lt "100" ]; then
    echo "vmid Must be <= 100"
    exit 1
fi

# Validate that vmid is unique
vmidcheck=$(qm list | grep $vmid)
if [ -z "$vmidcheck" ]; then
    # Download Cloud Image if needed
    IMGFILE=/tmp/focal-server-cloudimg-amd64.img
    if [ ! -f "$IMGFILE" ]; then
    wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img -P /tmp/
    fi

    # Create virtual machine
    qm create $vmid --memory 2048 --core 1 --name ubuntu-focal --net0 virtio,bridge=vmbr0

    # Import the downloaded image
    qm importdisk $vmid /tmp/focal-server-cloudimg-amd64.img local-lvm

    # Attach the new disk to the vm
    qm set $vmid --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$vmid-disk-0

    # Add a cloud init drive to VM
    qm set $vmid --ide2 local-lvm:cloudinit

    # Make the cloud init drive bootable
    qm set $vmid --boot c --bootdisk scsi0

    # Add serial console
    qm set $vmid --serial0 socket --vga serial0

    # Convert to template
    qm template $vmid

    exit 0
else
    echo "vmid $vmid already exists"
    exit 1
fi