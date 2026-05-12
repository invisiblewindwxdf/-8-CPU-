import struct
import numpy as np
import matplotlib.pyplot as plt

# ------------------------------------------------------
# 【修复】float32 精度 指数函数 e^x（严格单精度）
# ------------------------------------------------------
def exp_f32(x):
    x = np.float32(x)
    one = np.float32(1.0)
    res = one
    term = one
    n = 1
    # f32 机器精度，不无限迭代
    for _ in range(20):
        term = term * x / np.float32(n)
        res += term
        n += 1
    return np.float32(res)

# ------------------------------------------------------
# 【修复】float32 精度 tanh（严格单精度）
# ------------------------------------------------------
def tanh_f32(x):
    x = np.float32(x)
    sign = np.float32(1.0) if x >= 0 else np.float32(-1.0)
    x_abs = abs(x)

    if x_abs > np.float32(5.0):
        return sign

    if x_abs < np.float32(0.01):
        return sign * x

    y = exp_f32(np.float32(-2.0) * x_abs)
    res = (np.float32(1.0) - y) / (np.float32(1.0) + y)
    return sign * res

# ========================
# 读取二进制（你原来的）
# ========================
float_32_list = []

with open(r'parameters\parameter.bin', 'rb') as f:
    while True:
        Bytes = f.read(4)
        if not Bytes:
            break
        if len(Bytes) < 4:
            break
        float_32_list.append(struct.unpack('>f', Bytes)[0])

x = float_32_list[0:784]
b0 = float_32_list[784:784+784]
w1 = float_32_list[784+784 : 784+784+784*10]
b1 = float_32_list[784+784+784*10 : 784+784+784*10+10]

# ========================
# 【修复】全部转 float32
# ========================
x = np.array(x, dtype=np.float32)
b0 = np.array(b0, dtype=np.float32)
w1 = np.array(w1, dtype=np.float32).reshape(10, 784)
b1 = np.array(b1, dtype=np.float32)

# ========================
# 【修复】第一层推理（f32 + tanh_f32）
# ========================
h = np.zeros(784, dtype=np.float32)
for i in range(784):
    val = b0[i] + x[i]
    h[i] = tanh_f32(val)

# ========================
# 【修复】输出层（纯 f32 计算）
# ========================
out = np.zeros(10, dtype=np.float32)
for i in range(10):
    s = np.float32(0.0)
    for j in range(784):
        s += h[j] * w1[i, j]
    s += b1[i]
    out[i] = s

# ========================
# 输出结果（严格大端 f32）
# ========================
print("==== 输出 10 个结果 ====")
for i in range(10):
    print(f"out[{i}] = {out[i]}")
    # 【关键】打包成 大端 float32
    print("二进制(大端f32):", struct.pack('>f', out[i]).hex(' ').upper())
    print("-"*30)