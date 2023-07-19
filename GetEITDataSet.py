from torch.utils.data import Dataset, DataLoader
import torch
class EITDataset(Dataset):
    
    def __init__(self, cond_dir, vol_dir):
        self.conductivity = None
        self.voltage = None
        
        raise NotImplementedError
    
    def __len__(self):
        return len(self.conductivity)
    
    def __getitem__(self, index):
        
        raise NotImplementedError    

training_cond_dir = ''
training_vol_dir = ''
test_cond_dir = ''
test_vol_dir = ''
training_data = EITDataset(training_cond_dir, training_vol_dir)    
test_data = EITDataset(test_cond_dir, test_vol_dir)
train_dataloader = DataLoader(training_data, batch_size=64, shuffle=True)
test_dataloader = DataLoader(test_data, batch_size=64, shuffle=True)