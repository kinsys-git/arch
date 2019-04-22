# arch
Basic arch installer with optional WM/DE install

*Install Guide*
---
1. Boot into the Arch Linux iso
2. Connect to the internet
3. Partition your disks, and remember or write down where you want your mounts
4. Format your partitions - home partition optional (mkfs.ext4 /dev/[PARTITION])
5. Run the following commands:
```
wget https://raw.githubusercontent.com/soripants/arch/master/install.sh
chmod +x install.sh
./install.sh
```

The installer will take you through the rest.

Timezone is automatically set to pacific.

There's plenty of features that could be added, but I'd rather just have a quick and dirty option for those who just are tired of going through all the steps.
