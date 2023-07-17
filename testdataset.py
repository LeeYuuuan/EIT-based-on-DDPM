
import torch
import numpy as np
import matplotlib.pyplot as plt
from main import q_x
num_steps = 100
betas = torch.linspace(0.0001, 0.02, num_steps)
alphas = 1 - betas
alphas_prod = torch.cumprod(alphas,0)
alphas_bar_sqrt = torch.sqrt(alphas_prod)
one_minus_alphas_bar_log = torch.log(1 - alphas_prod)
one_minus_alphas_bar_sqrt = torch.sqrt(1 - alphas_prod)
alphas_prod_p = torch.cat([torch.tensor([1]).float(),alphas_prod[:-1]],0)

assert alphas.shape==alphas_prod.shape==alphas_prod_p.shape==\
alphas_bar_sqrt.shape==one_minus_alphas_bar_log.shape\
==one_minus_alphas_bar_sqrt.shape
print("all the same shape",betas.shape)
print(len(alphas_prod_p))

from sklearn.datasets import make_s_curve

s_curve, _ = make_s_curve(10**4, noise=0.1)
s_curve = s_curve[:, [0, 2]]/10.0
print("shape of moons:", np.shape(s_curve))
data = s_curve.T
fig, ax = plt.subplots()
ax.scatter(*data, color="red", edgecolor="white")
ax.axis('off')
dataset = torch.Tensor(s_curve).float()

num_shows = 20
fig, axs = plt.subplots(2, 10, figsize=(28, 3))

for i in range(num_shows):
    j = i // 10
    k = i % 10
    q_i = q_x(dataset, torch.tensor([i*num_steps // num_steps]))
    axs[j, k].scatter(q_i[:, 0], q_i[:, 1], color="red")
    axs[j, k].set_axis_off()
    axs[j, k].set_title('$q(\mathbf{x}_{'+str(i*num_steps//num_shows)+'})$')
plt.show()
    