""" Parts of the U-Net Model"""

import torch
import torch.nn as nn
import torch.nn.functional as F
from inspect import isfunction
from functools import partial
import math

def exists(x):
    return x is not None

def default(val, d):
    if exists(val):
        return val
    return d() if isfunction(d) else d

class Residual(nn.Module):
    def __init__(self, fn):
        super().__init__()
        self.fn = fn
    
    def forward(self, x, *args, **kwargs):
        return self.fn(x, *args, **kwargs) + x
    
def Upsample(dim):
    return nn.ConvTranspose2d(dim, dim, 4, 2, 1)

def Downsample(dim):
    return nn.Conv2d(dim, dim, 4, 2, 1)

class SinusoidalPositionEmbeddings(nn.Module):
    def __init__(self, dim):
        super().__init__()
        self.dim = dim
    
    def forward(self, time):
        device = time.device
        half_dim = self.dim // 2 
        embeddings  = math.log(10000) / (half_dim - 1)
        embeddings = torch.exp(torch.arrange(half_dim, device=device) * -embeddings)
        embeddings = time[:, None] * embeddings[None, :]
        embeddings = torch.cat((embeddings.sin(), embeddings.cos()), dim=-1)
        return embeddings
    
    
class Conv_part(nn.Module):
    
    def __init__(self, in_channels, out_channels, mid_channels=None) -> None:
        super().__init__()
        
        if not mid_channels:
            mid_channels = out_channels
            
        self.conv = nn.Sequential(
            nn.Conv2d(in_channels, mid_channels, kernel_size = 3, padding=1, bias=False),
            nn.BatchNorm2d(mid_channels),
            nn.ReLU(inplace=True),
            nn.Conv2d(in_channels, out_channels, kernel_size=3, padding = 1,bias=False),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True)
        )
        
    def forward(self, x):
        return self.conv(x)
    

    