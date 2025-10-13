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
   conda create -n myenv python=3.11 # example, change with your preference (name, version, ...)
   conda activate myenv
   ```
4. Install necessary packages (e.g., PyTorch):
   ```bash
   conda install pytorch torchvision torchaudio -c pytorch -c nvidia
   ```
(!) **Please note that CUDA toolkit is already installed.**

> The global installation path is `/opt/miniconda3`,  
> but each user’s environment lives under `~/.conda/envs/`.

---

## Submitting Jobs with Slurm

Use Slurm to schedule your GPU/CPU jobs instead of running Python scripts directly.  
A sample job script is provided: **`train.sh`**

---

## About `train.sh`

The included `train.sh` is a **single-GPU Slurm job template**.  
It automatically activates your Conda environment and runs `train.py`.

You can change the number of each resource in this template.
```bash
#SBATCH --gres=gpu:1      # Request 1 GPU
#SBATCH --cpus-per-task=8 # Use up to 8 CPU cores
#SBATCH --mem=32G         # Allocate 32 GB of memory
```

For example, if you need multiple GPUs for using **PyTorch DistributedDataParallel (DDP)**, update these lines:
```bash
#SBATCH --gres=gpu:4
```
and run your code as an example below:
```bash
torchrun --standalone --nproc_per_node=4 train.py
```

> Without DDP, requesting multiple GPUs does **not** automatically make your code multi-GPU aware.

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

_Last updated: Oct 2025_
