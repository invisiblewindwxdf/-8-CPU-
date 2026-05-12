# coding=utf-8

# 该文件是微指令码生成器
# 生成的每一条指令都是16位的
# 这里面的指令最终在运行时进行解码为32位的控制信号
import os
import pin
import assembly as ASM

dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, 'micro.bin')

micro = [pin.HLT for _ in range(0x10000)]

CJMPS = {ASM.JO, ASM.JNO, ASM.JZ, ASM.JNZ, ASM.JP, ASM.JNP}


def compile_addr2(addr, ir, psw, index):
    global micro
    # 二地址指令的通式：
    # 1xxx[aa][bb]
    # 此处取出1xxx
    # 此处op取前四位显得多余，但是在
    # 在assembly文件中规定的INSTRUCTIONS中，
    # 即使疫情确定了是二地址的情况下各个二地址指令的
    # 字典钥匙依然包含了二地址指令的标识
    # 因此查询时即使在二地址指令的子字典中依然要包含最高表示位
    # 这样设计减少了阅读难度吧
    # 但一定要明白前四位中此时最看重的是前四位中的后三位！！！
    op = ir & 0xf0
    
    # 取[aa]
    amd = (ir >> 2) & 3
    # 取[bb]
    ams = ir & 3

    # 取出指令集中二地址指令集的字典
    INST = ASM.INSTRUCTIONS[2]
    if op not in INST:
        micro[addr] = pin.CYC
        return
    am = (amd, ams)
    if am not in INST[op]:
        micro[addr] = pin.CYC
        return

    EXEC = INST[op][am]
    if index < len(EXEC):
        micro[addr] = EXEC[index]
    else:
        micro[addr] = pin.CYC


def get_condition_jump(exec, op, psw):
    overflow = psw & 1
    zero = psw & 2
    parity = psw & 4

    if op == ASM.JO and overflow:
        return exec
    if op == ASM.JNO and not overflow:
        return exec
    if op == ASM.JZ and zero:
        return exec
    if op == ASM.JNZ and not zero:
        return exec
    # parity 奇偶性
    if op == ASM.JP and parity:
        return exec
    if op == ASM.JNP and not parity:
        return exec
    return [pin.CYC]


def get_interrupt(exec, op, psw):
    interrupt = psw & 8
    if interrupt:
        return exec
    return [pin.CYC]


def compile_addr1(addr, ir, psw, index):
    global micro
    global CJMPS

    # 一地址指令的标准型是：
    # 01xxxx[aa]
    # 0xfc为0b11111100
    # 也就是取出其操作码
    op = ir & 0xfc
    # 获取操作数[aa]
    amd = ir & 3

    INST = ASM.INSTRUCTIONS[1]
    if op not in INST:
        micro[addr] = pin.CYC
        return

    if amd not in INST[op]:
        micro[addr] = pin.CYC
        return
 
    EXEC = INST[op][amd]
    if op in CJMPS:
        EXEC = get_condition_jump(EXEC, op, psw)
    if op == ASM.INT:
        EXEC = get_interrupt(EXEC, op, psw)

    if index < len(EXEC):
        micro[addr] = EXEC[index]
    else:
        micro[addr] = pin.CYC


def compile_addr0(addr, ir, psw, index):
    global micro

    op = ir

    INST = ASM.INSTRUCTIONS[0]
    if op not in INST:
        micro[addr] = pin.CYC
        return

    EXEC = INST[op]
    if index < len(EXEC):
        micro[addr] = EXEC[index]
    else:
        micro[addr] = pin.CYC


for addr in range(0x10000):
    # 地址前八位代表的指令
    ir = addr >> 8
    # 地址中的5到8位对应的CPU实时管理的程序状态字
    psw = (addr >> 4) & 0xf
    # 地址1到4位所对应的微指令所处的周期值(16个周期，因此值从0x0到0xf即0到15)
    cyc = addr & 0xf

    addr2 = ir & (1 << 7)
    addr1 = ir & (1 << 6)

    if addr2:
        if cyc < len(ASM.FETCH2):
            micro[addr] = ASM.FETCH2[cyc]
            continue
        index = cyc - len(ASM.FETCH2)
        compile_addr2(addr, ir, psw, index)
    elif addr1:
        if cyc < len(ASM.FETCH1):
            micro[addr] = ASM.FETCH1[cyc]
            continue
        index = cyc - len(ASM.FETCH1)
        compile_addr1(addr, ir, psw, index)
    else:
        if cyc < len(ASM.FETCH0):
            micro[addr] = ASM.FETCH0[cyc]
            continue
        index = cyc - len(ASM.FETCH0)
        compile_addr0(addr, ir, psw, index)


with open(filename, 'wb') as file:
    for var in micro:
        # 小端序是把高位写到低地址
        # 之所以用小端序是因为模拟软件中读取文件使用的是小端序
        # 且读取时候每n个字节为一组，n看实际模拟的内存的单元含n个字节
        # 很明显此为4
        value = var.to_bytes(4, byteorder='little')
        file.write(value)

print('Compile micro instruction finish!!!')
