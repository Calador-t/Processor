def to_opcode(opcode):
    if opcode == "add":
        return "0000000"
    if opcode == "sub":
        return "0000001"
    if opcode == "mul":
        return "0000010"
    if opcode == "ldb":
        return "0010000"
    if opcode == "ldh":
        return "0010001"
    if opcode == "ldw":
        return "0010010"
    if opcode == "stb":
        return "0010011"
    if opcode == "sth":
        return "0010100"
    if opcode == "stw":
        return "0010101"
    if opcode == "mov":
        return "0010110"
    if opcode == "li":
        return "0010111"
    if opcode == "beq":
        return "0110000"
    if opcode == "jump":
        return "0110001"
    if opcode == "tlbwrite":
        return "0110010"
    if opcode == "iret":
        return "0110011"
    raise SystemExit("Error: No opcode")

def inst_type(oc):
	if oc == "add" or oc == "sub" or oc == "mul":
		return "R"
	if oc == "ldb" or oc == "lhd" or oc == "ldw" or oc == "li" or oc == "stb" or oc == "sth" or oc == "stw" or oc == "mov":
		return "M"
	if oc == "beq" or oc == "jump" or oc == "tlbwrite" or oc == "iret":
		return "B"	

def to_reg(reg, it):
	if reg[0:1] == "r":
		bits = '{0:05b}'.format(int(reg[1:]))
		return bits

def to_offset(offset, it):
	if it != "M":
		raise SystemExit("Error: Offset only for type M instr.")
	bits = '{0:015b}'.format(int(offset))
	return bits

def to_big_offset(offset, it):
	if it != "B":
		raise SystemExit("Error: Offset only for type M instr.")
	bits = '{0:020b}'.format(int(offset))
	return bits

# --------------------
# ---  Code Start  ---
# --------------------
import sys
import os

file_path = "code.txt"
if len(sys.argv) >= 2 and sys.argv[1] != "":
	file_path = sys.argv[1]
print("From " + file_path + ":")
file = open(file_path, 'r+')
if not os.path.exists('asmbl.bin'):
    os.mknod('ambl.bin')
target_file = open('asmbl.bin', 'w');


for line in file:
    # Print each line
    print(line[:-1])
    words = line.split()
    # instruction name
    oc = ""
    # Type of instruction (M, R B)
    it = ""
    binary = ""
    src1 = ""
    src2 = ""
    dst = ""
    offset = ""
    big_offset = ""
    for i, word in enumerate(words):
        if i == 0:
            oc = word
            it = inst_type(word)
            binary += to_opcode(word)
        if i == 1:
            if oc == "li":
                print(word)
                src1 = '{0:020b}'.format(int(word))
                print(src1)
            else:
                src1 = to_reg(word, i)
        if i == 2:
            if oc == "mov" or oc == "li":
                dst = to_reg(word, it)
                if oc == "mov":
                    offset = to_offset("0", it)
                break
            if it == "R":
                src2 = to_reg(word, it)
            elif it == "M":
                offset = to_offset(word, it)
            elif it == "B":
                big_offset = to_big_offset(word, it)
                dst = big_offset[0:5]
                offset = big_offset[5:]
        if i == 3:
            if it == "B":
                raise SystemExit("Error: oc not 7b: " + line)
            dst = to_reg(word, it)
    # --- Make result string ---
    if len(binary) != 7:
    	raise SystemExit("Error: oc not 7b: " + line)
    binary += dst
    binary += src1
    	
    if it == "R":
    	binary += src2 + "0000000000"
    elif it == "M" or it == "B":
    	binary += offset
    
    if len(src1) != 5 and oc != "li":	
    	raise SystemExit("Error: src1 not 5b: " + line)
    if it == "R" and len(src2) != 5:	
    	raise SystemExit("Error: src2 not 5b: " + line)
    if len(dst) != 5:	
    	raise SystemExit("Error: dst not 5b: " + line)
    if it == "M" and oc != "li" and len(offset) != 15:	
    	raise SystemExit("Error: offset not 15b: " + line)
    if it == "B" and len(big_offset) != 20:	
    	raise SystemExit("Error: big_offset not 20b: " + line + " big_offset: " + big_offset)
    print(len(binary))
    if len(binary) != 32:	
    	raise SystemExit("Error: Code for inst " + line + " not 32 bits long")
    if it == "R":
    	print(binary[0:7] + "|" + binary[7:12] + "|" + binary[12:17] + "|" + binary[17:22] + "|" + binary[22:])
    else:
    	print(binary[0:7] + "|" + binary[7:12] + "|" + binary[12:17] + "|" + binary[17:])
    print(binary)
    target_file.write(binary + "\n")
    print("")


