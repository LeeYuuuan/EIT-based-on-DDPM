
import torch
import matplotlib.pyplot as plt

# set hyper-parameters
num_steps = 1000  
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
print(alphas_prod)

def q_x(x_0, t):
    """calculate sample value in any given t"""
    
    noise = torch.randn_like(x_0)
    sigma = alphas_bar_sqrt[t] * x_0
    miu = one_minus_alphas_bar_sqrt[t]
    return (sigma + miu * noise)


    
    
    