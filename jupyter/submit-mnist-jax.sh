#!/bin/bash
#SBATCH -p gpuq-short
#REQUIREMENTS
## Conda environment created like:
#module load miniconda3
#conda activate jax-keras
#conda install -c nvidia -c conda-forge -c defaults python=3.13 matplotlib keras 
#pip install "jax[cuda13]"

#May be required if no system cuda nvcc libs exist
export XLA_FLAGS="--xla_gpu_cuda_data_dir=$CONDA_PREFIX"

module load miniconda3
conda activate jax-keras
./mnist-jax.py
