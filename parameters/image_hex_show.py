import struct
import numpy as np
import matplotlib.pyplot as plt

# 换成你的txt文件路径
file_path = r"parameters\image_hex.txt"

# 存储所有读取到的字节（十六进制转字节）
all_bytes = []

# 1. 读取所有 hex 字节
with open(file_path, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        
        # 按制表符 \t 分割每个 2 位 hex
        hex_list = line.split("\t")
        for hx in hex_list:
            hx = hx.strip()
            if hx:
                # 把 "00" 转成 1 字节
                all_bytes.append(bytes.fromhex(hx))

# 2. 拼接成完整字节流
byte_data = b"".join(all_bytes)

# 3. 大端序 32 位浮点数 解析（!f = 大端 float32）
float_count = len(byte_data) // 4
floats = []
for i in range(float_count):
    # 每 4 个字节解析一个浮点数
    f_val = struct.unpack("!f", byte_data[i*4 : (i+1)*4])[0]
    floats.append(f_val)

# 4. 转 28x28 图片并显示
if len(floats) >= 784:
    img = np.array(floats[:784]).reshape(28, 28)
    
    plt.rcParams['font.sans-serif'] = ['SimHei']
    plt.rcParams['axes.unicode_minus'] = False
    plt.figure(figsize=(4,4))
    plt.imshow(img, cmap="gray")
    plt.axis("off")
    plt.title("28×28 灰度图（大端32位浮点数）")
    plt.show()
else:
    print(f"解析出 {len(floats)} 个浮点数，需要 784 个")