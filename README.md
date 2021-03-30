# Simple "Pet-OS"

I decided to study some low-level programming and the way how exactly the operating system boots.
I am using Bosch Emulator (also QEMU) to test this boot sector.
You can find the configuration file in the repository.
Soon I will repair my old PC and would try to run this code on it.

For now, this program runs in 16bit mode. After some research, I will add the ability to execute programs in 32bit mode.
For now, the main goals are to write some very simple operating system that can communicate with a hard drive, 
that can manipulate files, and maybe execute some simple programs in a single process mode