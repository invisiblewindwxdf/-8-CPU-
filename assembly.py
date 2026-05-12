# coding=utf-8

import pin

# 取指令操作
# 分别把操作数(MOV、JO等等)、目的地址、源地址放入
# 指令寄存器、目的寄存器、源寄存器中
# 我们微指令大多数时候为一进一出

FETCH2 = [
    pin.PC_OUT | pin.MAR_IN,
    pin.RAM_OUT | pin.IR_IN | pin.PC_INC,
    pin.PC_OUT | pin.MAR_IN,
    pin.RAM_OUT | pin.DST_IN | pin.PC_INC,
    pin.PC_OUT | pin.MAR_IN,
    pin.RAM_OUT | pin.SRC_IN | pin.PC_INC,
]

FETCH1 = [
    pin.PC_OUT | pin.MAR_IN,
    pin.RAM_OUT | pin.IR_IN | pin.PC_INC,
    pin.PC_OUT | pin.MAR_IN,
    pin.RAM_OUT | pin.DST_IN | pin.PC_INC,
]

FETCH0 = [
    pin.PC_OUT | pin.MAR_IN,
    pin.RAM_OUT | pin.IR_IN | pin.PC_INC,
]

# 下述这些编号操作完成的事情是：
# 假如一条指令完整长这样：
# MOV A, 5
# 那么此时内存里面有三个字节
# 第一个字节是MOV的操作数
# 即00000000 | 10000000 = 10000000
# 这还没完，这只是定位了MOV指令
# 但是MOV指令是一种二地址指令
# 那么必须有一个地方能区分MOV中的两个地址到底是
# 哪一种寻址方式
# 而二地址指令的区分方式为：
# 1xxx[aa][bb]
# 其中[aa]为两位表示的是前一个地址的寻址方式
# 如果[aa]为[00]则前一个地址是立即数
# 而此例中的是寄存器寻址则此例中[aa]为[01]
# 同理此例中[bb]为[00]
# 综上第一个字节中的数还要或上[aa]左移两位的值和[bb]
# 即10000000 | (1<<2) | 00
# 即 10000100
# 第二个字节是A寄存器的编号:pin文件中为8
# 即：00001000 = 00001000
# 第三个字节是5
# 00000101 = 00000101
# 所以综上，在我们的文件中最终指令MOV A, 5
# 在内存中的值为：
# 10000100 00001000 00000101
# 即：0x84, 0x08, 0x05

MOV = (0 << pin.ADDR2_SHIFT) | pin.ADDR2
ADD = (1 << pin.ADDR2_SHIFT) | pin.ADDR2
SUB = (2 << pin.ADDR2_SHIFT) | pin.ADDR2
CMP = (3 << pin.ADDR2_SHIFT) | pin.ADDR2
AND = (4 << pin.ADDR2_SHIFT) | pin.ADDR2
OR = (5 << pin.ADDR2_SHIFT) | pin.ADDR2
XOR = (6 << pin.ADDR2_SHIFT) | pin.ADDR2
MUT = (7 << pin.ADDR2_SHIFT) | pin.ADDR2

INC = (0 << pin.ADDR1_SHIFT) | pin.ADDR1
DEC = (1 << pin.ADDR1_SHIFT) | pin.ADDR1

NOT = (2 << pin.ADDR1_SHIFT) | pin.ADDR1

LSL = (3 << pin.ADDR1_SHIFT) | pin.ADDR1
LSR = (4 << pin.ADDR1_SHIFT) | pin.ADDR1

JMP = (5 << pin.ADDR1_SHIFT) | pin.ADDR1

JO = (6 << pin.ADDR1_SHIFT) | pin.ADDR1
JNO = (7 << pin.ADDR1_SHIFT) | pin.ADDR1
JZ = (8 << pin.ADDR1_SHIFT) | pin.ADDR1
JNZ = (9 << pin.ADDR1_SHIFT) | pin.ADDR1
JP = (10 << pin.ADDR1_SHIFT) | pin.ADDR1
JNP = (11 << pin.ADDR1_SHIFT) | pin.ADDR1

PUSH = (12 << pin.ADDR1_SHIFT) | pin.ADDR1
POP = (13 << pin.ADDR1_SHIFT) | pin.ADDR1

CALL = (14 << pin.ADDR1_SHIFT) | pin.ADDR1
INT = (15 << pin.ADDR1_SHIFT) | pin.ADDR1

NOP = 0
RET = 1
IRET = 2
STI = 3
CLI = 4
# 最终HLT在内存中也就是0x3f
HLT = 0x3f
OUT = 5
IN = 6
WRITE = 7
READ = 8
MUT32 = 9
DIV32 = 10
INCMSR = 11

INSTRUCTIONS = {
    2: {
        MOV: {
            # MOV A, 5
            (pin.AM_REG, pin.AM_INS): [
                pin.DST_W | pin.SRC_OUT,
            ],
            # MOV A, B
            (pin.AM_REG, pin.AM_REG): [
                pin.DST_W | pin.SRC_R,
            ],
            # MOV A, [5]
            (pin.AM_REG, pin.AM_DIR): [
                pin.SRC_OUT | pin.MAR_IN,
                pin.DST_W | pin.RAM_OUT
            ],
            # MOV A, [B]
            (pin.AM_REG, pin.AM_RAM): [
                pin.SRC_R | pin.MAR_IN,
                pin.DST_W | pin.RAM_OUT
            ],
            # MOV [5], 5
            (pin.AM_DIR, pin.AM_INS): [
                pin.DST_OUT | pin.MAR_IN,
                pin.RAM_IN | pin.SRC_OUT
            ],
            # MOV [5], A
            (pin.AM_DIR, pin.AM_REG): [
                pin.DST_OUT | pin.MAR_IN,
                pin.RAM_IN | pin.SRC_R,
            ],
            # MOV [5], [5]
            (pin.AM_DIR, pin.AM_DIR): [
                pin.SRC_OUT | pin.MAR_IN,
                pin.RAM_OUT | pin.T1_IN,
                pin.DST_OUT | pin.MAR_IN,
                pin.RAM_IN | pin.T1_OUT,
            ],
            # MOV [5], [A]
            (pin.AM_DIR, pin.AM_RAM): [
                pin.SRC_R | pin.MAR_IN,
                pin.RAM_OUT | pin.T1_IN,
                pin.DST_OUT | pin.MAR_IN,
                pin.RAM_IN | pin.T1_OUT,
            ],
            # MOV [A], [5]
            (pin.AM_RAM, pin.AM_INS): [
                pin.DST_R | pin.MAR_IN,
                pin.RAM_IN | pin.SRC_OUT
            ],
            # MOV [A], B
            (pin.AM_RAM, pin.AM_REG): [
                pin.DST_R | pin.MAR_IN,
                pin.RAM_IN | pin.SRC_R,
            ],
            # MOV [A], [5]
            (pin.AM_RAM, pin.AM_DIR): [
                pin.SRC_OUT | pin.MAR_IN,
                pin.RAM_OUT | pin.T1_IN,
                pin.DST_R | pin.MAR_IN,
                pin.RAM_IN | pin.T1_OUT,
            ],
            # MOV [A], [B]
            (pin.AM_RAM, pin.AM_RAM): [
                pin.SRC_R | pin.MAR_IN,
                pin.RAM_OUT | pin.T1_IN,
                pin.DST_R | pin.MAR_IN,
                pin.RAM_IN | pin.T1_OUT,
            ]
        },
        ADD: {
            (pin.AM_REG, pin.AM_INS): [
                pin.DST_R | pin.A_IN,
                pin.SRC_OUT | pin.B_IN,
                pin.OP_ADD | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
            (pin.AM_REG, pin.AM_REG): [
                pin.DST_R | pin.A_IN,
                pin.SRC_R | pin.B_IN,
                pin.OP_ADD | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
        },
        SUB: {
            # 目的地址 - 源地址
            # (目的地址, 源地址)
            (pin.AM_REG, pin.AM_INS): [
                pin.DST_R | pin.A_IN,
                pin.SRC_OUT | pin.B_IN,
                pin.OP_SUB | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
            (pin.AM_REG, pin.AM_REG): [
                pin.DST_R | pin.A_IN,
                pin.SRC_R | pin.B_IN,
                pin.OP_SUB | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
        },
        # 新增乘法
        MUT: {
            (pin.AM_REG, pin.AM_REG): [
                pin.DST_R | pin.A_IN,
                pin.SRC_R | pin.B_IN,
                pin.OP_MTL | pin.ALU_OUT | pin.A_IN | pin.ALU_PSW,
                pin.OP_MTH | pin.ALU_OUT | pin.B_IN | pin.ALU_PSW
            ],
            (pin.AM_REG, pin.AM_INS): [ 
                pin.DST_R | pin.A_IN,
                pin.SRC_OUT | pin.B_IN,
                pin.OP_MTL | pin.ALU_OUT | pin.A_IN | pin.ALU_PSW,
                pin.OP_MTH | pin.ALU_OUT | pin.B_IN | pin.ALU_PSW
            ]
        },
        # 该指令的作用是比较
        # 一般会搭配JZ、JNZ、ＪＯ、JNＯ使用
        CMP: {
            (pin.AM_REG, pin.AM_INS): [
                pin.DST_R | pin.A_IN,
                pin.SRC_OUT | pin.B_IN,
                pin.OP_SUB | pin.ALU_PSW
            ],
            (pin.AM_REG, pin.AM_REG): [
                pin.DST_R | pin.A_IN,
                pin.SRC_R | pin.B_IN,
                pin.OP_SUB | pin.ALU_PSW
            ],
        },
        AND: {
            (pin.AM_REG, pin.AM_INS): [
                pin.DST_R | pin.A_IN,
                pin.SRC_OUT | pin.B_IN,
                pin.OP_AND | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
            (pin.AM_REG, pin.AM_REG): [
                pin.DST_R | pin.A_IN,
                pin.SRC_R | pin.B_IN,
                pin.OP_AND | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
        },
        OR: {
            (pin.AM_REG, pin.AM_INS): [
                pin.DST_R | pin.A_IN,
                pin.SRC_OUT | pin.B_IN,
                pin.OP_OR | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
            (pin.AM_REG, pin.AM_REG): [
                pin.DST_R | pin.A_IN,
                pin.SRC_R | pin.B_IN,
                pin.OP_OR | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
        },
        XOR: {
            (pin.AM_REG, pin.AM_INS): [
                pin.DST_R | pin.A_IN,
                pin.SRC_OUT | pin.B_IN,
                pin.OP_XOR | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
            (pin.AM_REG, pin.AM_REG): [
                pin.DST_R | pin.A_IN,
                pin.SRC_R | pin.B_IN,
                pin.OP_XOR | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
        },
    },
    1: {
        INC: {
            pin.AM_REG: [
                pin.DST_R | pin.A_IN,
                pin.OP_INC | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
        },
        DEC: {
            pin.AM_REG: [
                pin.DST_R | pin.A_IN,
                pin.OP_DEC | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
        },
        NOT: {
            pin.AM_REG: [
                pin.DST_R | pin.A_IN,
                pin.OP_NOT | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
        },
        LSL:{
            pin.AM_REG: [
                pin.DST_R | pin.A_IN,
                pin.OP_LSL | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
            pin.AM_DIR: [
                pin.DST_OUT | pin.A_IN,
                pin.OP_LSL | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
        },
        LSR:{
            pin.AM_REG: [
                pin.DST_R | pin.A_IN,
                pin.OP_LSR | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ],
            pin.AM_DIR: [
                pin.DST_OUT | pin.A_IN,
                pin.OP_LSR | pin.ALU_OUT | pin.DST_W | pin.ALU_PSW
            ]
        },
        JMP: {
            pin.AM_INS: [
                pin.CS_OUT | pin.MSR_IN,
                pin.DST_OUT | pin.PC_IN,
            ],
        },
        JO: {
            pin.AM_INS: [
                pin.CS_OUT | pin.MSR_IN,
                pin.DST_OUT | pin.PC_IN,
            ],
        },
        JNO: {
            pin.AM_INS: [
                pin.CS_OUT | pin.MSR_IN,
                pin.DST_OUT | pin.PC_IN,
            ],
        },
        JZ: {
            pin.AM_INS: [
                pin.CS_OUT | pin.MSR_IN,
                pin.DST_OUT | pin.PC_IN,
            ],
        },
        JNZ: {
            pin.AM_INS: [
                pin.CS_OUT | pin.MSR_IN,
                pin.DST_OUT | pin.PC_IN,
            ],
        },
        JP: {
            pin.AM_INS: [
                pin.CS_OUT | pin.MSR_IN,
                pin.DST_OUT | pin.PC_IN,
            ],
        },
        JNP: {
            pin.AM_INS: [
                pin.CS_OUT | pin.MSR_IN,
                pin.DST_OUT | pin.PC_IN,
            ],
        },
        # 此处之所以加一句MSR_OUT | pin.MSR_IN是因为
        # 外界的CS可能在Jx指令前被改变但Jx指令并不维护CS
        # 导致错误
        PUSH: {
            pin.AM_INS: [
                pin.MSR_OUT | pin.CS_IN,
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                pin.SS_OUT | pin.MSR_IN,
                pin.DST_OUT | pin.RAM_IN,
                pin.CS_OUT | pin.MSR_IN,
            ],
            pin.AM_REG: [
                pin.MSR_OUT | pin.CS_IN,
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                pin.SS_OUT | pin.MSR_IN,
                pin.DST_R | pin.RAM_IN,
                pin.CS_OUT | pin.MSR_IN,
            ],
        },
        POP: {
            pin.AM_REG: [
                pin.MSR_OUT | pin.CS_IN,
                pin.SP_OUT | pin.MAR_IN,
                pin.SS_OUT | pin.MSR_IN,
                pin.DST_W | pin.RAM_OUT,
                pin.SP_OUT | pin.A_IN,
                pin.OP_INC | pin.SP_IN | pin.ALU_OUT,
                pin.CS_OUT | pin.MSR_IN,
            ],
        },
        # 函数调用指令
        # 函数调用时之所以使用DS而非使用CS就是因为怕
        # Jx指令不维护CS导致预料之外的错误
        CALL: {
            pin.AM_INS: [
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                pin.SS_OUT | pin.MSR_IN,
                pin.PC_OUT | pin.RAM_IN,
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                # 没人维护CS故CS不再安全
                # 因此汇编代码中只要使用CALL指令必须加上对CS的维护
                # 因为微指令没有足够的次数维护CS
                pin.CS_OUT | pin.RAM_IN,
                pin.DST_OUT | pin.PC_IN,
                pin.DS_OUT | pin.MSR_IN,
            ],
            pin.AM_REG: [
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                pin.SS_OUT | pin.MSR_IN,
                pin.PC_OUT | pin.RAM_IN,
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                pin.CS_OUT | pin.RAM_IN,
                pin.DST_R | pin.PC_IN,
                pin.DS_OUT | pin.MSR_IN,
            ],
        },
        INT: {
            pin.AM_INS: [
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                pin.SS_OUT | pin.MSR_IN,
                pin.PC_OUT | pin.RAM_IN,
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                pin.CS_OUT | pin.RAM_IN,
                pin.DST_OUT | pin.PC_IN,
                pin.CS_OUT | pin.MSR_IN | pin.ALU_PSW | pin.ALU_CLI,
            ],
            pin.AM_REG: [
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                pin.SS_OUT | pin.MSR_IN,
                pin.PC_OUT | pin.RAM_IN,
                pin.SP_OUT | pin.A_IN,
                pin.OP_DEC | pin.SP_IN | pin.ALU_OUT,
                pin.SP_OUT | pin.MAR_IN,
                pin.CS_OUT | pin.RAM_IN,
                pin.DST_R | pin.PC_IN,
                pin.CS_OUT | pin.MSR_IN | pin.ALU_PSW | pin.ALU_CLI,
            ],
        },
    },
    0: {
        NOP: [
            pin.CYC,
        ],
        RET: [
            pin.SP_OUT | pin.MAR_IN,
            pin.SS_OUT | pin.MSR_IN,
            # 此处的CS只是一个中转站因此不不收影响
            # IRET同理
            pin.CS_IN | pin.RAM_OUT,
            pin.SP_OUT | pin.A_IN,
            pin.OP_INC | pin.SP_IN | pin.ALU_OUT,
            pin.SP_OUT | pin.MAR_IN,
            pin.PC_IN | pin.RAM_OUT,
            pin.SP_OUT | pin.A_IN,
            pin.OP_INC | pin.SP_IN | pin.ALU_OUT,
            pin.CS_OUT | pin.MSR_IN,
        ],
        IRET: [
            pin.SP_OUT | pin.MAR_IN,
            pin.SS_OUT | pin.MSR_IN,
            pin.CS_IN | pin.RAM_OUT,
            pin.SP_OUT | pin.A_IN,
            pin.OP_INC | pin.SP_IN | pin.ALU_OUT,
            pin.SP_OUT | pin.MAR_IN,
            pin.PC_IN | pin.RAM_OUT,
            pin.SP_OUT | pin.A_IN,
            pin.OP_INC | pin.SP_IN | pin.ALU_OUT,
            pin.CS_OUT | pin.MSR_IN | pin.ALU_PSW | pin.ALU_STI,
        ],
        STI: [
            pin.ALU_PSW | pin.ALU_STI,
        ],
        CLI: [
            pin.ALU_PSW | pin.ALU_CLI,
        ],
        HLT: [
            pin.HLT,
        ],
        OUT: [
            pin.D_OUT | pin.HW_IN
        ],
        IN: [
            pin.HW_OUT | pin.D_IN
        ],
        WRITE: [
            pin.D_OUT | pin.RAM_IN
        ],
        READ: [
            pin.RAM_OUT | pin.D_IN
        ],
        MUT32: [
            pin.CSRC | pin.F_OUT | pin.DorM
        ],
        DIV32: [
            pin.CSRC | pin.F_OUT
        ],
        INCMSR: [
            pin.A_OUT | pin.BP_IN,
            pin.MSR_OUT | pin.A_IN,
            pin.OP_INC | pin.MSR_IN | pin.ALU_OUT,
            pin.BP_OUT | pin.A_IN
        ],
    }
}



