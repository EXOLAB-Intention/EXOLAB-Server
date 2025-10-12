# EXOLAB Server — User Guide

This document explains how to access and use the shared GPU server managed by **Slurm** and **Miniconda**.  
Please read carefully before submitting any jobs.

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

## Access via VSCode (SSH Remote)

1. Install **VSCode** and the extension **"Remote - SSH"**.
2. Add the server to your SSH config file:
   
   (Linux)
   ```bash
   code ~/.ssh/config
   ```
   (Windows)
   ```bash
   C:\Users\%USERNAME%\.ssh
   ```
   Example entry:
   ```bash
   Host slurm-server
       HostName <SERVER_IP_OR_HOSTNAME>
       User <your_username>
       Port 22
   ```
4. In VSCode, open the command palette →  
   `Remote-SSH: Connect to Host... → slurm-server`

5. Once connected, VSCode will open a remote workspace on the server.

---

## Account Creation

Accounts are managed by the administrator using a helper script:

```bash
sudo adduser-slurm <username>
```

After the account is created:
```bash
su - <username>
```

Each user can log in via SSH with the assigned password.  
Please change your password after the first login:
```bash
passwd
```

---

## Conda Environment Setup (Per User)

Each user manages their own Conda environments independently.

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
   conda create -n myenv python=3.11
   conda activate myenv
   ```
4. Install necessary packages (e.g., PyTorch):
   ```bash
   conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
   ```

> The global installation path is `/opt/miniconda3`,  
> but each user’s environment lives under `~/.conda/envs/`.

---

## Submitting Jobs with Slurm

Use Slurm to schedule your GPU/CPU jobs instead of running Python scripts directly.  
A sample job script is provided: **`train.sh`**

### Run the job
```bash
sbatch train.sh
```

### Check job status
```bash
squeue -u $USER
```

### Cancel a job
```bash
scancel <job_id>
```

### View logs
```bash
cat logs/<job_name>_<job_id>.out
```

---

## About `train.sh`

The included `train.sh` is a **single-GPU Slurm job template**.  
It automatically activates your Conda environment and runs `train.py`.

Example snippet:
```bash
#SBATCH --gres=gpu:1      # Request 1 GPU
#SBATCH --cpus-per-task=8 # Use up to 8 CPU cores
#SBATCH --mem=32G         # Allocate 32 GB of memory
```

If you need multiple GPUs, update these lines:
```bash
#SBATCH --gres=gpu:4
```
and run your code using **PyTorch DistributedDataParallel (DDP)**:
```bash
torchrun --standalone --nproc_per_node=4 train.py
```

> Without DDP, requesting multiple GPUs does **not** automatically make your code multi-GPU aware.

---

## Slurm Quick Reference

| Command | Description |
|----------|-------------|
| `sbatch script.sh` | Submit a job |
| `squeue -u $USER` | Check running/pending jobs |
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

_Last updated: Oct 2025_
