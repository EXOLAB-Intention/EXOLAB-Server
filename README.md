# EXOLAB Server — User Guide

This document explains how to access and use the shared GPU server managed by **Slurm**.

**Please read carefully** before submitting any jobs.

---

## Server Overview

| Item | Specification |
|------|----------------|
| **OS** | Ubuntu 22.04 LTS (jammy) |
| **Scheduler** | Slurm 23.02.7 |
| **CGroup** | v2 unified mode |
| **Node** | `server1` |
| **CPUs** | 64 cores |
| **Memory** | 62 GB usable |
| **GPUs** | 4 × NVIDIA RTX A5000 |
| **Python Environment** | System-wide Miniconda (`/opt/miniconda3`) |

> Resource limits per node:  
> `--cpus-per-task ≤ 64`, `--mem ≤ 62G`, `--gres=gpu: ≤ 4`

---

## 🆕 Web GUI: EXOLAB Server Monitor

You can monitor the server status, GPU usage, and your Slurm jobs in real-time via the web dashboard.

- **URL**: [http://143.248.65.114:5050](http://143.248.65.114:5050)
- **Features**:
    - **Dashboard**: System load, RAM, and GPU utilization.
    - **Storage Management**: Check your disk usage in `/home`.
    - **Job Monitoring**: View running/pending jobs and even preview your job scripts.

---

## Access via VSCode (SSH Remote)

1. Make sure your PC is connected to **KAIST's network** (WiFi / Ethernet).
2. Install the extension **"Remote - SSH"** in VSCode.
3. Type ">ssh" in the command palette (located at the top of the window as "Search"), and click "Add New SSH Host...".
4. Type:
```bash
ssh user@143.248.65.114
```
5. Select the config as below to create/modify your SSH configuration file:
   
(Linux)
```bash
code ~/.ssh/config
```
(Windows)
```bash
C:\Users\%USERNAME%\.ssh
```
Open that file and modify it as:
```bash
Host server1-admin
    HostName 143.248.65.114
    User user
    Port 22
```

6. In VSCode, open the command palette →  
   `Remote-SSH: Connect to Host... → server1-admin`
   `(You need to type password, which is announced.)`

7. Select "Linux".
8. Once connected, VSCode will open a remote workspace on the server.

---

## Account Creation

Accounts are managed by the administrator using a helper script:

```bash
adduser-slurm <YOUR ACCOUNT ID> # (ex: "adduser-slurm tykim")
```
First, you should type sudo password (which is announced), then you may see the line that sets your password.

(!) **Please remember your password carefully.**

After that, type:
```bash
exit
```
and modify the config file set before by changing the 1) host name and 2) user name:
```bash
Host <YOUR SERVER NAME> # (ex: server1-tykim)
    HostName 143.248.65.114
    User <YOUR ACCOUNT ID>
    Port 22
```
Each user can log in via SSH with the assigned password.

---

## File and folder (Per User)

After you create your account, while working with VSCode, you should create your own folder.

Since the base repository is already created as:
```bash
/home/<YOUR ACCOUNT ID>
```
You can create files and folders within it.

Please do not modify or delete the system files and folders.

It is safe to create some folders first and do the rest of your work inside those folders.

---

## Conda Environment Setup (Per User)

After logging in, each user manages their own Conda environments independently.

1. Verify that Conda is available:
```bash
conda --version
```

2. Initialize Conda for your shell (only once):
```bash
conda init bash
```
   
3. Create your own environment:
```bash
conda create -n myenv python=3.11  # example, change with your preference
conda activate myenv
```
   
4. Install your frameworks such as PyTorch or TensorFlow:

For PyTorch (recommended):
```bash
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
```
   
For TensorFlow:
```bash
conda install -c conda-forge tensorflow
```
      
**Important notes:**

- The GPU driver (for CUDA) is already installed globally on the server.
- You can still install CUDA runtime packages (like pytorch-cuda=12.x or cudatoolkit)
  inside your Conda environment — this does not conflict with the system driver.
- Just ensure the runtime version ≤ 12.2 (driver-supported maximum).

## Exporting and Importing Conda Environments (YAML)

If you already have a working Conda environment on your local PC,  
you can export it as a YAML file and recreate it on the EXOLAB server.

### 1. Export your local Conda environment

Activate your environment first, then export it:
```bash
conda activate <YOUR CONDA ENVIRONMENT>
conda env export > myenv.yml
```

This command will create a file named "myenv.yml" in your current directory.

### 2. Clean up unnecessary CUDA-related packages

Before using this YAML file on the server, you should remove any lines containing the cuda-related packages.
```bash
grep -vE 'cuda|cudnn|nccl' myenv.yml > myenv_clean.yml
```

(These low-level CUDA libraries are often platform-specific and may cause version conflicts.)

### 3. Copy the YAML file to the server

You can use scp or VSCode file upload to transfer the file:
```bash
scp myenv_clean.yml user@143.248.65.114:/home/<YOUR ACCOUNT ID>/
```

### 4. Recreate the environment on the server

Log in to the server and create a new Conda environment:
```bash
conda env create -n myenv -f myenv_clean.yml
```

Then activate it:
```bash
conda activate myenv
```

### 5. Reinstall your deep learning frameworks

Install your preferred framework inside the new environment:

PyTorch (recommended)
```bash
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
```

For TensorFlow
```bash
conda install -c conda-forge tensorflow
```

### 6. Verify GPU access

To check if CUDA works properly, run:
    python -c "import torch; print(torch.cuda.is_available())"
or:
    python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"

If the output is "True" or shows your GPU (e.g., NVIDIA RTX A5000),  
your setup is complete and ready to use.

The global installation path is /opt/miniconda3,
but each user’s environment lives under ~/.conda/envs/.

---

## Submitting Jobs with Slurm

Use Slurm to schedule your GPU/CPU jobs instead of running Python scripts directly.  
A sample job script is provided: **`train.sh`**

The included `train.sh` is a **single-GPU Slurm job template**.  
It automatically activates your Conda environment and runs `train.py`.

To submit and que your job, type:
```bash
sbatch train.sh
```

You can also change the number of each resource in this template.
```bash
#SBATCH --gres=gpu:1      # Request 1 GPU
#SBATCH --cpus-per-task=8 # Use up to 8 CPU cores
#SBATCH --mem=32G         # Allocate 32 GB of memory
```

### 🆕 Specific GPU Allocation
If you want to use a specific GPU index (e.g., for consistency in debugging), you can specify it using the `idx` type:
```bash
#SBATCH --gres=gpu:1          # Request any 1 GPU
#SBATCH --gres=gpu:idx0:1     # Request GPU #0 specifically
#SBATCH --gres=gpu:idx1:1     # Request GPU #1 specifically
#SBATCH --gres=gpu:idx2:1     # Request GPU #2 specifically
#SBATCH --gres=gpu:idx3:1     # Request GPU #3 specifically
```
*(Note: Availability depends on other users' jobs. If the specific GPU is already in use by another job, your job will stay in 'PENDING' state.)*

For example, if you need multiple GPUs for using **PyTorch DistributedDataParallel (DDP)**, update these lines:
```bash
#SBATCH --gres=gpu:4                    # Request any 4 GPUs
#SBATCH --gres=gpu:idx0:1,gpu:idx1:1    # Request GPU #0,1 specifically
```
and run your code as an example below:
```bash
torchrun --standalone --nproc_per_node=4 train.py
```

---

## Slurm Quick Reference

| Command | Description |
|----------|-------------|
| `sbatch script.sh` | Submit a job |
| `squeue` | Check running/pending jobs |
| `scontrol show job <job_id>` | Detailed job info |
| `scancel <job_id>` | Cancel a job |
| `sinfo` | Check node/partition status |

---

## Notes & Best Practices

- Avoid running heavy jobs directly in the SSH terminal. Always use `sbatch`.
- Release GPUs quickly after experiments.
- Keep your Conda environments tidy (remove unused ones).
- Save output logs under a dedicated `logs/` directory.

---

_Last updated: Feb 2026_
