# 配置文件路径（修改为你的txt文件名）
txt_file = r"parameters\最终结果.txt"
bin_file = r"parameters\最终结果.bin"

# 读取所有十六进制字节
with open(txt_file, "r", encoding="utf-8") as f:
    lines = f.readlines()
    line_datas = [line.strip().split("\t") for line in lines]

# 按顺序写入二进制文件
with open(bin_file, "wb") as f:
    for line_data in line_datas:
        for hex_str in line_data:
            # 跳过空字符串（防止行尾制表符产生空值）
            if not hex_str:
                continue
            
            # 把 16进制字符串 → 1字节二进制
            byte_value = int(hex_str, 16)
            f.write(bytes([byte_value]))

print("✅ 写入完成！所有十六进制字节已按顺序写入 parameter.bin")