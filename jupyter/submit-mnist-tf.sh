#!/bin/bash
#SBATCH -p gpuq-short

#REQUIREMENTS
#conda create -n tf-keras
#conda activate tf-keras
#conda install -c nvidia -c conda-forge -c defaults matplotlib keras tensorflow-gpu 
#conda install -c nvidia -c conda-forge -c defaults nvidia::cuda-toolkit nvidia::cuda-nvcc

#or

#pip install ipykernel keras "jax[cuda12]" tensorflow matplotlib # assuming you are running against cuda 12 drivers (A100. H100)
#use jax[13] if B100+

module load miniconda3
conda activate tf-keras
#if nvcc is installed onlyin conda environments
export XLA_FLAGS="--xla_gpu_cuda_data_dir=$CONDA_PREFIX"
./mnist-jax.py
