+++
title = "Windows 10 KVM Single-GPU Passthrough (Outdated)"
tags = ["virtualization","kvm","windows","linux"]
date = "2020-05-18"
+++
## This guide is outdated and ended up being incomplete.
## Note: This is here as notes and shouldn't be taken as a direct guide.

# Table of Contents
{{< table_of_contents >}}

---
### Host Specs
{{< highlight txt >}}
CPU: AMD Ryzen 5 3600  
GPU: NVIDIA GeForce GTX 1060 6GB  
Motherboard: MSI B450 Tomahawk Max  
OS: Garuda Linux: Spotted-Eagle
Kernel: 5.12.3-zen1-1-zen  
Memory: 16GB  
{{< /highlight >}}

### Final VM Configuration
{{< highlight txt >}}
CPU: 4 Cores, 8 Threads
GPU: NVIDIA GeForce GTX 1060 6GB  
Memory: 10GB
Chipset: Q35
Firmware: OVMF
PCI Passthrough: Advanced Micro Devices, Inc. [AMD] 400 Series Chipset USB 3.1 XHCI Controller
PCI Passthrough: Advanced Micro Devices, Inc. [AMD] Matisse USB 3.0 Host Controller
{{< /highlight >}}

### Extra Kernal Arguements
{{< highlight txt >}}
video:vesafb=off video:efifb=off amd_iommu=on iommu=pt iommu=1 pcie_acs_override=downstream,multifunction
{{< /highlight >}}

### Nvidia GPU VFIO patch (This is required on 10XX Series)
Original bios downloaded from: https://www.techpowerup.com/vgabios/  
[NVIDIA vBIOS VFIO Patcher](https://github.com/Matoking/NVIDIA-vBIOS-VFIO-Patcher)
{{< highlight bash >}}
git clone https://github.com/Matoking/NVIDIA-vBIOS-VFIO-Patcher
cd NVIDIA-vBIOS-VFIO-Patcher
python nvidia_vbios_vfio_patcher.py -i /home/phoenix/download/gtx1060.rom -o ./gtx1060-patched.rom
cp ./gtx1060-patched.rom /usr/share/vgabios/gtx1060-patched.rom
{{< /highlight >}}

#### Make sure Bar is toggled, Pass the file for the rom, and the second address contains multifunction='on'
{{< highlight xml >}}
<hostdev mode='subsystem' type='pci' managed='yes'>
  <source>
    <address domain='0x0000' bus='0x26' slot='0x00' function='0x0'/>
  </source>
  <rom bar='on' file='/usr/share/vgabios/gtx1060-patched.rom'/>
  <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0' multifunction='on'/>
</hostdev>
{{< /highlight >}}

### VM Networking
**Scripts**  
[macvlan.sh](/posts/windows10-kvm/macvlan/)  
[macvlan.service](/posts/windows10-kvm/macvlan-service/)  

**Virt-Manager Settings**  
![Virt-Manager-Networking](/posts/windows10-kvm/images/network.png)

### CPU Settings
{{< highlight xml >}}
<cputune>
  <vcpupin vcpu='0' cpuset='2'/>
  <vcpupin vcpu='1' cpuset='8'/>
  <vcpupin vcpu='2' cpuset='3'/>
  <vcpupin vcpu='3' cpuset='9'/>
  <vcpupin vcpu='4' cpuset='4'/>
  <vcpupin vcpu='5' cpuset='10'/>
  <vcpupin vcpu='6' cpuset='5'/>
  <vcpupin vcpu='7' cpuset='11'/>
  <emulatorpin cpuset='0-1,6-7'/>
</cputune>
{{< /highlight >}}
{{< highlight xml >}}
  <cpu mode='host-passthrough' check='none' migratable='off'>
    <topology sockets='1' dies='1' cores='4' threads='2'/>
    <cache mode='passthrough'/>
    <feature policy='require' name='topoext'/>
  </cpu>
{{< /highlight >}}

### Sata Passthrough

{{< highlight xml >}}
<disk type='block' device='disk'>
  <driver name='qemu' type='raw' cache='none' io='native' discard='unmap'/>
  <source dev='/dev/disk/by-id/ata-....'/>
  <target dev='sda' bus='sata'/>
  <boot order='1'/>
  <address type='drive' controller='0' bus='0' target='0' unit='0'/>
</disk>
{{< /highlight >}}

### Virt-Manager Hardware Overview
![Virt-Manager-Overview](/posts/windows10-kvm/images/hardware-overview.png)
