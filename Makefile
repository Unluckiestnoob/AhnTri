#######################################################################################################################################################
all: make_deafult

#Makes everything up
make_deafult: bboot atclib kernel ccalc irq timer advset cbot cal credit art artii fishdic game notes osver keychar gdt idt fsa ld buildgrub clean

#Build kernel main image
kernel: main.c
	gcc -m32 -c main.c -o image.o -std=gnu99 -ffreestanding -O1 -Wall -Wextra 
#Link everything up
ld: linker.ld linker.ld clib.o image.o irq.o irq_s.o timer.o ccalc.o advset.o cbot.o isr.o cal.o art.o artii.o notes.o osver.o fishdic.o credit.o game.o char.o boot.o gdt.o load_gdt.o idt.o load_idt.o fs.o
	ld -m elf_i386 -T linker.ld clib.o image.o irq.o irq_s.o timer.o advset.o ccalc.o cbot.o isr.o cal.o art.o artii.o notes.o osver.o fishdic.o credit.o game.o char.o boot.o gdt.o load_gdt.o idt.o load_idt.o fs.o -o ATOS1.bin -nostdlib

#Build ISO file via grub
buildgrub: ATOS1.bin
	grub-file --is-x86-multiboot ATOS1.bin
	mkdir -p rpc_isodir/boot/grub
	cp ATOS1.bin rpc_isodir/boot/ATOS1.bin
	cp grub.cfg rpc_isodir/boot/grub/grub.cfg
	grub-mkrescue -o atos_rpc.iso rpc_isodir

#Run it in QEMU
qemu: atos_rpc.iso
	qemu-system-i386 -cdrom atos_rpc.iso

#######################################################################################################################################################
atclib: libc/atclib.c
	gcc -m32 -c libc/atclib.c -o clib.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

irq: arch/i386/irq.c arch/i386/irq.s
	gcc -m32 -c arch/i386/irq.c -o irq.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	as --32 arch/i386/irq.s -o irq_s.o

#Build GDT
gdt: arch/i386/gdt.c arch/i386/load_gdt.s
	gcc -m32 -c arch/i386/gdt.c -o gdt.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	as --32 arch/i386/load_gdt.s -o load_gdt.o

#Build IDT
idt: arch/i386/idt.c arch/i386/load_idt.s
	gcc -m32 -c arch/i386/idt.c -o idt.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	as --32 arch/i386/load_idt.s -o load_idt.o
	as --32 arch/i386/isr.s -o isr.o

timer: drivers/timer.c
	gcc -m32 -c drivers/timer.c -o timer.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

ccalc: kapps/ccalcfi.c
	gcc -m32 -c kapps/ccalcfi.c -o ccalc.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

advset: kapps/advset.c
	gcc -m32 -c kapps/advset.c -o advset.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

notes: kapps/notes.c
	gcc -m32 -c kapps/notes.c -o notes.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

osver: kapps/osver.c
	gcc -m32 -c kapps/osver.c -o osver.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

cbot: kapps/cbot.c
	gcc -m32 -c kapps/cbot.c -o cbot.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

cal: kapps/cal.c
	gcc -m32 -c kapps/cal.c -o cal.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

art: kapps/art.c
	gcc -m32 -c kapps/art.c -o art.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

artii: kapps/artii.c
	gcc -m32 -c kapps/artii.c -o artii.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

fishdic: kapps/fishdic.c
	gcc -m32 -c kapps/fishdic.c -o fishdic.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

credit: kapps/credit.c
	gcc -m32 -c kapps/credit.c -o credit.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

game: kapps/game.c
	gcc -m32 -c kapps/game.c -o game.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	
fsa: fs/fs.c
	gcc -m32 -c fs/fs.c -o fs.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

#Assemble gru(bboot)loader
bboot: boot/boot.s
	as --32 boot/boot.s -o boot.o

#Build Keychar drivers
keychar: drivers/kb/char.c
	gcc -m32 -c drivers/kb/char.c -o char.o -std=gnu99 -ffreestanding -O1 -Wall -Wextra 

clean:
	rm *.o
#######################################################################################################################################################

#Makes VMPC up
vmpc: bboot kernel_vmpc ccalc advset cbot cal art artii fishdic credit game notes osver keychar gdt idt ld_vm buildgrub_vmpc clean

#Build kernel main image
kernel_vmpc: os_vmpc.c
	gcc -m32 -c os_vmpc.c -o imagei.o -std=gnu99 -ffreestanding -O1 -Wall -Wextra 

#Link everything up
ld_vm: linker.ld linker.ld imagei.o ccalc.o advset.o cbot.o cal.o artii.o notes.o osver.o fishdic.o credit.o game.o char.o boot.o gdt.o load_gdt.o idt.o load_idt.o
	ld -m elf_i386 -T linker.ld imagei.o ccalc.o advset.o cbot.o cal.o artii.o notes.o osver.o credit.o fishdic.o game.o utils.o char.o boot.o gdt.o load_gdt.o idt.o load_idt.o -o ATOS2.bin -nostdlib

#Build ISO file via grub
buildgrub_vmpc: ATOS2.bin
	grub-file --is-x86-multiboot ATOS2.bin
	mkdir -p vmpc_isodir/boot/grub
	cp ATOS2.bin vmpc_isodir/boot/ATOS2.bin
	grub-mkrescue -o atos_vmpc.iso vmpc_isodir

#Run it in QEMU
qemu_vmpc: atos_vmpc.iso
	qemu-system-i386 -cdrom atos_vmpc.iso

#######################################################################################################################################################
