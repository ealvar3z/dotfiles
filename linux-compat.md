To enable Linux compatibility in NetBSD, you need to load the Linux emulation kernel module and install the necessary Linux runtime libraries (typically from openSUSE via pkgsrc). [1, 2] 
Here are the exact steps to get it running:
1. Load the Linux Compatibility Module
Load the kernel module dynamically using modload: [2] 

modload compat_linux

To enable it permanently on boot, add compat_linux to your rc.conf by running:

sysrc -f /etc/rc.conf linux_enable=YES

2. Install Linux Shared Libraries
Most Linux binaries require shared libraries to function. The easiest way to get these is by using NetBSD's package manager (pkgsrc) to install pre-packaged versions of Linux libraries (e.g., from openSUSE). [1] 
If you are running a 64-bit system, install the base 64-bit emulation package: [1, 3] 

pkgin install suse15_base

(Note: If you are running a 32-bit system or need to run 32-bit binaries on a 64-bit system, install suse15_32 instead). [3] 
3. Mount the Linux procfs
Many Linux binaries expect a Linux-specific /proc filesystem and will crash without it.
Mount it manually: [2] 

mount_procfs procfs /emul/linux/proc

To mount it automatically on every boot, add this line to your /etc/fstab: [2] 

procfs /emul/linux/proc procfs ro 0 0

Once these steps are complete, the NetBSD kernel will automatically detect if an executable is a Linux binary and translate the system calls on the fly. [1, 4] 
Could you tell me which specific Linux application or binary you are trying to run? I can help you check for any missing dependencies or specialized configuration flags it might require.

[1] [https://www.netbsd.org](https://www.netbsd.org/docs/guide/en/chap-linux.html)
[2] [https://man.netbsd.org](https://man.netbsd.org/compat_linux.8)
[3] [https://www.reddit.com](https://www.reddit.com/r/NetBSD/comments/183s764/netbsd_linux_compatibility_layer_running_python/)
[4] [https://www.netbsd.org](https://www.netbsd.org/docs/compat.html)

