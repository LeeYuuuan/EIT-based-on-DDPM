import torch
import torch.nn as nn

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