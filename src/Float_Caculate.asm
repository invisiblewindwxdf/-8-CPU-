Main:
    ; 初始化栈段
    MOV SS, 0xFF

    MOV CS, MSR
    CALL Predict
    ; 10:10开始
    ; 预计430+180分钟结束
    ; 预计于22:35
    HLT

Predict:
    ; 测试无异常
    ; 函数介绍
        ; 使用栈：所有
    ; 开始
    
    ; tanh(x + B0)
        ; 压入循环数
            PUSH 0X03
            PUSH 0X10
        ; 压入参数地址起点
            PUSH 0; OMSR
            PUSH 0; OMAR
        ; 开启while_1循环
        开始while_1循环_Predict:
            ; 判断循环是否结束
                ADD SP, 2
                POP A3
                POP A4
                SUB SP, 4

                MOV A2, 0
                MOV A1, 1

                PUSH 0
                MOV CS, MSR
                CALL 2Btyes_SUB
                POP C
                AND C, 0XFF
                JNZ 结束while_1循环_Predict
                ADD SP, 4
                PUSH A4
                PUSH A3
                SUB SP, 2

            ; 循环体
                ; 获取A4-A1和B4-B1的位置并入栈
                    POP OMAR
                    POP OMSR
                    SUB SP, 2

                    MOV CS, MSR
                    CALL INC_OUT_M
                    PUSH OMSR
                    PUSH OMAR

                    MOV CS, MSR
                    CALL INC_OUT_M
                    PUSH OMSR
                    PUSH OMAR

                    MOV CS, MSR
                    CALL INC_OUT_M
                    PUSH OMSR
                    PUSH OMAR

                    ADD SP, 6
                    POP OMAR
                    POP OMSR
                    SUB SP, 8

                    PUSH 0X0C
                    PUSH 0X40
                    MOV CS, MSR
                    CALL ADD_OUT_M
                    ADD SP, 2
                    PUSH OMSR
                    PUSH OMAR

                    MOV CS, MSR
                    CALL INC_OUT_M
                    PUSH OMSR
                    PUSH OMAR

                    MOV CS, MSR
                    CALL INC_OUT_M
                    PUSH OMSR
                    PUSH OMAR

                    MOV CS, MSR
                    CALL INC_OUT_M
                    PUSH OMSR
                    PUSH OMAR
                
                ; 计算tanh(B0 + X)
                    POP OMAR
                    POP OMSR
                    IN
                    MOV B1, D

                    POP OMAR
                    POP OMSR
                    IN
                    MOV B2, D

                    POP OMAR
                    POP OMSR
                    IN
                    MOV B3, D

                    POP OMAR
                    POP OMSR
                    IN
                    MOV B4, D

                    POP OMAR
                    POP OMSR
                    IN
                    MOV A1, D

                    POP OMAR
                    POP OMSR
                    IN
                    MOV A2, D

                    POP OMAR
                    POP OMSR
                    IN
                    MOV A3, D

                    POP OMAR
                    POP OMSR
                    IN
                    MOV A4, D

                    SUB SP, 16

                    MOV CS, MSR
                    CALL Float_A+B_Caculate

                    PUSH A4
                    PUSH A3
                    PUSH A2
                    PUSH A1
                    MOV CS, MSR
                    CALL Thanh_Caculate
                    ADD SP, 4

                    POP OMAR
                    POP OMSR
                    MOV D, A1
                    OUT

                    POP OMAR
                    POP OMSR
                    MOV D, A2
                    OUT

                    POP OMAR
                    POP OMSR
                    MOV D, A3
                    OUT

                    POP OMAR
                    POP OMSR
                    MOV D, A4
                    OUT

                    ADD SP, 6
                    POP OMAR
                    POP OMSR

                    PUSH 0X00
                    PUSH 0X04
                    MOV CS, MSR
                    CALL ADD_OUT_M
                    ADD SP, 2

                    PUSH OMSR
                    PUSH OMAR
                JMP 开始while_1循环_Predict
            结束while_1循环_Predict:
            
    ; 计算矩阵
        ; 舍弃后方的栈
            ADD SP, 4
        ; 压入第二层大循环数
            PUSH 10
        ; 压入第二层小循环数
            PUSH 0X03
            PUSH 0X10
        ; 压入O1 = tanh(x + b0)位置
            PUSH 0X0C
            PUSH 0X40
        ; 压入W1 位置
            PUSH 0X18
            PUSH 0X80
        ; 压入Result_X 位置
            PUSH 0X93
            PUSH 0X28
        开始while_2循环_Predict:
            开始while_2_while_1_循环_Predict:
                ADD SP, 2
                POP OMAR
                POP OMSR
                SUB SP, 4
                IN
                MOV A4, D

                MOV CS, MSR
                CALL INC_OUT_M

                IN
                MOV A3, D

                MOV CS, MSR
                CALL INC_OUT_M

                IN
                MOV A2, D

                MOV CS, MSR
                CALL INC_OUT_M

                IN
                MOV A1, D

                MOV CS, MSR
                CALL INC_OUT_M

                ; 更新w1参数位置
                ADD SP, 4
                PUSH OMSR
                PUSH OMAR
                SUB SP, 2

                ADD SP, 4
                POP OMAR
                POP OMSR
                SUB SP, 6

                IN
                MOV B4, D

                MOV CS, MSR
                CALL INC_OUT_M

                IN
                MOV B3, D

                MOV CS, MSR
                CALL INC_OUT_M

                IN
                MOV B2, D

                MOV CS, MSR
                CALL INC_OUT_M

                IN
                MOV B1, D

                MOV CS, MSR
                CALL INC_OUT_M
                ; 跟新Thanh(x + b0)参数位置
                ADD SP, 6
                PUSH OMSR
                PUSH OMAR
                SUB SP, 4

                MOV CS, MSR
                CALL Float_A*B_Caculate

                ; w1*Thanh(x + b0)结果存放位置
                ; 注意此处是连加
                POP OMAR
                POP OMSR
                SUB SP, 2

                IN
                MOV B4, D

                MOV CS, MSR
                CALL INC_OUT_M

                IN
                MOV B3, D

                MOV CS, MSR
                CALL INC_OUT_M

                IN
                MOV B2, D

                MOV CS, MSR
                CALL INC_OUT_M

                IN
                MOV B1, D

                MOV CS, MSR
                CALL Float_A+B_Caculate

                MOV D, A1
                OUT

                MOV CS, MSR
                CALL DEC_OUT_M

                MOV D, A2
                OUT

                MOV CS, MSR
                CALL DEC_OUT_M

                MOV D, A3
                OUT

                MOV CS, MSR
                CALL DEC_OUT_M

                MOV D, A4
                OUT

                ; 小循环参数减一
                ADD SP, 6
                POP OMAR
                POP OMSR
                SUB SP, 8

                MOV CS, MSR
                CALL DEC_OUT_M
                ADD SP, 8
                PUSH OMSR
                PUSH OMAR
                SUB SP, 6

                OR OMSR, OMAR
                JNZ 开始while_2_while_1_循环_Predict
            
            ; 大循环参数
            ; 是0则结束循环
            ; 重置参数
                ADD SP, 8
                POP C
                DEC C
                JZ 结束while_2_循环
                ; 20:24开始
                ; 预计40分钟
                ; 预计于21:04结束
                PUSH C
                PUSH 0X03
                PUSH 0X10
                PUSH 0X0C
                PUSH 0X40
                SUB SP, 4

                ; 更新Result_X参数
                POP A3
                POP A4
                SUB SP, 2
                MOV A2, 0
                MOV A1, 4

                PUSH 0
                MOV CS, MSR
                CALL 2Btyes_ADD
                INC SP

                ADD SP, 2
                PUSH A4
                PUSH A3

                JMP 开始while_2循环_Predict
                ; 20点22分开始的
                ; 预计43分钟
                ; 实际44分钟
            
        结束while_2_循环:
            ; 11点30分开始
            ; 预计43*10 = 430分钟
            ; 预计18点40分结束
            ; 11点16分开始
            ; 预计430分钟
            ; 预计18:27完成

    ; (O2 + B1)
        ; 压入循环数
            PUSH 10
        ; 压入B1位置
            PUSH 0X93
            PUSH 0
        ; 压入Result_X位置
            PUSH 0X93
            PUSH 0X28
        开始while_3_循环_Predict:
            ; 获取B1位置参数
            ADD SP, 2
            POP OMAR
            POP OMSR
            SUB SP, 4

            IN
            MOV A4, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV A3, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV A2, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV A1, D

            MOV CS, MSR
            CALL INC_OUT_M

            ; 更新B1位置参数
            ADD SP, 4
            PUSH OMSR
            PUSH OMAR
            SUB SP, 2

            ; 获取Result_X位置参数
            POP OMAR
            POP OMSR
            SUB SP, 2

            IN
            MOV B4, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV B3, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV B2, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV B1, D

            MOV CS, MSR
            CALL Float_A+B_Caculate

            ; 获取Result_X位置参数
            POP OMAR
            POP OMSR
            SUB SP, 2

            MOV D, A4
            OUT

            MOV CS, MSR
            CALL INC_OUT_M

            MOV D, A3
            OUT

            MOV CS, MSR
            CALL INC_OUT_M

            MOV D, A2
            OUT

            MOV CS, MSR
            CALL INC_OUT_M

            MOV D, A1
            OUT

            MOV CS, MSR
            CALL INC_OUT_M

            ; 更新Result_X参数位置
            ADD SP, 2
            PUSH OMSR
            PUSH OMAR

            ADD SP, 4
            POP C
            DEC C
            JZ 结束while_3_循环_Predict
            PUSH C
            SUB SP, 4
            JMP 开始while_3_循环_Predict
        结束while_3_循环_Predict:

    ; 确认识别结果
        ; 压入识别结果
            PUSH 0
        ; 压入循环数
            PUSH 9
        ; 压入最大值位置
            PUSH 0X93
            PUSH 0X28
        ; Result_X位置
            PUSH 0X93
            PUSH 0X2C
        开始while_4_循环_Predict:
            ; 先把O[x]中最大值拿出来放在A寄存器中
            ADD SP, 2
            POP OMAR
            POP OMSR
            SUB SP, 4

            IN
            MOV A4, D
            XOR A4, 0X80

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV A3, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV A2, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV A1, D

            POP OMAR
            POP OMSR
            SUB SP, 2

            IN
            MOV B4, D
            XOR B4, 0X80

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV B3, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV B2, D

            MOV CS, MSR
            CALL INC_OUT_M

            IN
            MOV B1, D

            MOV CS, MSR
            CALL INC_OUT_M

            PUSH 0
            MOV CS, MSR
            CALL 32_SUB

            POP C
            AND C, C
            JZ 不需要改变最大值_while_4_循环_Predict
                ; 暂存下一个要比较的数的指针
                PUSH OMSR
                PUSH OMAR

                ; 在还没有将下一个要比较的数的指针压栈前
                ; 此处就的指针是当前大小超过旧最大值的数的指针
                ADD SP, 2
                POP OMAR
                POP OMSR
                SUB SP, 4

                ; 更新栈中最大值的指针
                ADD SP, 6
                PUSH OMSR
                PUSH OMAR
                SUB SP, 4

                ; 更新栈中下一个要比较的数的指针
                POP OMAR
                POP OMSR
                ADD SP, 2
                PUSH OMSR
                PUSH OMAR

                ADD SP, 4
                POP T1; 当前循环数
                POP T2; 识别结果
                SUB SP, 6

                MOV A, 10
                SUB A, T1

                MOV T2, A
                ADD SP, 6
                PUSH T2
                PUSH T1
                SUB SP, 4
                JMP 判断while_4_循环_Predict
            不需要改变最大值_while_4_循环_Predict:
            ; 直接更新下一个要比较的数的指针
            ADD SP, 2
            PUSH OMSR
            PUSH OMAR
            判断while_4_循环_Predict:
            ADD SP, 4
            POP C
            DEC C
            JZ 结束while_4_循环_Predict
                PUSH C
                SUB SP, 4
                JMP 开始while_4_循环_Predict
            结束while_4_循环_Predict:
            POP D
    RET

INC_OUT_M:
    INC OMAR
    JNO OMAR_ADD_NO_OVERFLOW_INC_OUT_M
        INC OMSR
    OMAR_ADD_NO_OVERFLOW_INC_OUT_M:
    RET

DEC_OUT_M:
    DEC OMAR
    JNO OMAR_SUB_NO_OVERFLOW_DEC_OUT_M
        DEC OMSR
    OMAR_SUB_NO_OVERFLOW_DEC_OUT_M:
    RET

ADD_OUT_M:
    ADD SP, 2
    POP T2
    POP T1
    SUB SP, 4
    ADD OMAR, T2
    JNO OMAR_ADD_NO_OVERFLOW_ADD_OUT_M
        INC OMSR
    OMAR_ADD_NO_OVERFLOW_ADD_OUT_M:
    ADD OMSR, T1
    JNO OMSR_ADD_NO_OVERFLOW_ADD_OUT_M
        INC OMSR
    OMSR_ADD_NO_OVERFLOW_ADD_OUT_M:
    RET

2Btyes_ADD:
    ; 测试无异常
    ; 函数介绍
        ; 参数传入使用A[X]
        ; 使用的寄存器：
        ; A[X]、T1
        ; A[4-3]被加数高Byte-被加数低Byte
        ; A[2-1]加数高Byte-加数低Byte
        ; 栈传入参数
        ; 溢出位(传入0)
        ; 返回值使用传入栈
    
    ; 计算
        ADD A3, A1
        JNO 低位加法没有溢出_2Bytes_ADD
            ADD SP, 3
            PUSH 1
            SUB SP, 2
        低位加法没有溢出_2Bytes_ADD:

        ADD SP, 2
        POP T1
        PUSH 0
        SUB SP, 2
        ADD A4, T1
        JNO 加溢出位加法没有溢出_2Bytes_ADD
            ADD SP, 3
            PUSH 1
            SUB SP, 2
        加溢出位加法没有溢出_2Bytes_ADD:

        ADD A4, A2
        JNO 高位加法没有溢出_2Bytes_ADD
            ADD SP, 3
            PUSH 1
            SUB SP, 2
        高位加法没有溢出_2Bytes_ADD:
        RET

2Btyes_SUB:
    ; 测试无异常
    ; 函数介绍
        ; 使用的寄存器：
        ; A[X]、T1
        ; 参数传入使用A[X]
        ; A[4-3]被减数高Byte-被减数低Byte
        ; A[2-1]减数高Byte-减数低Byte
        ; 栈传入参数
        ; 溢出位(传入0)
        ; 返回值使用传入栈
    ; 计算
        PUSH A4
        PUSH A3
        PUSH 0
        NOT A2
        NOT A1
        MOV A3, A1
        MOV A4, A2
        MOV A2, 0
        MOV A1, 1
        MOV CS, MSR
        CALL 2Btyes_ADD
        MOV A1, A3
        MOV A2, A4
        INC SP
        POP A3
        POP A4
        PUSH 0
        MOV CS, MSR
        CALL 2Btyes_ADD
        POP T1
        XOR T1, 1
        ADD SP, 3
        PUSH T1
        SUB SP, 2
        RET

Float_A+B_Caculate:
    ; 测试无异常
    ; 函数简介
        ; 使用到的寄存器：
        ; A[x]、B[x]、C、D
        ; A,B由寄存器传入
        ; 需要传入参数: A[4],A[3],A[2],A[1]
        ;              B[4],B[3],B[2],B[1]
        ; 需要返回参数: A[4],A[3],A[2],A[1]
        ; 栈：
        ; SignA
        ; SignB
        ; ExpoentA
        ; ExpoentB
        ; Sign_EA-EB
        ; Result_EA-EB(此为绝对值)
        ; SignA+B
        ; SignA+B不是最终的Sign
        ; 对非规格化视为0

    ; SignA_Float_A+B_Caculate
        MOV T1, A4
        AND T1, 0x80
        PUSH T1

    ; SignB_Float_A+B_Caculate
        MOV T1, B4
        AND T1, 0x80
        PUSH T1

    ; 分离阶码的部分会处理NaN和Inf
    ; ExpoentA_Float_A+B_Caculate
        MOV T1, A4
        LSL T1
        MOV T2, A3
        AND T2, 0x80
        ; 调用8bits_LSR
        ; 调用前先保存T1
        ; T2由于是需要改变的值因此不用保存
        PUSH T1
        ; 传入参数
        PUSH T2
        PUSH 7
        PUSH 0
        MOV CS, MSR
        CALL 8bits_LSR
        POP T2
        ADD SP, 2
        POP T1
        OR T1, T2
        MOV A, 0xFF
        SUB A, T1
        ; 异常处理，若A是NaN，则返回A
        JNZ no_error_1_Float_A+B_Caculate
            ADD SP, 2
            RET
        no_error_1_Float_A+B_Caculate:
        OR T1, 0
        JNZ Expoent_A_not_zero_Float_A+B_Caculate
            MOV A4, B4
            MOV A3, B3
            MOV A2, B2
            MOV A1, B1
            ADD SP, 2
            RET
        Expoent_A_not_zero_Float_A+B_Caculate:
        PUSH T1
        OR A3, 0x80

    ; ExpoentB_Float_A+B_Caculate
        MOV T1, B4
        LSL T1
        MOV T2, B3
        AND T2, 0x80
        ; 调用8bits_LSR
        ; 调用前先保存T1
        ; T2由于是需要改变的值因此不用保存
        PUSH T1
        ; 传入参数
        PUSH T2
        PUSH 7
        PUSH 0
        MOV CS, MSR
        CALL 8bits_LSR
        POP T2
        ADD SP, 2
        POP T1
        OR T1, T2
        MOV A, 0xFF
        SUB A, T1
        ; 异常处理，若B是NaN，则返回B
        JNZ no_error_2_Float_A+B_Caculate
            MOV A4, B4
            MOV A3, B3
            MOV A2, B2
            MOV A1, B1
            ADD SP, 3
            RET
        no_error_2_Float_A+B_Caculate:
        OR T1, 0
        JNZ Expoent_B_not_zero_Float_A+B_Caculate
            ADD SP, 3
            RET
        Expoent_B_not_zero_Float_A+B_Caculate:
        PUSH T1
        OR B3, 0x80

    ; Sign_EA-EB_and_Result_EA-EB_Float_A+B_Caculate:
        POP T2; 获取EB
        POP T1; 获取EA
        SUB SP, 2
        SUB T1, T2
        MOV T2, 0
        JNO SignA+B_no_overflow_Float_A+B_Caculate
            ; 如果有溢出说明是负数
            ; 因此我需要将T1取负
            MOV T2, 1
            MOV A, 0
            SUB A, T1
            MOV T1, A
        SignA+B_no_overflow_Float_A+B_Caculate:
        PUSH T2
        PUSH T1

    ; 对A非规格数检测同时将A化为整数
    if_1_Float_A+B_Caculate:
        ; 检查浮点数A是否为非规则化数
        ; 也就是阶码是否为0000 0000
        ; 同时将A化换为32位整数
        MOV C, 0x80
        ADD SP, 3
        POP T1
        SUB SP, 4
        MOV A, T1
        SUB A, 0
        JNZ if_1_not_zero_Float_A+B_Caculate
            MOV C, 0x00
        if_1_not_zero_Float_A+B_Caculate:
        MOV A4, 0
        OR A3, C

    ; 对B非规格数检测同时将B化为整数
    if_2_Float_A+B_Caculate:
        ; 检查浮点数B是否为非规则化数
        ; 也就是阶码是否为0000 0000
        ; 同时将B化换为32位整数
        MOV C, 0x80
        ADD SP, 2
        POP T1
        SUB SP, 3
        MOV A, T1
        SUB A, 0
        JNZ if_2_not_zero_Float_A+B_Caculate
            MOV C, 0x00
        if_2_not_zero_Float_A+B_Caculate:
        MOV B4, 0
        OR B3, C

    ; 处理特殊阶码差值
    if_3_Float_A+B_Caculate:
        ; 检查浮点数的阶码是否相差24位或24位以上
        ; 是相差24以上则把小的浮点数置零
        ; 是相差刚好24位则将其置为1
        MOV T1, 1; T1为1 代表减的结果溢出
        MOV T2, 0; T2为0 代表减的结果不是0
        POP C
        SUB SP, 1
        MOV A, 24
        SUB A, C
        JNO if_3_not_overflow_Float_A+B_Caculate
            if_3_if_1_Float_A+B_Caculate:
                ; 阶码右移超24位
                ADD SP, 1
                POP T1
                SUB SP, 2
                AND T1, 0xFF; 阶码相减有溢出表示A阶小于B阶
                JNZ 阶码相减为负_if_3_if_1_Float_A+B_Caculate:
                    MOV B3, 0
                    MOV B2, 0
                    MOV B1, 0
                    JMP if_3_if_1_Float_A+B_Caculate_End
                阶码相减为负_if_3_if_1_Float_A+B_Caculate:
                    MOV A3, 0
                    MOV A2, 0
                    MOV A1, 0
            if_3_if_1_Float_A+B_Caculate_End:
                JMP if_3_Float_A+B_Caculate_End
        if_3_not_overflow_Float_A+B_Caculate:

        JNZ if_3_not_zero_Float_A+B_Caculate
            ; 阶码右移刚好24位
            if_3_if_2_Float_A+B_Caculate:
                ADD SP, 1
                POP T1
                SUB SP, 2
                AND T1, 0xFF
                JNZ 阶码相减为负_if_3_if_2_Float_A+B_Caculate
                    MOV B3, 0
                    MOV B2, 0
                    MOV B1, 0x01
                    JMP if_3_if_2_Float_A+B_Caculate_End
                阶码相减为负_if_3_if_2_Float_A+B_Caculate:
                    MOV A3, 0
                    MOV A2, 0
                    MOV A1, 0x01
            if_3_if_2_Float_A+B_Caculate_End:
                JMP if_3_Float_A+B_Caculate_End
        if_3_not_zero_Float_A+B_Caculate:
        if_3_Float_A+B_Caculate_End:

    ; 调用函数对阶
    Exponent_alignment_Float_A+B_Caculate:
        ; 根据阶数相减的溢出与否判断对A还是B进行右移
        ADD SP, 1
        POP C; Sign_EA-EB
        SUB SP, 2
        AND C, 0xFF
        JNZ A进行右移_Float_A+B_Caculate
            POP C
            DEC SP
            PUSH A4
            PUSH A3
            PUSH A2
            PUSH A1
            PUSH B4
            PUSH B3
            PUSH B2
            PUSH B1
            PUSH C
            MOV CS, MSR
            CALL 32LSR
            MOV B4, A4
            MOV B3, A3
            MOV B2, A2
            MOV B1, A1
            ADD SP, 5
            POP A1
            POP A2
            POP A3
            POP A4
            JMP Exponent_alignment_Float_A+B_Caculate_End
        A进行右移_Float_A+B_Caculate:
            POP C
            DEC SP
            PUSH A4
            PUSH A3
            PUSH A2
            PUSH A1
            PUSH C
            MOV CS, MSR
            CALL 32LSR
            ADD SP, 5
        Exponent_alignment_Float_A+B_Caculate_End:

    ; 将A_B中的负数换成负数形式
    ; Positive_Negative_Regular
        ADD SP, 4
        POP T2
        POP T1
        SUB SP, 6

        AND T1, 0xFF
        JZ A_not_Negative_Float_A+B_Caculate
            NOT A4
            NOT A3
            NOT A2
            NOT A1
        A_not_Negative_Float_A+B_Caculate:
        AND T2, 0xFF
        JZ B_not_Negative_Float_A+B_Caculate
            NOT B4
            NOT B3
            NOT B2
            NOT B1
        B_not_Negative_Float_A+B_Caculate:

    ; 调用32位加法
    ; Sign_A+B
    CALL_32_ADD_Float_A+B:
        ; 函数第一个返回的结果就是我们需要入栈的Sign_A+B
        ; 同时处理A或B为负数没有加1的情况
        PUSH 0
        MOV CS, MSR
        CALL 32_ADD
        MOV C, 0
        ADD SP, 5
        POP T2
        POP T1
        SUB SP, 7
        AND T1, 0xFF
        JZ A_not_Negative_2_Float_A+B_Caculate
            INC C
        A_not_Negative_2_Float_A+B_Caculate:
        AND T2, 0xFF
        JZ B_not_Negative_2_Float_A+B_Caculate
            INC C
        B_not_Negative_2_Float_A+B_Caculate:
        MOV B4, 0
        MOV B3, 0
        MOV B2, 0
        MOV B1, C
        PUSH 0
        MOV CS, MSR
        CALL 32_ADD
        POP T1
        POP T2
        OR T1, T2
        PUSH T1

    ; 批注:
        ; 由于我们的加减法在对阶的时候指挥往右对阶。
        ; 因此正常的加法不会产生溢出。
        ; 负数加负数一定产生溢出----结果为负
        ; 正负数相加产生溢出说明结果为正
        ; 正数加负数未产生溢出则结果为负数

    ; 调用规则化函数
        ;确定阶数
        ADD SP, 2
        POP C
        SUB SP, 3
        AND C, 0xFF
        
        ; ======注意此处入栈了一次
        JZ 取出A的阶数_Flaot_A_B_Caculate
            ADD SP, 3
            POP C
            SUB SP, 4
            PUSH C
            JMP 确定好阶数值_Float_A_B_Caculate
        取出A的阶数_Flaot_A_B_Caculate:
            ADD SP, 4
            POP C
            SUB SP, 5
            PUSH C
        确定好阶数值_Float_A_B_Caculate:
        ; 取出A、B的符号
        ADD SP, 6
        POP T2
        POP T1
        SUB SP, 8

        MOV C, T1
        AND C, T2
        JZ A_B_不都是负数_Float_A_B_Caculate
            ; A_B_都是负数
            PUSH 0
            MOV B4, 0
            MOV B3, 0
            MOV B2, 0
            MOV B1, 1
            NOT A4
            NOT A3
            NOT A2
            NOT A1
            MOV CS, MSR
            CALL 32_ADD
            INC SP
            PUSH 0x01
            MOV CS, MSR
            CALL 32_Regular
            ADD SP, 2
            JMP Float_A+B_Caculate_End
            RET
        A_B_不都是负数_Float_A_B_Caculate:
        MOV C, T1
        XOR C, T2
        JZ 结果是正数_Float_A_B_Caculate
            INC SP
            POP C
            SUB SP, 2
            AND C, 0xFF
            JNZ 结果是正数_Float_A_B_Caculate
            NOT A4
            NOT A3
            NOT A2
            NOT A1
            MOV B4, 0
            MOV B3, 0
            MOV B2, 0
            MOV B1, 1
            PUSH 0
            MOV CS, MSR
            CALL 32_ADD
            INC SP
            PUSH 0x01
            MOV CS, MSR
            CALL 32_Regular
            ADD SP, 2
            JMP Float_A+B_Caculate_End
        结果是正数_Float_A_B_Caculate:
            PUSH 0
            MOV CS, MSR
            CALL 32_Regular
            ADD SP, 2
            JMP Float_A+B_Caculate_End

    Float_A+B_Caculate_End:
        ; 恢复Float_A+B_Caculate的栈
        ; 准备返回调用函数
        ADD SP, 7
        RET

8bits_LSL:
    ; 测试无异常
    ; 该函数会使用T1,T2寄存器
    ; 栈传入参数:
    ; A  :被左移的数
    ; B  :左移的位数
    ; 返回参数:
    ; C  :左移后的数
    ADD SP, 4
    POP T1
    SUB SP, 2
    POP T2
    SUB SP, 4

    AND T2, 0xFF
    JZ 8bits_LSL_Loop_End

    8bits_LSL_Loop:
        LSL T1
        DEC T2
        JNZ 8bits_LSL_Loop
    8bits_LSL_Loop_End:
        ADD SP, 3
        PUSH T1
        SUB SP, 2
        JMP 8bits_LSL_End
    8bits_LSL_End:
        RET

8bits_LSR:
    ; 测试无异常
    ; 该函数会使用T1,T2寄存器
    ; 栈传入参数:
    ; A  :被右移的数
    ; B  :右移的位数
    ; 返回参数:
    ; C  :右移后的数
    ADD SP, 4
    POP T1
    SUB SP, 2
    POP T2
    SUB SP, 4

    AND T2, 0xFF
    JZ 8bits_LSR_Loop_End
    8bits_LSR_Loop:
        LSR T1
        DEC T2
        JNZ 8bits_LSR_Loop
    
    8bits_LSR_Loop_End:
        ADD SP, 3
        PUSH T1
        SUB SP, 2
        JMP 8bits_LSR_End
    8bits_LSR_End:
        RET

32LSR:
    ; 测试无异常
    ; 函数介绍：
        ; 传入参数使用栈
        ; 栈:
        ; A[4-1]
        ; 移动次数
        ; 返回参数使用寄存器A[4-1]
        ; 需要使用A[x]、T[x]寄存器、C
    ADD SP, 2
    POP C
    POP A1
    POP A2
    POP A3
    POP A4
    SUB SP, 7
    while_32LSR_Float_Caculate:
        AND C, 0xFF
        JZ while_32LSR_Float_Caculate_End
            MOV T1, A4
            AND T1, 0x01
            PUSH T1
            PUSH 7
            PUSH 0
            ; 不要误会,这里就是使用8bits_LSL
            MOV CS, MSR
            CALL 8bits_LSL
            POP T1
            ADD SP, 2
            LSR A4

            MOV T2, A3
            AND T2, 0x01
            PUSH T1
            PUSH T2
            PUSH 7
            PUSH 0
            MOV CS, MSR
            CALL 8bits_LSL
            POP T2
            ADD SP, 2
            POP T1
            LSR A3

            OR A3, T1

            MOV T1, A2
            AND T1, 0x01
            PUSH T2
            PUSH T1
            PUSH 7
            PUSH 0
            MOV CS, MSR
            CALL 8bits_LSL
            POP T1
            ADD SP, 2
            POP T2
            LSR A2

            OR A2, T2

            LSR A1
            OR A1, T1

            DEC C
            JMP while_32LSR_Float_Caculate
        while_32LSR_Float_Caculate_End:
    RET

32LSL:
    ; 测试无异常
    ; 函数介绍：
        ; 传入参数使用栈
        ; 栈:
        ; A[4-1]
        ; 移动次数
        ; 返回参数使用寄存器A[4-1]
        ; 需要使用A[x]、T[x]寄存器、C
    ADD SP, 2
    POP C
    POP A1
    POP A2
    POP A3
    POP A4
    SUB SP, 7
    while_32LSL_Float_Caculate:
        AND C, 0xFF
        JZ while_32LSL_Float_Caculate_End
            MOV T1, A1
            AND T1, 0x80
            PUSH T1
            PUSH 7
            PUSH 0
            MOV CS, MSR
            CALL 8bits_LSR
            POP T1
            ADD SP, 2
            LSL A1

            MOV T2, A2
            AND T2, 0x80
            PUSH T1
            PUSH T2
            PUSH 7
            PUSH 0
            MOV CS, MSR
            CALL 8bits_LSR
            POP T2
            ADD SP, 2
            POP T1
            LSL A2

            OR A2, T1

            MOV T1, A3
            AND T1, 0x80
            PUSH T2
            PUSH T1
            PUSH 7
            PUSH 0
            MOV CS, MSR
            CALL 8bits_LSR
            POP T1
            ADD SP, 2
            POP T2
            LSL A3

            OR A3, T2

            LSL A4
            OR A4, T1

            DEC C
            JMP while_32LSL_Float_Caculate
        while_32LSL_Float_Caculate_End:
    RET

32_SUB:
    ; 函数介绍
        ; 函数功能: A[x] - B[x] = C[x]
        ; 函数使用寄存器: A[x]、B[x]、C
        ; 函数使用栈: A[x]、B[x]、C
        ; 函数返回使用A[X]
        ; 预留一个栈空间返回进位
    
    PUSH A4
    PUSH A3
    PUSH A2
    PUSH A1

    MOV A4, B4
    MOV A3, B3
    MOV A2, B2
    MOV A1, B1

    NOT A4
    NOT A3
    NOT A2
    NOT A1

    MOV B4, 0
    MOV B3, 0
    MOV B2, 0
    MOV B1, 1

    PUSH 0
    MOV CS, MSR
    CALL 32_ADD

    INC SP

    MOV B4, A4
    MOV B3, A3
    MOV B2, A2
    MOV B1, A1

    POP A1
    POP A2
    POP A3
    POP A4

    PUSH 0
    MOV CS, MSR
    CALL 32_ADD


    POP C
    XOR C, 0X01

    ADD SP, 3
    PUSH C
    SUB SP, 2

    RET

32_ADD:
    ; 函数介绍
        ; 函数使用寄存器: A[x]、B[x]、C
        ; 用A[x]、B[x]传入参数、同时预留一个栈返回进位参数
        ; 函数返回使用A[x]和一个栈
    ; 初始化进位(C)为0
    MOV C, 0
    ADD A1, B1
    JNO while_32_not_overflow_1
        INC C
    while_32_not_overflow_1:
    ADD A2, C
    MOV C, 0
    JNO while_32_not_overflow_2
        INC C
    while_32_not_overflow_2:
    ADD A2, B2
    JNO while_32_not_overflow_3
        INC C
    while_32_not_overflow_3:
    ADD A3, C
    MOV C, 0
    JNO while_32_not_overflow_4
        INC C
    while_32_not_overflow_4:
    ADD A3, B3
    JNO while_32_not_overflow_5
        INC C
    while_32_not_overflow_5:
    ADD A4, C
    MOV C, 0
    JNO while_32_not_overflow_6
        INC C
    while_32_not_overflow_6:
    ADD A4, B4
    JNO while_32_not_overflow_7
        INC C
    while_32_not_overflow_7:
    
    ADD SP, 3
    PUSH C
    SUB SP, 2
    RET

32_Regular:
    ; 函数介绍
        ; 注意：该函数是吧符号位及阶码没有何在一起的值变为规格化值
        ; 注意: 该函数处理的符号是0x01表示负号0x00表示正号
        ; 传入参数:
        ; 寄存器A[4-1]传入被规格化数
        ; 栈传入参数:
        ; 阶码
        ; Sign_Result
        ; 函数返回:
        ; A[x]寄存器
    ; 是否为0判断
        MOV T1, A4
        AND T1, 0xFF
        JNZ 数值不为0_32_Regular
        MOV T1, A3
        AND T1, 0xFF
        JNZ 数值不为0_32_Regular
        MOV T1, A2
        AND T1, 0xFF
        JNZ 数值不为0_32_Regular
        MOV T1, A1
        AND T1, 0xFF
        JNZ 数值不为0_32_Regular
        数值为0_32_Regular:
        MOV A4, 0
        MOV A3, 0
        MOV A2, 0
        MOV A1, 0
        RET
    数值不为0_32_Regular:
    AND A4, 0x01
    JZ 结果没有过大_32_Regular
        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1
        PUSH 1
        MOV CS, MSR
        CALL 32LSR
        ADD SP, 5
        ADD SP, 3
        POP T2
        SUB SP, 4
        INC T2
        MOV A, 0xFF
        SUB A, T2
        JNZ 没有溢出_32Regular
            MOV A1, 0
            MOV A2, 0
            MOV A3, 0
        没有溢出_32Regular:
        JMP while_32_Regular_End
    结果没有过大_32_Regular:
        MOV C, 0
        ADD SP, 3
        POP T2; 阶码
        SUB SP, 4
        while_32_Regular:
            MOV T1, A3
            AND T1, 0x80
            JNZ while_32_Regular_End
            PUSH T2
            PUSH C
            PUSH A4
            PUSH A3
            PUSH A2
            PUSH A1
            PUSH 1
            MOV CS, MSR
            CALL 32LSL
            ADD SP, 5
            POP C
            POP T2
            INC C
            MOV A, 24
            SUB A, C
            JZ 数值为0_32_Regular
            DEC T2
            JZ 数值为0_32_Regular
            JMP while_32_Regular
        while_32_Regular_End:
            ADD SP, 2
            POP C; 符号
            SUB SP, 3
            PUSH T2
            PUSH C
            PUSH 7
            PUSH 0
            MOV CS, MSR
            CALL 8bits_LSL
            POP C
            ADD SP, 2
            POP T2

            MOV A4, C
            MOV C, T2
            MOV T1, 0x01
            AND T1, C
            PUSH T1
            PUSH 7
            PUSH 0
            MOV CS, MSR
            CALL 8bits_LSL
            POP T1
            ADD SP, 2

            AND A3, 0b01111111
            OR A3, T1

            LSR C
            OR A4, C

            RET

Expoent_negation:
    ; 函数介绍：
        ; 测试无异常
        ; 函数使用寄存器：T1
        ; 函数对传入阶码进行取反操作
        ; 函数使用栈传入参数
        ; 栈：
        ; 阶码

    ADD SP, 2
    POP T1
    SUB SP, 3

    NOT T1
    ADD T1, 1

    ADD T1, 0B11111110
    ADD SP, 3
    PUSH T1
    SUB SP, 2

    RET

Expoent_ADD:
    ; 函数介绍：
        ; 测试无异常
        ; 函数使用
        ; 函数使用栈传入参数
        ; 入栈参数：
        ; A阶码
        ; B阶码
        ; 0
        ; 函数使用栈返回参数
        ; 无关值
        ; 阶码是否有问题(0为没有溢出，1为有溢出)
        ; 结果
        ; 函数栈：
        ;   阶码正负值记录

    ADD SP, 3
    POP T2
    POP T1
    SUB SP, 5

    PUSH 0

    MOV C, T1
    AND C, 0X80
    JZ 阶码A为负数_Expoent_ADD
        POP C
        OR C, 0B00000010
        PUSH C
    阶码A为负数_Expoent_ADD:
    MOV C, T2
    AND C, 0X80
    JZ 阶码B为负数_Expoent_ADD
        POP C
        OR C, 0B00000001
        PUSH C
    阶码B为负数_Expoent_ADD:

    ADD T1, T2
    ADD T1, 0B10000001

    JNO 相加阶码未溢出_Expoent_ADD
        POP C
        OR C, 0B00000100
        JMP 标志位前三位处理完成_Expoent_ADD
    相加阶码未溢出_Expoent_ADD:
    POP C
    标志位前三位处理完成_Expoent_ADD:

    MOV A, C
    AND A, 0B00000011
    XOR A, 0B00000000
    JNZ 非负负形式相加_Expoent_ADD
        MOV A, T1
        AND A, 0B10000000
        JNZ 负负形式相加出问题_Expoent_ADD
            ADD SP, 4
            PUSH 0
            PUSH T1
            SUB SP, 2
            RET
        负负形式相加出问题_Expoent_ADD:
            ADD SP, 4
            PUSH 1
            PUSH 0
            SUB SP, 2
            RET
    非负负形式相加_Expoent_ADD:
    MOV A, C
    AND A, 0B00000011
    XOR A, 0B00000011
    JNZ 非正正相加形式_Expoent_ADD
        MOV A, T1
        AND A, 0B10000000
        JZ 正正形式相加出问题_Expoent_ADD
            ADD SP, 4
            PUSH 0
            PUSH T1
            SUB SP, 2
            RET
        正正形式相加出问题_Expoent_ADD:
            ADD SP, 4
            PUSH 1
            PUSH 0XFF
            SUB SP, 2
            RET
    非正正相加形式_Expoent_ADD:
    ADD SP, 4
    PUSH 0
    PUSH T1
    SUB SP, 2
    RET

Float_A*B_Caculate:
    ; 测试无异常
    ; 函数介绍：
        ; 函数使用所有寄存器
        ; 函数使用A[X]、B[X]传入参数
        ; 函数返回使用A[X]
        ; 函数栈：
        ; Sign_A(最高位直接表示)
        ; Sign_B
        ; Expoent_A
        ; Expoent_B
        ; 乘法结果是否大于2
        ; 函数注意事项：
        ; 如果传入有阶码为0XFF的值则直接返回无穷大
        ; 如果传入有阶码为0X00的值则直接返回0

    ; 获取A的符号
        MOV C, A4
        AND C, 0X80
        PUSH C
    
    ; 获取B的符号
        MOV C, B4
        AND C, 0X80
        PUSH C

    ; 获取A的阶数
        MOV T1, A4
        MOV T2, A3
        AND T2, 0X80
        JZ A的阶数最后一位是0_Float_A*B_Caculate
            MOV T2, 1
            JMP 取好A的阶数最后一位_Float_A*B_Caculate
        A的阶数最后一位是0_Float_A*B_Caculate:
            MOV T2, 0
        取好A的阶数最后一位_Float_A*B_Caculate:

        LSL T1
        OR T1, T2
        PUSH T1

    ; 获取B的阶数
        MOV T1, B4
        MOV T2, B3
        AND T2, 0X80
        JZ B的阶数最后一位是0_Float_A*B_Caculate
            MOV T2, 1
            JMP 取好B的阶数最后一位_Float_A*B_Caculate
        B的阶数最后一位是0_Float_A*B_Caculate:
            MOV T2, 0
        取好B的阶数最后一位_Float_A*B_Caculate:

        LSL T1
        OR T1, T2
        PUSH T1

    ; 检查B是否为阶数为0XFF的异常值
        POP C
        SUB C, 0XFF
        JNZ B不是阶数为0XFF的异常值_Float_A*B_Caculate
            INC SP
            POP T2
            POP T1
            XOR T1, T2
            OR T1, 0X7F
            MOV A4, T1
            MOV A3, 80
            MOV A2, 0
            MOV A1, 0
            RET
        B不是阶数为0XFF的异常值_Float_A*B_Caculate:
            DEC SP

    ; 检查A是否为阶数为0XFF的异常值
        INC SP
        POP C
        SUB C, 0XFF
        JNZ A不是阶数为0XFF的异常值_Float_A*B_Caculate
            POP T2
            POP T1
            XOR T1, T2
            OR T1, 0X7F
            MOV A4, T1
            MOV A3, 0X80
            MOV A2, 0
            MOV A1, 0
            RET
        A不是阶数为0XFF的异常值_Float_A*B_Caculate:
            SUB SP, 2

    ; 判断B的阶数是否为0的异常并对B进行规整化
        POP C
        DEC SP
        AND C, 0XFF
        JNZ B不是阶数为0的异常值_Float_A*B_Caculate
            ; 是则直接把B当作0,这样就是A*0,直接返回0即可
            MOV A4, 0
            MOV A3, 0
            MOV A2, 0
            MOV A1, 0
            ADD SP, 4
            RET
        B不是阶数为0的异常值_Float_A*B_Caculate:
            MOV B4, 0
            OR B3, 0X80

    ; 判断A的阶数是否为0的异常并对B进行规整化
        INC SP
        POP C
        SUB SP, 2
        AND C, 0XFF
        JNZ A不是阶数为0的异常值_Float_A*B_Caculate
            ; 是则直接把B当作0,这样就是B*0,直接返回0即可
            MOV A4, 0
            MOV A3, 0
            MOV A2, 0
            MOV A1, 0
            ADD SP, 4
            RET
        A不是阶数为0的异常值_Float_A*B_Caculate:
            MOV A4, 0
            OR A3, 0X80

    MUT32

    ; 结果寄存器的顺序改造
        ; 由于乘法的结果是B[X]放大结果A[X]放小结果
        ; 我们通过移动寄存器得到我们想要的顺序
        ; 即A[X]寄存器放大结果B[X]寄存器放小结果

        MOV B4, A4
        MOV B3, A3
        MOV A3, B2
        MOV A2, B1
        MOV A1, B4
        MOV B4, B3

        MOV A4, 0
        MOV B3, 0
        MOV B2, 0
        MOV B1, 0

    ; 检查乘法结果是否大于2
        MOV C, A3
        AND C, 0X80
        JNZ 乘法结果大于2_Float_A*B_Caculate
            PUSH A4
            PUSH A3
            PUSH A2
            PUSH A1
            PUSH 1
            MOV CS, MSR
            CALL 32LSL
            ADD SP, 5
            PUSH 0
            JMP 结束检查惩罚结果是否大于2
        乘法结果大于2_Float_A*B_Caculate:
            PUSH 1
        结束检查惩罚结果是否大于2:

    ; 4舍5入
        AND B4, 0X80
        JZ 不需要4舍5如进1_Float_A*B_Caculate
            OR A1, 0X01
        不需要4舍5如进1_Float_A*B_Caculate:

    ; 最终规格化
        INC SP

        ; 取出A、B的阶数
        POP T2
        POP T1
        SUB SP, 3

        PUSH T1
        PUSH T2
        PUSH 0
        MOV CS, MSR
        CALL Expoent_ADD
        POP T1; 阶码相加结果
        POP T2; 阶码相加是否有问题
        INC SP

        MOV A, T1
        XOR A, 0XFF
        JNZ 阶数相加结果不是无穷_Float_A*B_Caculate
            MOV A2, 0
            MOV A1, 0
            ADD SP, 3
            POP T2
            POP T1
            XOR T1, T2
            OR T1, 0X7F
            MOV A4, T1
            MOV A3, 0X80
            RET
        阶数相加结果不是无穷_Float_A*B_Caculate:
        MOV A, T1
        AND A, 0XFF
        JNZ 阶数相加结果正常_Float_A*B_Caculate
            ; 阶码相加是-127
            MOV A4, 0
            MOV A3, 0
            MOV A2, 0
            MOV A1, 0
            ADD SP, 5
            RET
        阶数相加结果正常_Float_A*B_Caculate:
            MOV T2, 0
            POP C
            DEC SP
            AND C, 0XFF
            JZ 乘法结果没有大于2_Float_A*B_Caculate
                PUSH 0X80
                PUSH T1
                PUSH 0
                MOV CS, MSR
                CALL Expoent_ADD
                POP T1
                POP T2
                INC SP

                AND T2, 0XFF
                JZ 第二次阶码加法没有问题_Float_A*B_Caculate
                    ADD SP, 3
                    POP T1
                    POP T2
                    XOR T1, T2
                    MOV T1, A4
                    OR A4, 0X7F
                    MOV A3, 0X80
                    MOV A2, 0
                    MOV A1, 0
                    RET
                第二次阶码加法没有问题_Float_A*B_Caculate:
            乘法结果没有大于2_Float_A*B_Caculate:

        乘法规则化_Float_A*B_Caculate:
            AND A3, 0X7F
            MOV C, T1
            AND C, 0X01
            JZ 阶码最后一位是0_Float_A*B_Caculate
                OR A3, 0X80
            阶码最后一位是0_Float_A*B_Caculate:

            LSR T1
            MOV A4, T1

            ADD SP, 3
            POP T2
            POP T1
            XOR T1, T2

            OR A4, T1
            

    乘法结束_Float_A*B_Caculate:
        RET

Float_A/B_Caculate:
    ; 函数简介
        ; 使用的寄存器：所有
        ; 传入参数使用A[X]、B[X]
        ; 返回参数使用A[X]
        ; 函数栈结构：
        ;   Sign_A
        ;   Sign_B
        ;   Expoent_A
        ;   Expoent_B
        ;  以下的栈是临时的,做除法时使用
        ;  除法结束时便删除
        ;   B4
        ;   B3
        ;   B2
        ;   B1
        ;   R4
        ;   R3
        ;   R2
        ;   R1

    ; 获取A的符号
        MOV C, A4
        AND C, 0X80
        PUSH C
    
    ; 获取B的符号
        MOV C, B4
        AND C, 0X80
        PUSH C

    ; 获取A的阶数
        MOV T1, A4
        LSL T1
        MOV T2, A3
        AND T2, 0X80
        MOV T2, 0
        JZ A的阶码最后一位是零
            MOV T2, 1
        A的阶码最后一位是零:
        OR T1, T2
        PUSH T1
        MOV A4, 0
        OR A3, 0X80
    
    ; 获取B的阶数
        ; B的阶码要取反
        MOV T1, B4
        LSL T1
        MOV T2, B3
        AND T2, 0X80
        MOV T2, 0
        JZ B的阶码最后一位是零
            MOV T2, 1
        B的阶码最后一位是零:
        OR T1, T2
        ; 检查B是否是不允许的值(0X00 0XFF)
        MOV C, T1
        XOR C, 0XFF
        JNZ B不是无穷大_Float_A/B_Caculate
            MOV A4, 0
            MOV A3, 0
            MOV A2, 0
            MOV A1, 0
            ADD SP, 3
            RET
        B不是无穷大_Float_A/B_Caculate:
        MOV C, T1
        AND T1, 0XFF
        JNZ B阶码正常_Float_A/B_Caculate
            INC SP
            POP T1
            POP T2
            XOR T1, T2
            OR T1, 0X7F
            MOV A4, T1
            MOV A3, 0X80
            MOV A2, 0
            MOV A1, 0
            RET
        B阶码正常_Float_A/B_Caculate:

        NOT T1
        ADD T1, 1
        ADD T1, 0B11111110
        PUSH T1
        MOV B4, 0
        OR B3, 0X80

    ; 入栈被除数B
        PUSH B4
        PUSH B3
        PUSH B2
        PUSH B1

    ; 除法开始
        ; 4次循环固定因此不采用变量循环代码风格
        DIV32
        PUSH A1
        MOV A4, B3
        MOV A3, B2
        MOV A2, B1
        MOV A1, 0

        INC SP
        POP B1
        POP B2
        POP B3
        POP B4

        SUB SP, 5

        DIV32

        PUSH A1

        MOV A4, B3
        MOV A3, B2
        MOV A2, B1
        MOV A1, 0

        ADD SP, 2
        POP B1
        POP B2
        POP B3
        POP B4

        SUB SP, 6

        DIV32

        PUSH A1

        MOV A4, B3
        MOV A3, B2
        MOV A2, B1
        MOV A1, 0

        ADD SP, 3

        POP B1
        POP B2
        POP B3
        POP B4

        SUB SP, 7

        DIV32

        PUSH A1

        POP A1
        POP A2
        POP A3
        POP A4

        ADD SP, 4
    
    ; 阶码相加(之前已经取反)
        POP T1
        POP T2
        SUB SP, 2
        PUSH T2
        PUSH T1
        PUSH 0
        MOV CS, MSR
        CALL Expoent_ADD
        POP T1
        POP T2
        INC SP

        MOV C, T1
        XOR C, 0XFF
        JNZ 除法结果不是无穷大_Float_A/B_Caculate
            ADD SP, 2
            POP T1
            POP T2
            XOR T1, T2
            OR T1, 0X7F
            MOV A4, T1
            MOV A3, 0X80
            MOV A2, 0
            MOV A1, 0
            RET
        除法结果不是无穷大_Float_A/B_Caculate:
        MOV C, T1
        AND C, 0XFF
        JNZ 除法结果不是0_Float_A/B_Caculate
            MOV A4, 0
            MOV A3, 0
            MOV A2, 0
            MOV A1, 0
            ADD SP, 4
            RET
        除法结果不是0_Float_A/B_Caculate:

        AND A4, 0X01
        JZ 除法结果小于1_Float_A/B_Caculate
            PUSH T1
            PUSH A4
            PUSH A3
            PUSH A2
            PUSH A1
            PUSH 0X01
            MOV CS, MSR
            CALL 32LSR
            ADD SP, 5
            POP T1
            JMP 结束除法_Float_A/B_Caculate
        除法结果小于1_Float_A/B_Caculate:
            PUSH T1
            PUSH 0B01111110
            PUSH 0
            MOV CS, MSR
            CALL Expoent_ADD
            POP T1
            POP T2
            INC SP

            MOV C, T1
            AND C, 0XFF
            JNZ 结束除法_Float_A/B_Caculate
                MOV A4, 0
                MOV A3, 0
                MOV A2, 0
                MOV A1, 0
                ADD SP, 4
                RET

    结束除法_Float_A/B_Caculate:
        MOV T2, T1
        AND T2, 0X01
        MOV T2, 0
        JZ 结果阶码最后一位为0_Float_A/B_Caculate
            MOV T2, 0X80
        结果阶码最后一位为0_Float_A/B_Caculate:
        AND A3, 0X7F
        OR A3, T2
        LSR T1
        MOV A4, T1
        ADD SP, 2
        POP T1
        POP T2
        XOR T1, T2
        OR A4, T1
        RET

Round_X:
    ; 函数介绍:
        ; 函数使用的寄存器:
        ; A[X]、B[X]、C、T[X]
        ; 参数输入使用栈:
        ; A[4-1]
        ; 参数返回使用A[X]

    ; 参数传入寄存器
        ADD SP, 2
        POP A1
        POP A2
        POP A3
        POP A4
        SUB SP, 6
        MOV B4, 0XFF
        MOV B3, B4
        MOV B2,B3
        MOV B1, B3

    ; B向左移X位
        MOV T1, A4
        LSL T1
        MOV T2, A3
        AND T2, 0X80
        MOV T2, 0
        JZ 阶码最后一位是0_Round_X
            MOV T2, 0X01
        阶码最后一位是0_Round_X:
        OR T1, T2
        MOV C, T1

        SUB C, 0X7F
        JO 阶码小于0_Round_X
            ; 阶码大于等于0
            MOV C, T1
            MOV A, 0B10010110
            SUB A, C
            JO 数字本生就是整数_Round_X
                MOV C, T1
                SUB C, 0X7F
                MOV A, 0X17
                SUB A, C
                MOV C, A
                PUSH C; 移动次数
                PUSH 0
                PUSH 0
                PUSH 0
                PUSH 1
                PUSH C
                MOV CS, MSR
                CALL 32LSL
                ADD SP, 5
                PUSH A4
                PUSH A3
                PUSH A2
                PUSH A1
                PUSH 1
                MOV CS, MSR
                CALL 32LSR
                ADD SP, 5
                POP C
                PUSH A4
                PUSH A3
                PUSH A2
                PUSH A1

                PUSH 0XFF
                PUSH 0XFF
                PUSH 0XFF
                PUSH 0XFF
                PUSH C
                MOV CS, MSR
                CALL 32LSL
                ADD SP, 5
                PUSH A4
                PUSH A3
                PUSH A2
                PUSH A1
                ADD SP, 4
                POP B1
                POP B2
                POP B3
                POP B4
                SUB SP, 8
                
                ADD SP, 10
                POP A1
                POP A2
                POP A3
                POP A4
                SUB SP, 14
                MOV T2, 0
                AND A4, B4
                JZ JMP_1_Round_X
                    MOV T2, 1
                    JMP End_JMP_Round_X
                JMP_1_Round_X:
                AND A3, B3
                JZ JMP_2_Round_X
                    MOV T2, 1
                    JMP End_JMP_Round_X
                JMP_2_Round_X:
                AND A2, B2
                JZ JMP_3_Round_X
                    MOV T2, 1
                    JMP End_JMP_Round_X
                JMP_3_Round_X:
                AND A1, B1
                JZ JMP_4_Round_X
                    MOV T2, 1
                    JMP End_JMP_Round_X
                JMP_4_Round_X:
                End_JMP_Round_X:
                AND T2, 0XFF
                JZ 不需要加1_Round_X
                    ADD SP, 10
                    POP A1
                    POP A2
                    POP A3
                    POP A4
                    SUB SP, 14
                    MOV T1, A4
                    AND T1, 0X80
                    MOV B4, 0B00111111
                    OR B4, T1
                    MOV B3, 0B10000000
                    MOV B2, 0B00000000
                    MOV B1, 0B00000000
                    MOV CS, MSR
                    CALL Float_A+B_Caculate
                不需要加1_Round_X:
                ADD SP, 10
                POP A1
                POP A2
                POP A3
                POP A4
                SUB SP, 14
                POP B1
                POP B2
                POP B3
                POP B4
                ADD SP, 4
                AND A4, B4
                AND A3, B3
                AND A2, B2
                AND A1, B1
                RET
            数字本生就是整数_Round_X:
                RET
        阶码小于0_Round_X:
            MOV C, T1
            XOR C, 0X7E
            JNZ 阶码小于负1_Round_X
                OR A4, 0X3F
                MOV A3, 0X80
                MOV A2, 0
                MOV A1, 0
                RET
            阶码小于负1_Round_X:
                MOV A4, 0
                MOV A3, 0
                MOV A2, 0
                MOV A1, 0
                RET

E_X_Calculate:
    ; 函数介绍:
        ; 输入：
        ; A[X]
        ; 栈:
        ; X
        ; k
        ; r
        ; e_r

    ; 0和无穷处理
        MOV T1, A4
        AND T1, 0X7F
        MOV T2, A3
        AND T2, 0X80
        OR T1, T2
        JNZ 输入参数的阶数不是0_E_X_Calculate
            MOV A4, 0X3F
            MOV A3, 0X80
            MOV A2, 0
            MOV A1, 0
            RET
        输入参数的阶数不是0_E_X_Calculate:
        MOV C, A4
        AND C, 0X80
        MOV T1, A4
        MOV T2, A3
        OR T1, 0X80
        OR T2, 0X7F
        XOR T1, 0XFF
        XOR T2, 0XFF
        OR T1, T2
        JNZ 输入参数的阶数不是无穷_E_X_Calculate
            AND C, 0XFF
            JZ 输入参数是正无穷_E_X_Calculate
                MOV A4, 0
                MOV A3, 0
                MOV A2, 0
                MOV A1, 0
                RET
            输入参数是正无穷_E_X_Calculate:
            MOV A4, 0X7F
            MOV A3, 0X80
            MOV A2, 0X00
            MOV A1, 0X00
            RET
        输入参数的阶数不是无穷_E_X_Calculate:


    ; Save_X
        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1

    ; k_Calculate:
        ; 顺带直接计算k
        MOV B4, 0B00111111
        MOV B3, 0B10111000
        MOV B2, 0B10101010
        MOV B1, 0B00111011

        MOV CS, MSR
        CALL Float_A*B_Caculate

        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1

        MOV CS, MSR
        CALL Round_X
        ADD SP, 4
        ; 入栈k
        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1

    ; r_Calculate:
        MOV B4, 0B00111111
        MOV B3, 0B00110001
        MOV B2, 0B01110010
        MOV B1, 0B00011000

        MOV CS, MSR
        CALL Float_A*B_Caculate

        MOV B4, A4
        MOV B3, A3
        MOV B2, A2
        MOV B1, A1

        XOR B4, 0X80

        ADD SP, 4
        POP A1
        POP A2
        POP A3
        POP A4
        SUB SP, 8

        MOV CS, MSR
        CALL Float_A+B_Caculate

        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1
    
    e_r_Calculate:
        ; r此时就在A[X]中
        MOV B4, 0B00111111
        MOV B3, 0B10000000
        MOV B2, 0
        MOV B1, 0

        ; 1 + r
        MOV CS, MSR
        CALL Float_A+B_Caculate

        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1

        ADD SP, 4
        POP A1
        POP A2
        POP A3
        POP A4
        SUB SP, 8
        MOV B4, A4
        MOV B3, A3
        MOV B2, A2
        MOV B1, A1

        ; r**2
        MOV CS, MSR
        CALL Float_A*B_Caculate

        MOV B4, 0B00111111
        MOV B3, 0B00000000
        MOV B2, 0B00000000
        MOV B1, 0B00000000

        ; 0.5*r**2
        MOV CS, MSR
        CALL Float_A*B_Caculate

        POP B1
        POP B2
        POP B3
        POP B4
        SUB SP, 4


        ; 1 + r + 0.5*r**2
        MOV CS, MSR
        CALL Float_A+B_Caculate

        ADD SP, 4
        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1

        ADD SP, 4
        POP A1
        POP A2
        POP A3
        POP A4
        SUB SP, 8

        MOV B4, A4
        MOV B3, A3
        MOV B2, A2
        MOV B1, A1

        ; r**2
        MOV CS, MSR
        CALL Float_A*B_Caculate

        ADD SP, 4
        POP B1
        POP B2
        POP B3
        POP B4
        SUB SP, 8

        ; r**3
        MOV CS, MSR
        CALL Float_A*B_Caculate

        MOV B4, 0B00111110
        MOV B3, 0B00101010
        MOV B2, 0B10101010
        MOV B1, 0B10101011

        ; 1/6*r**3
        MOV CS, MSR
        CALL Float_A*B_Caculate

        POP B1
        POP B2
        POP B3
        POP B4
        SUB SP, 4

        ; 1 + r + 0.5*r**2 + 1/6*r**3
        MOV CS, MSR
        CALL Float_A+B_Caculate
        ADD SP, 4
        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1
    
    ; Result
        ADD SP, 8
        POP A1
        POP A2
        POP A3
        POP A4
        SUB SP, 12

        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1

        MOV CS, MSR
        CALL 2**K

        ADD SP, 4

        POP B1
        POP B2
        POP B3
        POP B4

        SUB SP, 4

        MOV CS, MSR
        CALL Float_A*B_Caculate

    ; 返回
        ADD SP, 16
        RET

2**K:
    ; 函数介绍:
        ; 测试无异常
        ; 输入使用栈：
        ; A[4-1]
        ; 输出使用寄存器:
        ; A[X]
        ; 函数会使用寄存器:
        ;   T1 T2 C A[X]
    ; 获取参数K
        ADD SP, 2
        POP A1
        POP A2
        POP A3
        POP A4
        SUB SP, 6
    ; 处理逻辑
        MOV T2, A4
        AND T2, 0X80
        JZ K值大于0_2**K
            MOV T2, 1
        K值大于0_2**K:
        ; K值等于0在K值大于0中处理
        PUSH T2 ; K值的正负0正1负

        MOV T1, A4
        LSL T1
        MOV T2, A3
        AND T2, 0X80
        JZ K值的阶码最后一位是0_2**K
            OR T1, 0X01
        K值的阶码最后一位是0_2**K:
        SUB T1, 0X7F
        JNO K值阶码不小于0_2**K
            ; 结果就是1
            JMP 2**K的值是1_2**K
        K值阶码不小于0_2**K:
            MOV A, 0X07
            SUB A, T1
            MOV T1, A
            JNZ K值阶码小于等于7_2**K
                ; K值过大直接当无穷或0处理
                POP T2
                DEC SP
                AND T2, 0XFF
                JZ 2**K的值是正无穷_2**K
                JMP 2**K的值是1_2**K
        K值阶码小于等于7_2**K:
            MOV C, A3
            OR C, 0X80
            PUSH C
            PUSH T1
            PUSH 0
            MOV CS, MSR
            CALL 8bits_LSR
            POP T1
            ADD SP, 2
            MOV C, 0X7F
            POP T2
            DEC SP
            AND T2, 0XFF
            JZ K值是大于零的要做加法_2**K
                SUB C, T1
                MOV T1, C
                AND T1, 0X80
                MOV T1, C
                JNZ 2**K的值是1_2**K
                JMP 2**K的值是正常的_2**K
            K值是大于零的要做加法_2**K:
                ADD C, T1
                MOV T1, C
                AND T1, 0X80
                MOV T1, C
                JZ 2**K的值是正无穷_2**K
            
            2**K的值是正常的_2**K:
                MOV T2, T1
                LSR T1
                MOV A4, T1
                AND T2, 0X01
                MOV A3, 0
                JZ 2**K的结果的阶码最后一位是0_2**K
                    MOV A3, 0X80
                2**K的结果的阶码最后一位是0_2**K:
                MOV A2, 0
                MOV A1, 0
                INC SP
                RET

    2**K的值是正无穷_2**K:
        MOV A4, 0X7F
        MOV A3, 0X80
        MOV A2, 0X00
        MOV A1, 0X00
        INC SP
        RET

    2**K的值是1_2**K:
        MOV A4, 0X3F
        MOV A3, 0X80
        MOV A2, 0X00
        MOV A1, 0X00
        INC SP

        RET

Thanh_Caculate:
    ; 函数介绍:
        ; 传入参数使用栈
        ;  A[4-1]
        ; 输出使用寄存器:
        ;  A[X]
        ; 函数会使用寄存器:
        ;  T1 T2 C A[X]
    ; 获取参数
        ADD SP, 2
        POP A1
        POP A2
        POP A3
        POP A4
        SUB SP, 6

    ; 0和无穷处理
        MOV T1, A4
        AND T1, 0X7F
        MOV T2, A3
        AND T2, 0X80
        OR T1, T2
        JNZ 输入参数的阶数不是0_Thanh_Caculate
            MOV A4, 0
            MOV A3, 0
            MOV A2, 0
            MOV A1, 0
            RET
        输入参数的阶数不是0_Thanh_Caculate:
        MOV C, A4
        AND C, 0X80
        MOV T1, A4
        MOV T2, A3
        OR T1, 0X80
        OR T2, 0X7F
        XOR T1, 0XFF
        XOR T2, 0XFF
        OR T1, T2
        JNZ 输入参数的阶数不是无穷_Thanh_Caculate
            MOV A4, 0X3F
            MOV A3, 0X80
            MOV A2, 0X00
            MOV A1, 0X00
            OR A4, C
            RET
        输入参数的阶数不是无穷_Thanh_Caculate:

    ; 大于5处理
        MOV C, A4
        AND C, 0X80
        PUSH C
        AND A4, 0X7F
        MOV B4, 0B01000000
        MOV B3, 0B10100000
        MOV B2, 0
        MOV B1, 0

        PUSH 0
        MOV CS, MSR
        CALL 32_SUB
        POP C

        OR C, C
        JNZ 值的大小在5以内_Thanh_Caculate
            MOV A4, 0X3F
            MOV A3, 0X80
            MOV A2, 0
            MOV A1, 0
            POP C
            OR A4, C
            RET
        值的大小在5以内_Thanh_Caculate:
            INC SP
            ADD SP, 2
            POP A1
            POP A2
            POP A3
            POP A4
            SUB SP, 6
    
    ; 小于0.01处理
        MOV C, A4
        AND C, 0X80
        PUSH C
        AND A4, 0X7F
        MOV B4, 0B00111100
        MOV B3, 0B00100011
        MOV B2, 0B11010111
        MOV B1, 0B00001010

        PUSH 0
        MOV CS, MSR
        CALL 32_SUB
        POP C

        OR C, C
        JZ 值的大小在0.01以外_Thanh_Caculate
            MOV A4, 0
            MOV A3, 0
            MOV A2, 0
            MOV A1, 0
            POP C
            OR A4, C
            RET
        值的大小在0.01以外_Thanh_Caculate:
            INC SP
            ADD SP, 2
            POP A1
            POP A2
            POP A3
            POP A4
            SUB SP, 6

    ; Sign_Recode
        MOV T1, A4
        AND T1, 0X80
        PUSH T1

        AND A4, 0X7F
        MOV B4, 0XC0
        MOV B3, 0
        MOV B2, 0
        MOV B1, 0

        ; -2x
        MOV CS, MSR
        CALL Float_A*B_Caculate

        ; E^(-2|X|)
        MOV CS, MSR
        CALL E_X_Calculate

        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1

        MOV B4, 0X3F
        MOV B3, 0X80
        MOV B2, 0
        MOV B1, 0

        ; 1 + E^(-2|X|)
        MOV CS, MSR
        CALL Float_A+B_Caculate

        POP B1
        POP B2
        POP B3
        POP B4

        PUSH A4
        PUSH A3
        PUSH A2
        PUSH A1

        XOR B4, 0X80

        MOV A4, 0X3F
        MOV A3, 0X80
        MOV A2, 0
        MOV A1, 0

        ; 1 - E^(-2|X|)
        MOV CS, MSR
        CALL Float_A+B_Caculate

        POP B1
        POP B2
        POP B3
        POP B4

        ; (1 - E^(-2|X|)) / (1 + E^(-2|X|))
        MOV CS, MSR
        CALL Float_A/B_Caculate

        ; Sign_Result
        POP C
        OR A4, C

        RET
