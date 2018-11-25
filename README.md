Kernel Config
-------------

Build in kernel command line had serial port config




SD Image
--------

Directory contents.

    U-Boot> fatls mmc 0
       470904   u-boot.bin
        52116   bootcode.bin
         6653   fixup.dat
         2618   fixup_cd.dat
         9884   fixup_db.dat
         9884   fixup_x.dat
      2843876   start.elf
       675748   start_cd.elf
      5104580   start_db.elf
      4044100   start_x.elf
           18   config.txt

    11 file(s), 0 dir(s)


The config.txt has a single line indicating to load uboot as the kernel

    / # cat /boot/config.txt
    kernel=u-boot.bin


Or, when running on a rpi3 with the mini-uart mapped as the console.

    / # cat /boot/config.txt
    kernel=u-boot.bin
    enable_uart=1

Be sure to add "8250.nr_uarts=1 console=ttyS0,115200" to the kernel
command line.



U-Boot fit configuration
------------------------

Each board board sets up fit_conf.
