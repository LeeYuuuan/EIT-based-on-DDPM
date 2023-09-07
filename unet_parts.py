""" Parts of the U-Net Model"""

import torch
import torch.nn as nn
import torch.nn.functional as F

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
    

    