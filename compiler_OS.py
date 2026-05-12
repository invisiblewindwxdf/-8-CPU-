# coding=utf-8

# 该文件是编译器，将汇编代码编译成二进制代码
# 该文件基于compiler.py和OS_改.py升级

import os
import re

import pin
import assembly as ASM

dirname = os.path.dirname(__file__)
    
input_name = 'Float_Caculate'   
input_file = os.path.join(dirname,'./src/' + input_name + '.asm')
output_file = os.path.join(dirname, './code/' + input_name + '.bin')

# 去除注释的re格式
# 原理是用';'分割符串，将注释前的内容加入分组中(实际上只有注释前的字符进入分组)
annotation = re.compile(r"(.*?)\s*;.*")

codes = []
marks = {}

OP2 = {
    'MOV': ASM.MOV,
    'ADD': ASM.ADD,
    'SUB': ASM.SUB,
    'CMP': ASM.CMP,
    'AND': ASM.AND,
    'OR': ASM.OR,
    'XOR': ASM.XOR,
    'MUT': ASM.MUT,
}

OP1 = {
    'INC': ASM.INC,
    'DEC': ASM.DEC,
    'NOT': ASM.NOT,
    'LSL': ASM.LSL,
    'LSR': ASM.LSR,
    'JMP': ASM.JMP,
    'JO': ASM.JO,
    'JNO': ASM.JNO,
    'JZ': ASM.JZ,
    'JNZ': ASM.JNZ,
    'JP': ASM.JP,
    'JNP': ASM.JNP,
    'PUSH': ASM.PUSH,
    'POP': ASM.POP,
    'CALL': ASM.CALL,
    'INT': ASM.INT,
}

JUMP = {
    'JMP': ASM.JMP,
    'JO': ASM.JO,
    'JNO': ASM.JNO,
    'JZ': ASM.JZ,
    'JNZ': ASM.JNZ,
    'JP': ASM.JP,
    'JNP': ASM.JNP,
    'CALL':ASM.CALL
}

OP0 = {
    'NOP': ASM.NOP,
    'RET': ASM.RET,
    'IRET': ASM.IRET,
    'STI': ASM.STI,
    'CLI': ASM.CLI,
    'HLT': ASM.HLT,
    'OUT': ASM.OUT,
    'IN': ASM.IN,
    'WRITE': ASM.WRITE,
    'READ': ASM.READ,
    'MUT32': ASM.MUT32,
    'DIV32': ASM.DIV32,
    'INCMSR': ASM.INCMSR,
}

OP2SET = set(OP2.values())
OP1SET = set(OP1.values())
OP0SET = set(OP0.values())

REGISTERS = {
    "A": pin.A,
    "B": pin.B,
    "C": pin.C,
    "D": pin.D,
    "SS": pin.SS,
    "SP": pin.SP,
    "CS": pin.CS,
    'MSR': pin.MSR,
    'OMSR': pin.OMSR,
    'OMAR': pin.OMAR,
    'T1': pin.T1,
    'T2':  pin.T2,
    'DS': pin.DS,
    'A1': pin.A1,
    'A2': pin.A2,
    'A3': pin.A3,
    'A4': pin.A4,
    'B1': pin.B1,
    'B2': pin.B2,
    'B3': pin.B3,
    'B4': pin.B4,
}

class Code(object):
    TYPE_CODE = 1
    TYPE_LABEL = 2
    
    def __init__(self, number, source: str):
        self.number = number
        self.source = source.upper()
        # 此处的op dst src 均为string类型，时源码中的字符串
        # 例如
        # source = "ADD A B"
        # op = "ADD"
        # dst = "A"
        # src = "B"
        self.op = None
        self.dst = None
        self.src = None
        self.type = self.TYPE_CODE
        self.index = 0
        self.prepare_source()
        
    def prepare_source(self):
        if self.source.endswith(':'):
            self.type = self.TYPE_LABEL
            self.name = self.source.strip(':')
            return
        
        # 对于一条指令我们先得到其源地址数
        # 再得到其目的地址数
        # 最后得到其操作数
        # 于是先看有没有','
        # 则是2地址指令
        # 没有再看剩下的指令能不能用空格分为两部分
        # 能则是1地址指令
        # 否则则是0地址指令
        # 也就是利用找源地址数、目的地指数、源操作数
        # 得到指令Code对应的参数实际上是没有进行
        # 指令的分类的，具体是后续操作得到指令类型
        tup = self.source.split(',')
        if len(tup) > 2:
            raise SyntaxError(self)
        if len(tup) == 2:
            self.src = tup[1].strip()
        # tup[0]是去除源操作数之后(如果有的话)的剩余部分
        tup = re.split(r' +', tup[0])
        if len(tup) > 2:
            raise SyntaxError(self)
        if len(tup) == 2:
            self.dst = tup[1].strip()
        # tup[0]是去除目的操作数之后(如果有的话)的剩余部分(操作数)
        self.op = tup[0].strip()
    
    def get_op(self):
        if self.op in OP2:
            return OP2[self.op]
        if self.op in OP1:
            return OP1[self.op]
        if self.op in OP0:
            return OP0[self.op]
        raise SyntaxError(self)

    def get_am(self, addr):
        global marks
        
        if not addr:
            return None, None
        # 如果传入的字符是标记而不是造作书对应的字符
        if addr in marks:
            # 这是跳转的代码对象在跳转指令中才会遇到的情况
            # 本来要传回立即数类型 + 该标对应的位置
            # 但是由于改版进行的优化，这里不再返回立即数类型
            # 而是返回立即数类型和None，至于之后None要换成什么
            # 由重新排版代码排版之后再确定
            value = marks[addr].index % 256
            return pin.AM_INS, value
        if addr in REGISTERS:
            return pin.AM_REG, REGISTERS[addr]
        if re.match(r'^[0-9]+$', addr):
            return pin.AM_INS, int(addr)
        if re.match(r'0X[0-9A-F]+$', addr):
            return pin.AM_INS, int(addr, 16)
        if re.match(r'0B[0-1]+$', addr):
            return pin.AM_INS, int(addr, 2)
        match = re.match(r'^\[([0-9]+)\]$', addr)
        if match:
            return pin.AM_DIR, int(match.group(1))
        match = re.match(r'^\[([0-9A-F]+)\]$', addr)
        if match:
            return pin.AM_DIR, int(match.group(1), 16)
        # 寄存器直接寻址
        match = re.match(r'^\[(.+)\]$', addr)
        if match and match.group(1) in REGISTERS:
            return pin.AM_RAM, REGISTERS[match.group(1)]
        raise SyntaxError(code)

    def compile_code(self):
        # 得到源码中操作类型的字符串对应的操作码
        op = self.get_op()
        
        # am是指示操作数类型
        # 其包含目的操作数类型和源操作数类型
        # 本质就是看你指令中(不论是源操作数还是目的操作数)到底是使用
        # 寄存器、立即数还是
        amd, dst = self.get_am(self.dst)
        ams, src = self.get_am(self.src)
        
        if src is not None and (amd,ams) not in ASM.INSTRUCTIONS[2][op]:
            raise SyntaxError(self)
        if src is None and dst and amd not in ASM.INSTRUCTIONS[1][op]:
            if self.src not in JUMP:
                raise SyntaxError(self)
        if src is None and dst is None and op not in ASM.INSTRUCTIONS[0]:
            raise SyntaxError(self)
        
        amd = amd or 0
        ams = ams or 0
        dst = dst or 0
        src = src or 0
        
        # 这是生成指令的编码的，也就是
        # 例如：
        # MOV A, 5
        # 此处生成上述的指令编码
        # 2地址指令生成三个字节
        # 1地址指令生成两个字节
        # 0地址指令生成一个字节
        if op in OP2SET:
            ir = op | (amd << 2) | ams
            return [ir, dst ,src]
        elif op in OP1SET:
            ir = op  | amd
            return [ir, dst]
        else:
            ir = op
            return [ir]
    
    def __repr__(self):
        return f'[{self.number}] - {self.source}'
            
        
class SyntaxError(Exception):
    def __init__(self, code: Code, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.code = code
        
def compile_program():
    global codes
    global marks
    
    with open(input_file, encoding='utf8') as file:
        lines = file.readlines()
        
    for index, line in enumerate(lines):
        source = line.strip()
        if ';' in source:
            match = annotation.match(source)
            source = match.group(1)
        if not source:
            continue
        code = Code(index + 1, source)
        codes.append(code)
    code = Code(index + 2, 'HLT')
    codes.append(code)
    
    result = []
    
    # index是最终写入二进制文件中的代码索引
    index = 0
    # code_index是当前正在处理的代码实例
    code_index = 0
    # 获取最后一条代码，用于判断程序是否结束
    last_code = codes[-1]
    
    while code_index <= len(codes) - 1:
        group_boundary = 256 * (index // 256 + 1)
        code = codes[code_index]
        # if group_boundary - 5 <= index <= group_boundary + 2:
        #     print('=======')
        if code.op in OP2 or code.op in JUMP:
            target_pos = index + 3
            if target_pos == group_boundary - 1:
                if code.op in JUMP:
                    if code.op == 'CALL':
                        codes.insert(code_index, Code(None, 'MOV DS, 0x00'))
                        codes.insert(code_index + 1, Code(None, 'INCMSR'))
                    else:
                        codes.insert(code_index, Code(None, 'MOV CS, 0x00'))
                        codes.insert(code_index + 1, Code(None, 'INCMSR'))
                    index += 6
                    code_index += 3
                    continue
                codes.insert(code_index + 1, Code(None, 'INCMSR'))
                index += 4
                code_index += 2
                continue
            elif target_pos == group_boundary:
                if code.op in JUMP:
                    codes.insert(code_index,Code(None, 'NOP'))
                    codes.insert(code_index + 1,Code(None, 'NOP'))
                    codes.insert(code_index + 2, Code(None, 'INCMSR'))
                    if code.op == 'CALL':
                        codes.insert(code_index + 3, Code(None, 'MOV DS, 0x00'))
                    else:
                        codes.insert(code_index + 3, Code(None, 'MOV CS, 0x00'))
                    index += 8
                    code_index += 5
                    continue
                codes.insert(code_index, Code(None, 'NOP'))
                codes.insert(code_index, Code(None, 'NOP'))
                codes.insert(code_index + 2, Code(None, 'INCMSR'))
                index += 6
                code_index += 4
                continue
            elif target_pos == group_boundary + 1:
                if code.op in JUMP:
                    codes.insert(code_index, Code(None, 'NOP'))
                    codes.insert(code_index + 1, Code(None, 'INCMSR'))
                    if code.op == 'CALL':
                        codes.insert(code_index + 2, Code(None, 'MOV DS, 0x00'))
                    else:
                        codes.insert(code_index + 2, Code(None, 'MOV CS, 0x00'))
                    index += 7
                    code_index += 4
                    continue
                codes.insert(code_index, Code(None, 'NOP'))
                codes.insert(code_index + 1, Code(None, 'INCMSR'))
                index += 5
                code_index += 3
                continue
            elif target_pos == group_boundary + 2:
                if code.op in JUMP:
                    codes.insert(code_index, Code(None, 'INCMSR'))
                    if code.op == 'CALL':
                        codes.insert(code_index + 1, Code(None, 'MOV DS, 0x00'))
                    else:
                        codes.insert(code_index + 1, Code(None, 'MOV CS, 0x00'))
                    index += 6
                    code_index += 3
                    continue
                codes.insert(code_index, Code(None, 'INCMSR'))
                index += 4
                code_index += 2
                continue
            elif code.op in JUMP and target_pos == group_boundary-2:
                if code.op == 'CALL':
                    codes.insert(code_index, Code(None, 'MOV DS, 0x00'))
                else:
                    codes.insert(code_index, Code(None, 'MOV CS, 0x00'))
                codes.insert(code_index + 1, Code(None, 'NOP'))
                codes.insert(code_index + 2, Code(None, 'INCMSR'))
                index += 7
                code_index += 4
                continue

        elif code.op in OP1 and code.op not in JUMP:
            target_pos = index + 2
            if target_pos == group_boundary - 1:
                codes.insert(code_index + 1, Code(None, 'INCMSR'))
                index += 3
                code_index += 2
                continue
            elif target_pos == group_boundary:
                codes.insert(code_index, Code(None, 'NOP'))
                codes.insert(code_index + 1, Code(None, 'INCMSR'))
                index += 4
                code_index += 3
                continue
            elif target_pos == group_boundary + 1:
                codes.insert(code_index, Code(None, 'INCMSR'))
                index += 3
                code_index += 2 
                continue
        elif code.op in OP0:
            target_pos = index + 1
            if target_pos == group_boundary:
                codes.insert(code_index, Code(None, 'INCMSR'))
                index += 2
                code_index += 2
                continue
            
        if code.op in OP2:
            index += 3
            code_index += 1
            continue
        elif code.op in OP1:
            if code.op in JUMP:
                if code.op == 'CALL':
                    codes.insert(code_index, Code(None, 'MOV DS, 0x00'))
                else:
                    codes.insert(code_index, Code(None, 'MOV CS, 0x00'))
                index += 5
                code_index += 2
                continue
            else:
                index += 2
                code_index += 1
                continue
        elif code.op in OP0:
            index += 1
            code_index += 1
            continue
        elif code.type == Code.TYPE_LABEL:
            code_index += 1
            continue
        else:
            raise SyntaxError(code)

    current = None
    for var in range(len(codes) - 1, -1, -1):
        code = codes[var]
        if code.type == Code.TYPE_CODE:
            current = code
            result.insert(0, code)
            continue
        if code.type == Code.TYPE_LABEL:
            marks[code.name] = current
            continue
        raise SyntaxError(code)
    
    real_index = 0
    for index, var in enumerate(result):
        # 重新调整属于代码类型的代码的引索
        var.index = real_index
        if var.op in OP2:
            real_index += 3
        elif var.op in OP1:
            real_index += 2
        elif var.op in OP0:
            real_index += 1
    
    CS_op_index = None
    CALL_count = 0
    CS_op_count = 0
    # 全局修改跳转的引索
    for index in range(len(result)):
        code = result[index]
        if code.source == 'MOV CS, MSR':
            CS_op_count += 1
            CS_op_index = index
        if code.op in JUMP:
            if index == 0:
                raise SyntaxError('跳转指令前没有MOV指令,请检查compiler_OS.py 中的compile_program()函数')
            dst_code = marks[code.dst]
            cs = dst_code.index // 256
            pc = dst_code.index % 256
            if code.op == 'CALL':
                if result[index - 1].source == 'INCMSR':
                    if result[index - 2].source == 'NOP':
                        result[index - 3].source = f'MOV DS, {cs}'
                        result[index - 3].prepare_source()
                    else:
                        result[index - 2].source = f'MOV DS, {cs}'
                        result[index - 2].prepare_source()
                else:
                    result[index - 1].source = f'MOV DS, {cs}'
                    result[index - 1].prepare_source()
                dst_cs = result[index + 1].index // 256
                result[CS_op_index].source = f'MOV CS, {dst_cs}'
                result[CS_op_index].prepare_source()
                CALL_count += 1
            else:
                if result[index - 1].source == 'INCMSR':
                    if result[index - 2].source == 'NOP':
                        result[index - 3].source = f'MOV CS, {cs}'
                        result[index - 3].prepare_source()
                    else:
                        result[index - 2].source = f'MOV CS, {cs}'
                        result[index - 2].prepare_source()
                else:
                    result[index - 1].source = f'MOV CS, {cs}'
                    result[index - 1].prepare_source()
            # code.source = f'{code.op} {pc}'
            # code.prepare_source()
    if CS_op_count != CALL_count:
        raise SyntaxError('CS_op_count != CALL_count')      
    with open(output_file, 'wb') as file:
        for index,code in enumerate(result):
            values = code.compile_code()
            for value in values:
                result = value.to_bytes(1, byteorder='little')
                file.write(result)
        
def main():
    try:
        compile_program()
    except SyntaxError as e:
        print(f'Syntax error at {e.code}')
        return

    print('compile program.asm finished!!!')


if __name__ == '__main__':
    main()