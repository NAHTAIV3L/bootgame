BIN=game.img

build: boot.asm
	nasm -f bin $^ -o $(BIN)

run:
	qemu-system-x86_64 -m 65M -drive format=raw,file=$(BIN),media=disk
