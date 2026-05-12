from pathlib import Path
import struct
import numpy as np
import random

# 数据集路径
dataset_path = Path('../dataset')
# 训练图片集路径
train_img_path = './NN_From_Scratch_python/dataset/train-images.idx3-ubyte'
train_lab_path = './NN_From_Scratch_python/dataset/train-labels.idx1-ubyte'
test_img_path = './NN_From_Scratch_python/dataset/t10k-images.idx3-ubyte'
test_lab_path = './NN_From_Scratch_python/dataset/t10k-labels.idx1-ubyte'


# 训练50000个，验证10000个，测试10000个
train_num = 50000
valid_num = 10000
test_num = 10000

# 读入训练图片集和验证图片集
with open(train_img_path,'rb') as f:
	struct.unpack('>4i',f.read(16))
	tmp_img = np.fromfile(f,dtype = np.uint8).reshape(-1,28*28)
	train_img = tmp_img[:train_num]
	valid_img = tmp_img[train_num:]

# 读入测试图片集
with open(test_img_path,'rb') as f:
	struct.unpack('>4i',f.read(16))
	test_img = np.fromfile(f,dtype = np.uint8).reshape(-1,28*28)


# 读入训练标签和验证标签
with open(train_lab_path,'rb') as f:
	struct.unpack('>2i',f.read(8))
	tmp_lab = np.fromfile(f,dtype = np.uint8)
	train_lab = tmp_lab[:train_num]
	valid_lab = tmp_lab[train_num:]

# 读入测试标签
with open(test_lab_path,'rb') as f:
	struct.unpack('>2i',f.read(8))
	test_lab = np.fromfile(f,dtype = np.uint8)

print('数据集加载完毕')

# 1. 随机选择一张测试集图片
random_index = random.randint(0, test_num - 1)  # 0~9999 随机
selected_image = test_img[random_index]  # 形状 (784,)
selected_label = test_lab[random_index]

# 2. 控制台输出信息
print(f"✅ 随机选中测试集图片编号：{random_index}")
print(f"✅ 该图片对应标签(label)：{selected_label}")

# 3. 将像素值从 uint8 转为 float32
image_float32 = selected_image.astype(np.float32)

# 4. 转为逗号分隔的字符串（干净格式）
pixel_str = ",".join([str(p) for p in image_float32])

# 5. 写入 image.txt 文件
with open(r".\image2.txt", "w", encoding="utf-8") as f:
    f.write(pixel_str)

print("✅ 像素数据已写入 image.txt，格式：float32，逗号分隔")