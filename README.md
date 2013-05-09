RolfOS
======

Yeah, so, RolfOS is a pretty tiny and basic 16-bit Operating System running on any(?) x86 CPU. To compile it, you'll need NASM and cdrutils. I suggest qemu for testing. Look into the Makefile for more Information 'bout that.

Writing Programs
----------------
To write a Program for RolfOS, simple create a .asm file named after your programs name in source/programs. It will automagically get compiled by make when you run make. You neede to include the rolfos.inc file to get access to the system functions. I'll write a documentation about that soon.
