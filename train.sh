#!/bin/bash
# ==============================================================
# SLURM JOB SCRIPT TEMPLATE  (single GPU example)
# --------------------------------------------------------------
# [Server Information]
#   NodeName    : server1
#   Total CPUs  : 64 cores
#   Total Memory: 62000 MB  (~62 GB usable)
#   Total GPUs  : 4 × NVIDIA RTX A5000
# --------------------------------------------------------------
# [Resource limits reminder]
#   - You must request resources within the server limits:
#       --cpus-per-task <= 64
#       --mem <= 62000M (or 62G)
#       --gres=gpu: <= 4
#   - Exceeding these values will cause "Requested node configuration is not available" error.
# ==============================================================


#SBATCH -J single_gpu_train               # Job name (for display in squeue / logs)
#SBATCH -N 1                              # Number of nodes (always 1 in this server)
#SBATCH -n 1                              # Number of tasks (processes)
#SBATCH --gres=gpu:1                      # GPU allocation / --gres=gpu:idx{gpu number}:1 for specific GPU usage
#SBATCH --cpus-per-task=8                 # CPU allocation: choose ≤ 64
#SBATCH --mem=32G                         # Memory allocation: choose ≤ 62000 MB (~62G)
#SBATCH -t 12:00:00                       # Max runtime (HH:MM:SS)
#SBATCH -o logs/%x_%j.out                 # Log files   (%x = job name, %j = job ID)
#SBATCH -e logs/%x_%j.err                 # Error files (%x = job name, %j = job ID)


# ================= ENVIRONMENT SETUP =================
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate myenv                      # !!! Change with your ACTUAL conda environment name !!!

echo "Job started on $(hostname) at $(date)"
echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
nvidia-smi -L

export PYTHONUNBUFFERED=1                 # To see the output in .out file directly

# ================= RUN YOUR SCRIPT =================
python train.py
# torchrun --standalone --nproc_per_node=4 train.py # For multi-GPU use


# ================== SLURM COMMAND ==================
# sbatch train.sh                           # Submit this script
# scancel <job_id>                          # Cancel job with job ID
# squeue                                    # Check all job status
