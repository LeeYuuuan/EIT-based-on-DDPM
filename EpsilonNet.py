import torch
import torch.nn as nn
from unet_parts import *
class U_net(nn.Module):
    
    def __init__(self, n_channels, n_classes, bilinear=False):
        
        super(U_net, self).__init__()
        
        self.Maxpooling = nn.MaxPool2d(2) # kernel_size = 2, Default stride = kernel_size = 2.
        
        
        self.Conv1 = Conv_part(in_channels=n_channels, out_channels=64)
        self.Conv2 = Conv_part(in_channels=64, out_channels=128)
        self.Conv3 = Conv_part(in_channels=128, out_channels=256)
        self.Conv4 = Conv_part(in_channels=256, out_channels=512)
        self.Conv5 = Conv_part(in_channels=512, out_channels=1024)
        
        
        
        
    
    def forward(self, x):
        
        # encoding path (contracting path)
        x1 = self.Conv1(x) # 64
        
        x2 = self.Maxpooling(x1)
        x2 = self.Conv2(x2) # 128
        
        x3 = self.Maxpooling(x2)
        x3 = self.Conv3(x3) # 256
        
        x4 = self.Maxpooling(x3)
        x4 = self.Conv4(x4) # 512
        
        x5 = self.Maxpooling(x4)
        x5 = self.Conv5(x5) # 1024
        
        # decoding path(expansive path)
        x5
        
        

        
        

class MLPDiffusion(nn.Module):
    
    def __init__(self, cond_num, n_steps, num_units=128):
        super(MLPDiffusion, self).__init__()
        
        self.linears = nn.ModuleList(
            [
                nn.Linear(cond_num, num_units),
                nn.ReLU(),
                nn.Linear(num_units, num_units),
                nn.ReLU(),
                nn.Linear(num_units, num_units),
                nn.ReLU(),
                nn.Linear(num_units, cond_num),
            ]
        )
        self.step_embeddings = nn.ModuleList(
            [
                nn.Embedding(n_steps, num_units),
                nn.Embedding(n_steps, num_units),
                nn.Embedding(n_steps, num_units),
            ]
        )
        
    def  forward(self, x_0, t):
        x = x_0
        for idx, embedding_layer in enumerate(self.step_embeddings):
            t_embedding = embedding_layer(t)
            x = self.linears[2*idx](x)
            x += t_embedding
            x = self.linears[2*idx+1](x)
        x = self.linears[-1](x)
        return x
    
    def loss_fn(model, x_0, alphas_bar_sqrt, one_minus_alphas_bar_sqrt, n_steps):
        """calculate loss in given t"""
        batch_size = x_0.shape[0]
        
        # sample t for every data in one batch
        t = torch.randint(0, n_steps, size=(batch_size//2))
        t = torch.cat([t, n_steps-1-t], dim=0)
        t = t.unsqueeze(-1)
        
        # coefficient of x0
        a = alphas_bar_sqrt[t]
        
        # coefficient of epsilon
        aml = one_minus_alphas_bar_sqrt[t]
        
        # random noise
        e = torch.randn_like(x_0)
        
        x = a * x_0 + e * aml
        
        output = model(x, t.squeeze(-1))
        
        return (e - output).square().mean()