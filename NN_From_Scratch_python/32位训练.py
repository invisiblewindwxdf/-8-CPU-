import numpy as np
import math
import matplotlib.pyplot as plt
from pathlib import Path
import struct
import copy

# 数据集路径
dataset_path = Path('./dataset')
train_img_path = './NN_From_Scratch_python/dataset/train-images.idx3-ubyte'
train_lab_path = './NN_From_Scratch_python/dataset/train-labels.idx1-ubyte'
test_img_path = './NN_From_Scratch_python/dataset/t10k-images.idx3-ubyte'
test_lab_path = './NN_From_Scratch_python/dataset/t10k-labels.idx1-ubyte'

# 激活函数（输出保持float32）
def tanh(x):
    return np.tanh(x.astype(np.float32))  # 显式转为float32计算

def softmax(x):
    x = x.astype(np.float32)  # 转为float32
    exp = np.exp(x - x.max())  # 防止指数爆炸
    return exp / exp.sum()

def relu(x):
    x = x.astype(np.float32)
    return np.maximum(0, x)

dimensions = [28*28, 10]
activation = [tanh, softmax, relu]
distribution = [
    {'b': [0, 0]},
    {'b': [0, 0],
     'w': [-math.sqrt(6/(dimensions[0]+dimensions[1])), math.sqrt(6/(dimensions[0]+dimensions[1]))]}
]

# 初始化参数b（指定float32）
def init_parameters_b(layer):
    dist = distribution[layer]['b']
    # 生成float32类型的随机数
    return np.random.rand(dimensions[layer]).astype(np.float32) * (dist[1]-dist[0]) + dist[0]

# 初始化参数w（指定float32）
def init_parameters_w(layer):
    dist = distribution[layer]['w']
    # 生成float32类型的随机数
    return np.random.rand(dimensions[layer-1], dimensions[layer]).astype(np.float32) * (dist[1]-dist[0]) + dist[0]

# 初始化参数方法
def init_parameters():
    parameter = []
    for i in range(len(distribution)):
        layer_parameter = {}
        for j in distribution[i].keys():
            if j == 'b':
                layer_parameter['b'] = init_parameters_b(i)
                continue
            if j == 'w':
                layer_parameter['w'] = init_parameters_w(i)
                continue
        parameter.append(layer_parameter)
    return parameter

# 预测函数（全程float32计算）
def predict(img, parameters):
    # 先将输入img转为float32
    img = img.astype(np.float32)
    l0_in = img + parameters[0]['b']
    l0_out = activation[0](l0_in)
    l1_in = np.dot(l0_out, parameters[1]['w']) + parameters[1]['b']
    l1_out = activation[1](l1_in)
    return l1_out

# 数据集数量配置
train_num = 50000
valid_num = 10000
test_num = 10000

# 读入训练/验证图片集（转为float32）
with open(train_img_path, 'rb') as f:
    struct.unpack('>4i', f.read(16))
    tmp_img = np.fromfile(f, dtype=np.uint8).reshape(-1, 28*28).astype(np.float32)  # 转为float32
    train_img = tmp_img[:train_num]
    valid_img = tmp_img[train_num:]

# 读入测试图片集（转为float32）
with open(test_img_path, 'rb') as f:
    struct.unpack('>4i', f.read(16))
    test_img = np.fromfile(f, dtype=np.uint8).reshape(-1, 28*28).astype(np.float32)  # 转为float32

# 读入训练/验证标签（标签是整数，无需转float32）
with open(train_lab_path, 'rb') as f:
    struct.unpack('>2i', f.read(8))
    tmp_lab = np.fromfile(f, dtype=np.uint8)
    train_lab = tmp_lab[:train_num]
    valid_lab = tmp_lab[train_num:]

# 读入测试标签
with open(test_lab_path, 'rb') as f:
    struct.unpack('>2i', f.read(8))
    test_lab = np.fromfile(f, dtype=np.uint8)

# 展示图片函数（无修改）
def show_train(index):
    plt.imshow(train_img[index].reshape(28,28), cmap='gray')
    print('label  = {}'.format(train_lab[index]))
    plt.show()

def show_valid(index):
    plt.imshow(valid_img[index].reshape(28,28), cmap='gray')
    print('label  = {}'.format(valid_lab[index]))
    plt.show()

def show_test(index):
    plt.imshow(test_img[index].reshape(28,28), cmap='gray')
    print('label  = {}'.format(test_lab[index]))
    plt.show()

# 激活函数导数（输出float32）
def d_softmax(data):
    data = data.astype(np.float32)
    sm = softmax(data)
    return (np.diag(sm) - np.outer(sm, sm)).astype(np.float32)

def d_tanh(data):
    data = data.astype(np.float32)
    return (1 / (np.cosh(data))**2).astype(np.float32)

def d_relu(data):
    data = data.astype(np.float32)
    return np.diag(np.where(data>0, 1, 0)).astype(np.float32)

differential = {softmax:d_softmax, tanh:d_tanh, relu:d_relu}

# 标签onehot编码（float32）
onehot = np.identity(dimensions[-1]).astype(np.float32)

# 平方差损失（float32计算）
def sqr_loss(img, lab, parameters):
    img = img.astype(np.float32)
    y_pred = predict(img, parameters)
    y = onehot[lab]
    diff = y - y_pred
    return np.dot(diff, diff).astype(np.float32)

# 梯度计算（全程float32）
def grad_parameters(img, lab, parameters):
    img = img.astype(np.float32)
    l0_in = img + parameters[0]['b']
    l0_out = activation[0](l0_in)
    l1_in = np.dot(l0_out, parameters[1]['w']) + parameters[1]['b']
    l1_out = activation[1](l1_in)
    
    diff = onehot[lab] - l1_out
    act1 = np.dot(differential[activation[1]](l1_in), diff)

    grad_b1 = (-2 * act1).astype(np.float32)
    grad_w1 = (-2 * np.outer(l0_out, act1)).astype(np.float32)
    grad_b0 = (-2 * differential[activation[0]](l0_in) * np.dot(parameters[1]['w'], act1)).astype(np.float32)

    return {'b1':grad_b1, 'w1':grad_w1, 'b0':grad_b0}

# 梯度测试函数（无核心修改，仅计算为float32）
def test_b1(h):
    for i in range(10):
        img_i = np.random.randint(train_num)
        test_parameters = init_parameters()
        derivative = grad_parameters(train_img[img_i], train_lab[img_i], test_parameters)['b1']
        value1 = sqr_loss(train_img[img_i], train_lab[img_i], test_parameters)
        test_parameters[1]['b'][i] += h
        value2 = sqr_loss(train_img[img_i], train_lab[img_i], test_parameters)
        print(derivative[i] - (value2-value1)/h)

def test_b0(h):
    grad_list = []
    for i in range(784):
        img_i = np.random.randint(train_num)
        test_parameters = init_parameters()
        derivative = grad_parameters(train_img[img_i], train_lab[img_i], test_parameters)['b0']
        value1 = sqr_loss(train_img[img_i], train_lab[img_i], test_parameters)
        test_parameters[0]['b'][i] += h
        value2 = sqr_loss(train_img[img_i], train_lab[img_i], test_parameters)
        grad_list.append(derivative[i] - (value2-value1)/h)
    return grad_list

def test_w1(h):
    grad_list = []
    for i in range(784):
        for j in range(10):
            img_i = np.random.randint(train_num)
            test_parameters = init_parameters()
            derivative = grad_parameters(train_img[img_i], train_lab[img_i], test_parameters)['w1']
            value1 = sqr_loss(train_img[img_i], train_lab[img_i], test_parameters)
            test_parameters[1]['w'][i][j] += h
            value2 = sqr_loss(train_img[img_i], train_lab[img_i], test_parameters)
            grad_list.append(derivative[i][j] - (value2-value1)/h)
    return grad_list

# 验证损失（float32）
def valid_loss(parameters):
    loss_accu = 0.0
    for img_i in range(valid_num):
        loss_accu += sqr_loss(valid_img[img_i], valid_lab[img_i], parameters).astype(np.float32)
    return loss_accu

# 验证准确率（无精度修改，仅统计）
def valid_accuracy(parameters):
    correct = [predict(valid_img[img_i], parameters).argmax() == valid_lab[img_i] for img_i in range(valid_num)]
    print("validation accuracy:{}".format(correct.count(True)/len(correct)))

# 批训练（float32）
batch_size = 100
def train_batch(current_batch, parameters):
    grad_accu = grad_parameters(train_img[current_batch*batch_size+0], train_lab[current_batch*batch_size+0], parameters)
    # 初始化梯度为float32
    for key in grad_accu.keys():
        grad_accu[key] = grad_accu[key].astype(np.float32)
    
    for img_i in range(1, batch_size):
        grad_tmp = grad_parameters(train_img[current_batch*batch_size+img_i], train_lab[current_batch*batch_size+img_i], parameters)
        for key in grad_accu.keys():
            grad_accu[key] += grad_tmp[key].astype(np.float32)
    
    for key in grad_accu.keys():
        grad_accu[key] = (grad_accu[key] / batch_size).astype(np.float32)
    return grad_accu

# 参数更新（保持float32）
def combine_parameters(parameters, grad, learn_rate):
    parameter_tmp = copy.deepcopy(parameters)
    # 确保更新后仍为float32
    parameter_tmp[0]['b'] = (parameter_tmp[0]['b'] - learn_rate * grad['b0']).astype(np.float32)
    parameter_tmp[1]['b'] = (parameter_tmp[1]['b'] - learn_rate * grad['b1']).astype(np.float32)
    parameter_tmp[1]['w'] = (parameter_tmp[1]['w'] - learn_rate * grad['w1']).astype(np.float32)
    return parameter_tmp

# 训练函数
def learn_self(learn_rate):
    global parameters
    for i in range(train_num//batch_size):
        if i % 100 == 99:
            print("running batch {}/{}".format(i+1, train_num//batch_size))
        grad_tmp = train_batch(i, parameters)
        parameters = combine_parameters(parameters, grad_tmp, learn_rate)

# 初始化参数 + 训练
parameters = init_parameters()
# 验证初始精度
valid_accuracy(parameters)
# 训练（学习率1）
learn_self(1)
# 验证训练后精度
valid_accuracy(parameters)

# 展示示例图片
show_train(0)
