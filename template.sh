# 1. Inject QEMU guest agent, clean machine-id and cloud-init state
virt-customize -a noble-server-cloudimg-amd64.qcow2 \
  --install qemu-guest-agent \
  --run-command 'systemctl enable qemu-guest-agent' \
  --run-command 'truncate -s 0 /etc/machine-id' \
  --run-command 'rm -f /var/lib/dbus/machine-id' \
  --run-command 'cloud-init clean' \
  --run-command 'rm -f /etc/udev/rules.d/70-persistent-net.rules'

# 2. Expand the image to 32GB (before import)
qemu-img resize noble-server-cloudimg-amd64.qcow2 32G

# 3. Create the VM shell
qm create 901 --name noble24-cloudinit --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0

# 4. Import the Ubuntu disk
qm importdisk 901 noble-server-cloudimg-amd64.qcow2 local-lvm

# 5. Attach the imported disk and set SCSI controller
qm set 901 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-901-disk-0

# 6. Add cloud-init drive
qm set 901 --ide2 local-lvm:cloudinit

# 7. Set boot options
qm set 901 --boot c --bootdisk scsi0

# 8. Add serial console for cloud images
qm set 901 --serial0 socket --vga serial0

# 9. Enable QEMU guest agent in Proxmox
qm set 901 --agent enabled=1

# 10. Set CPU type to 'host'
qm set 901 --cpu host

#Set username, password, ssh key, dhcp settings in proxmox UI.

# 11. (Optional) Set SSH key for cloud-init
qm set 901 --sshkey /root/.ssh/id_rsa.pub

# 12. (Optional) Set default cloud-init user and password
qm set 901 --ciuser darius --cipassword 'yourpassword'

# 13. Convert the VM to a template
qm template 901
