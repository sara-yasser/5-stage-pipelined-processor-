import re    # regular expression
#To convert decimal to binary
from numpy import binary_repr as br
import os


# Dictionary of supported opcodes
opcode = {}

# Group 1
opcode['LDD'] = '0000'
opcode['LDD1'] = '0001'
opcode['STD'] = '0010'
opcode['STD1'] = '0011'
opcode['SHL'] = '0100'
opcode['SHL1'] = '0101'
opcode['SHR'] = '0110'
opcode['SHR1'] = '0111'
opcode['LDM'] = '1000'
opcode['LDM1'] = '1001'
opcode['IADD'] = '1010'
opcode['IADD1'] = '1011'
opcode['OR'] = '1100'
opcode['AND'] = '1101'
opcode['SWAP'] = '1110'
opcode['SUB'] = '1111'
opcode['ADD'] = '1111'

# opcode['follow'] = '1111'

# Group 2
opcode['NOT'] = '1111'
opcode['INC'] = '1111'
opcode['DEC'] = '1111'
opcode['OUT'] = '1111'
opcode['IN'] = '1111'
opcode['NOP'] = '1111'
# opcode['NOP1'] = '1111'
# opcode['NOP2'] = '1111'
opcode['PUSH'] = '1111'
opcode['POP'] = '1111'
opcode['PUSH'] = '1111'
opcode['RET'] = '1111'
opcode['CALL'] = '1111'
opcode['RTI'] = '1111'
opcode['JZ'] = '1111'
opcode['JMP'] = '1111'

# Registers
reg = {}

reg['R0'] = '000'
reg['R1'] = '001'
reg['R2'] = '010'
reg['R3'] = '011'
reg['R4'] = '100'
reg['R5'] = '101'
reg['R6'] = '110'
reg['R7'] = '111'

# last 6 bits
lastbits = {}

lastbits['SUB'] = '11'
lastbits['ADD'] = '10'
# group 2
lastbits['NOT'] = '000000'
lastbits['INC'] = '000100'
lastbits['DEC'] = '001000'
lastbits['OUT'] = '001100'
lastbits['IN'] = '010000'
lastbits['NOP'] = '011100'
# lastbits['NOP1'] = '011000'
# lastbits['NOP2'] = '011100'
lastbits['PUSH'] = '100000'
lastbits['POP'] = '100100'
# lastbits['NOP3'] = '101000'
lastbits['CALL'] = '110000'
lastbits['RET'] = '110100'
lastbits['RTI1'] = '010100'
lastbits['RTI2'] = '011000'
lastbits['JZ'] = '111000'
lastbits['JMP'] = '111100'
################################################################
address = ['']*4096
################################################################
def appendAddress(addr, outputIR):
    address[addr] = outputIR
################################################################
#Read input and clean it

# inputFileName = "input.txt"
inputFileName = input()
lines = []

#output instructions (Assembeled instructions)
output = []

#Program counter
pc = 0

#Table to save labels
labelsTable = {}
#Table to save variables
variableTable = {}

outputIR = ''

###############################################################
# read from file
with open(inputFileName, "r") as file:
    try:
        i = 0
        for line in file:
            #if it's an empty line, skip it
            if line == "\n":
                continue
                
            #remove all leading/trailing spaces
            line = line.strip()
            
            #if it's a commented line, skip it
            print("lineeeee", line)
            if line[0] == '#':
                continue
                
            #if line has comment in the end
            if '#' in line:
                line = line[:line.index('#')]
                line = line.strip()
            
            #insert instruction to list of instructions
            text = re.split('[,\s]',line.lower())
            # remove any extra spaces
            liness = []
            liness = text.copy()
            for i in range (0, len(text)):
                if text[i] == '':
                    liness.remove('')
            text = liness.copy()

            lines.append(text)
                
            #if line has/is label
            if ':' in lines[-1][0]:
                #is label
                if(len(lines[-1]) == 1):
                    pass
                else: #label then instruction, split it
                    lines.insert(-1,[lines[-1][0]])
                    del(lines[-1][0])
            
    except ValueError as err:
        print(err.args[0])
######################################################################
for i in range (len(lines)):
    print(lines[i])
#Main of assember
addr = -1
for instruction in lines:

    if instruction[0][-1] == ':': #it's label
        labelsTable[instruction[0][:-1]] = pc
        
    elif instruction[0] == 'define': #it's variable (ex:define n 5)
        if instruction[1] in variableTable:
            raise ValueError('Variable redefinition')
        else:
            variableTable[instruction[1]]=pc
            output.append(br(int(instruction[2]),16))
        
    else:
        myInstr = str(instruction[0]).upper()
        print(myInstr)
        
        myReg = ''
        myReg2 = ''
        myReg3 = ''
        
        if (len(instruction) > 1):
            myReg = str(instruction[1]).upper()
            if len(myReg) > 2:
                for i in range (0, len(myReg)):
                    if (myReg[i] == 'R'):
                        myReg = myReg[i] + myReg[i + 1]
                        break
            print(myReg)
        if (len(instruction) > 2):
            myReg2 = str(instruction[2]).upper()
            if len(myReg2) > 2:
                for i in range (0, len(myReg2)):
                    if (myReg2[i] == 'R'):
                        myReg2 = myReg2[i] + myReg2[i + 1]
                        break
            print(myReg2)
        if (len(instruction) > 3):
            myReg3 = str(instruction[3]).upper()
            if len(myReg3) > 2:
                for i in range (0, len(myReg3)):
                    if (myReg3[i] == 'R'):
                        myReg3 = myReg3[i] + myReg3[i + 1]
                        break
            print(myReg3)

        if (myInstr == '.ORG'):
            addr = int(instruction[1]) - 1
            continue
        else:
            addr += 1
        
        if myInstr in opcode:
            
            # if LDD, STD
            if (myInstr == 'LDD') or (myInstr == 'STD'):
                outputIR = ''
                outputIR += opcode[myInstr]
                # outputIR += reg[myReg]
                # instruction[2][:9]
                hex2bin = bin(int(instruction[2], 16))
                insert_num = hex2bin[2:]
                while len(insert_num) < 20:
                    insert_num = '0' + insert_num
                outputIR += insert_num[:12]
                output.append(str(addr) + " " + outputIR)
                appendAddress(addr, outputIR)
                addr += 1

                outputIR = ''
                outputIR += opcode[(myInstr+'1')]
                # instruction[2][9:]
                outputIR += reg[myReg]
                outputIR += insert_num[12:]
                outputIR += '0'
                output.append(outputIR)
                appendAddress(addr, outputIR)
                
            
            elif (myInstr == 'IADD'):
                outputIR = ''
                outputIR += opcode[myInstr]
                # outputIR += reg[myReg]
                # outputIR += reg[myReg2]
                # instruction[3][:6]
                hex2bin = bin(int(instruction[3], 16))
                insert_num = hex2bin[2:]
                while len(insert_num) < 16:
                    insert_num = '0' + insert_num
                outputIR += insert_num[:12]
                output.append(outputIR)
                appendAddress(addr, outputIR)
                addr += 1
                

                outputIR = ''
                outputIR += opcode[(myInstr+'1')]
                # instruction[3][6:]
                outputIR += reg[myReg]
                outputIR += reg[myReg2]
                outputIR += insert_num[12:]
                outputIR += '00'
                output.append(outputIR)
                appendAddress(addr, outputIR)
                
                
            elif (myInstr == 'SHR') or (myInstr == 'SHL') or (myInstr == 'LDM'):
                outputIR = ''
                outputIR += opcode[myInstr]
                # outputIR += reg[myReg]
                # instruction[2][:9]
                hex2bin = bin(int(instruction[2], 16))
                insert_num = hex2bin[2:]
                while len(insert_num) < 16:
                    insert_num = '0' + insert_num
                outputIR += insert_num[:12]
                output.append(outputIR)
                appendAddress(addr, outputIR)
                addr += 1
                

                outputIR = ''
                outputIR += opcode[(myInstr+'1')]
                # instruction[2][9:]
                outputIR += reg[myReg]
                outputIR += insert_num[12:]
                outputIR += '00000'
                output.append(outputIR)
                appendAddress(addr, outputIR)

                
            elif (myInstr == 'ADD') or (myInstr == 'SUB') or (myInstr == 'AND') or (myInstr == 'OR'):
                outputIR = ''
                outputIR += opcode[myInstr]
                outputIR += reg[myReg]
                outputIR += reg[myReg2]
                outputIR += reg[myReg3]
                if (myInstr in lastbits):
                    outputIR += '0' + lastbits[myInstr]
                else:
                    outputIR += '000'
                output.append(outputIR)
                appendAddress(addr, outputIR)
                
            elif (myInstr == 'SWAP'):
                outputIR = ''
                outputIR += opcode[myInstr]
                outputIR += reg[myReg]
                outputIR += reg[myReg2]
                if (myInstr in lastbits):
                    outputIR += '0' + lastbits[myInstr]
                else:
                    outputIR += '000000'
                output.append(outputIR)
                appendAddress(addr, outputIR)
            
            # Group 2
            elif (myInstr == 'PUSH') or (myInstr == 'POP') or (myInstr == 'NOT') or (myInstr == 'INC') or (myInstr == 'DEC') or (myInstr == 'IN') or (myInstr == 'OUT') or (myInstr == 'JZ') or (myInstr == 'JMP') or (myInstr == 'CALL'):
                outputIR = ''
                outputIR += opcode[myInstr]
                outputIR += reg[myReg]
                outputIR += '000' + lastbits[myInstr]
                output.append(outputIR)
                appendAddress(addr, outputIR)
            
            elif (myInstr == 'RET') or (myInstr == 'NOP'):
                outputIR = ''
                outputIR += opcode[myInstr]
                outputIR += '000000' + lastbits[myInstr]
                output.append(outputIR)
                appendAddress(addr, outputIR)
            
            elif (myInstr == 'RTI'):
                outputIR = ''
                outputIR += opcode[myInstr]
                outputIR += '000000' + lastbits[myInstr + '1']
                output.append(outputIR)
                appendAddress(addr, outputIR)

                addr += 1

                outputIR = ''
                outputIR += opcode[myInstr]
                outputIR += '000000' + lastbits[myInstr + '2']
                output.append(outputIR)
                appendAddress(addr, outputIR)

        else:
            myInstr = int(instruction[0])
            if myInstr < 4095:
                myInstr = bin(myInstr)
                myInstr = myInstr[2:]
                for i in range(len(myInstr), 16):
                    myInstr = "0" + myInstr
                appendAddress(addr, myInstr)
                addr += 1
                appendAddress(addr, "0000000000000000")
                
            
           
        

        # else:
        #      raise ValueError('Undefined instruction')
                
    pc = len(output)
    
outputFileName = "output.txt"
# with open(outputFileName, "w") as file:
#     for line in output:
#         file.write(line + os.linesep)

with open(outputFileName, "w") as file:
    index = 0
    for line in address:
        idx = hex(index)
        idx = idx[2:]
        if(len(idx) == 1):
            idx = "00" + idx
        elif len(idx) == 2:
            idx = "0" + idx

        if (line != ""):
            string = idx + " " + line
            file.write(string + os.linesep)
        else:
            string = idx + " " + "XXXXXXXXXXXXXXXX"
            # string = idx + " " + "0000000000000000"
            file.write(string + os.linesep)
        index += 1
        
