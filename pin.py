# coding=utf-8
# 控制单元(Control Unit)中的寄存器编号，最终会进行解码只想具体的寄存器
# 不论是源寄存器还是目的寄存器都是该编码
MSR = 1
MAR = 2
MDR = 3
RAM = 4
IR = 5
DST = 6
SRC = 7
A = 8
B = 9
C = 10
D = 11
SI = 13
SP = 14
BP = 15
CS = 16
DS = 17
SS = 18
ES = 19
T1 = 21
T2 = 22
OMAR = 23
OMSR = 24
HW = 25
A1 = 26
A2 = 27
A3 = 28
A4 = 29
B1 = 30
B2 = 31
# 原VEC换为B3
B3 = 20
# 原DI换为B4
B4 = 12

MSR_OUT = MSR # MSR是内存的高8位
MAR_OUT = MAR # MAR是内存的低8位
MDR_OUT = MDR # 可使用的寄存器，暂时不知道是什么功能
RAM_OUT = RAM
IR_OUT = IR
DST_OUT = DST # DST_OUT是指目的操作数寄存器直接输出
SRC_OUT = SRC # SRC_OUT是指源操作数寄存器直接输出
A_OUT = A
B_OUT = B
C_OUT = C
D_OUT = D
# DI_OUT = DI
SI_OUT = SI
SP_OUT = SP
BP_OUT = BP
CS_OUT = CS
DS_OUT = DS
SS_OUT = SS
ES_OUT = ES
B3_OUT = B3
T1_OUT = T1
T2_OUT = T2
OMAR_OUT = OMAR
OMSR_OUT = OMSR
HW_OUT = HW
A1_OUT = A1
A2_OUT = A2
A3_OUT = A3
A4_OUT = A4
B1_OUT = B1
B2_OUT = B2
B3_OUT = B3
B4_OUT = B4


# 目的寄存器要向左移五位，因为Control Unit的输入是32位的0~4位是源寄存器
# 5~9位是目的寄存器
_DST_SHIFT = 5

MSR_IN = MSR << _DST_SHIFT
MAR_IN = MAR << _DST_SHIFT
MDR_IN = MDR << _DST_SHIFT
RAM_IN = RAM << _DST_SHIFT
IR_IN = IR << _DST_SHIFT
DST_IN = DST << _DST_SHIFT # SRC_IN是指目的操作数寄存器直接输入
SRC_IN = SRC << _DST_SHIFT # SRC_IN是指源操作数寄存器直接输入
A_IN = A << _DST_SHIFT
B_IN = B << _DST_SHIFT
C_IN = C << _DST_SHIFT
D_IN = D << _DST_SHIFT
# DI_IN = DI << _DST_SHIFT
SI_IN = SI << _DST_SHIFT
SP_IN = SP << _DST_SHIFT
BP_IN = BP << _DST_SHIFT
CS_IN = CS << _DST_SHIFT
DS_IN = DS << _DST_SHIFT
SS_IN = SS << _DST_SHIFT
ES_IN = ES << _DST_SHIFT
B3_IN = B3 << _DST_SHIFT
T1_IN = T1 << _DST_SHIFT
T2_IN = T2 << _DST_SHIFT
OMAR_IN = OMAR << _DST_SHIFT
OMSR_IN = OMSR << _DST_SHIFT
HW_IN = HW << _DST_SHIFT
A1_IN = A1 << _DST_SHIFT
A2_IN = A2 << _DST_SHIFT
A3_IN = A3 << _DST_SHIFT
A4_IN = A4 << _DST_SHIFT
B1_IN = B1 << _DST_SHIFT
B2_IN = B2 << _DST_SHIFT
B3_IN = B3 << _DST_SHIFT
B4_IN = B4 << _DST_SHIFT

# SRC控制源寄存器，DST控制目的寄存器。R是读出，W是写入
# 控制信号是在10~13位
# 这里一定要和SRC_IN和SRC_OUT相区别
# 这里指的是源操作数寄存器或目的操作数寄存器指代的寄存器输入或输出！！！！
SRC_R = 2 ** 10
SRC_W = 2 ** 11
DST_R = 2 ** 12
DST_W = 2 ** 13

# PC控制是14~16位
# PC_WE表示PC寄存器写入
# PC_CS表示PC寄存器被选中
# PC_EN表示PC寄存器输出
PC_WE = 2 ** 14
PC_CS = 2 ** 15
PC_EN = 2 ** 16

# PC控制信号
# PC_INC表示PC寄存器加1
# 注意：PC_OUT控制的时PC中的寄存器输出
# 这个输出确实是01
PC_OUT = PC_CS
PC_IN = PC_CS | PC_WE
PC_INC = PC_CS | PC_WE | PC_EN

# OP是指对ALU进行那种运算的选择
# 当然ALU所有类型的运算都是同时有的，选择输出哪种运算的结果到ALU的总线中
# 就是在选择运算
# 此处CPU有8中运算
# 用三位表示八种运算，然后把三位进行左移，因为管理ALU运算类型选择的位在第17位
_OP_SHIFT = 17

OP_ADD = 0
OP_SUB = 1 << _OP_SHIFT
OP_INC = 2 << _OP_SHIFT
OP_DEC = 3 << _OP_SHIFT
OP_AND = 4 << _OP_SHIFT
OP_OR = 5 << _OP_SHIFT
OP_XOR = 6 << _OP_SHIFT
OP_NOT = 7 << _OP_SHIFT
OP_LSL = 8 << _OP_SHIFT
OP_LSR = 9 << _OP_SHIFT
OP_MTL = 10 << _OP_SHIFT
OP_MTH = 11 << _OP_SHIFT
# 此处关于ALU的最高两位是什么意思还不知道
# 但是低两位分别表示：
# 0位：ALU总线输出到外部总线
# 1位：ALU的PSW输出到外部总线
# 猜测INT_W表示写入中断标志位
# 猜测INT表示读取中断标志位
# 修改（左移一位）
ALU_OUT = 1 << 21
ALU_PSW = 1 << 22
ALU_INT_W = 1 << 23
ALU_INT = 1 << 24

# ALU开中断
ALU_STI = ALU_INT_W
# ALU关中断
ALU_CLI = ALU_INT_W | ALU_INT

# 乘除计算两位
# SRC为Caculate Special Register Control
CSRC = 1 << 25
F_OUT = 1 << 26
DorM = 1 << 27


CYC = 2 ** 30
HLT = 2 ** 31

# 猜测位一地址指令和二地址指令的标志位
# 1开头表示二地址指令
# 01开头表示一地址指令
# 这里也能看出一条
ADDR2 = 1 << 7
ADDR1 = 1 << 6

ADDR2_SHIFT = 4
ADDR1_SHIFT = 2

# AM指的是 address mode 寻址方式
# INS 指立即数
# MOV A, 5
AM_INS = 0
# 寄存器寻址
# MOV A, B
AM_REG = 1
# 直接寻址
# MOV A, [10]
AM_DIR = 2
# 寄存器间接寻址
# MOV A, [B]
AM_RAM = 3
# 这里最重要的就是排列组合
# 我们可以在确定操作数MOV或ADD等等之后
# 再根据寻址方式的排列组合
# 例如：A, 5
# 就是前面为寄存器寻址，后面为立即数
# 再例如：
# MOV [A], [5]
# 前面为寄存器间接寻址
# 后面为直接寻址
# 所以在assembly文件中会有类似(pin.AM_REG, pin.AM_INS)
# 的东西出现
# 其目的就是表示出寻址的组合方式
# 比如上述示例就是MOV A, 5 的指令所代表的组合方式