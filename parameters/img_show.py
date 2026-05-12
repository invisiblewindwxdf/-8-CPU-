import numpy as np
import matplotlib.pyplot as plt

# 换成你的txt文件路径
file_path = r"parameters\image2.txt"

with open(file_path, "r", encoding="utf-8") as f:
    line = f.readline().strip()
    # 这里改成先转浮点数，再转整数！
    numbers = list(map(float, line.split(",")))

# 检查数据长度
if len(numbers) != 784:
    print(f"错误：数据长度是 {len(numbers)}，需要 784 个数字！")
else:
    # 转成 28x28 灰度图
    img_array = np.array(numbers).reshape(28, 28)

    plt.rcParams["font.sans-serif"] = ["SimHei"]
    plt.rcParams["axes.unicode_minus"] = False
    # 显示图片
    plt.figure(figsize=(4, 4))
    plt.imshow(img_array, cmap="gray")
    plt.axis("off")
    plt.title("28x28 灰度图像")
    plt.show()