import torch.nn as nn
import torch
import matplotlib.pyplot as plt


batch_size = 128
n_steps = 100
embedding = nn.Embedding(100, 128)
t = torch.randint(0, n_steps, size= (batch_size//2,))
t = torch.cat([t, n_steps-1-t], dim=0)
t = t.unsqueeze(-1)

# set hyper-parameters

betas = torch.linspace(0.0001, 0.02, n_steps)
alphas = 1 - betas
alphas_prod = torch.cumprod(alphas,0)
alphas_bar_sqrt = torch.sqrt(alphas_prod)
# print(alphas_bar_sqrt)
# print(alphas_bar_sqrt[t])
x = torch.tensor([1, 0, 2, 3, 6])
y = torch.randint(0, 5, size= (64,))
y = torch.cat([y, 5-1-y], dim=0)
y = y.unsqueeze(-1)
#print(x[y])
print(betas)