#!/bin/sh
# Puppet Task Name: create_template
if [ "$PT_vmid" -lt "100" ]; then
    echo "vmid Must be <= 100"
    exit 1
fi

# Validate that vmid is unique
vmidcheck=$(qm list | grep "$PT_vmid")
if [ -z "$vmidcheck" ]; then
    # Check if image is present, if not delete it
    IMGFILE=/tmp/focal-server-cloudimg-amd64.img
    if [ ! -f "$IMGFILE" ]; then
        # Download latest image
        wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img -P /tmp/
    fi

    # Install qemu agent into image
    virt-customize -a /tmp/focal-server-cloudimg-amd64.img --install qemu-guest-agent

    # Create virtual machine
    qm create $PT_vmid --memory 2048 --core 1 --name tpe-ubuntu-focal --net0 virtio,bridge=vmbr0

    # Import the downloaded image
    qm importdisk $PT_vmid /tmp/focal-server-cloudimg-amd64.img local-lvm

    # Attach the new disk to the vm
    qm set $PT_vmid --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$PT_vmid-disk-0

    # Add a cloud init drive to VM
    qm set $PT_vmid --ide2 local-lvm:cloudinit

    # Make the cloud init drive bootable
    qm set $PT_vmid --boot c --bootdisk scsi0

    # Add serial console
    qm set $PT_vmid --serial0 socket --vga serial0

    # Enable qemu agent
    qm set $PT_vmid --agent enabled=1

    # Convert to template
    qm template $PT_vmid

    exit 0
else
    echo "vmid $PT_vmid already exists"
    exit 1
fi