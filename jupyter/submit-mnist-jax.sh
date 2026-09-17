#!/bin/bash
#SBATCH -p gpuq-short
#REQUIREMENTS
## Conda environment created like:
#module load miniconda3
#conda activate jax-keras
#conda install -c defaults krb5 libpq 
#conda install -c conda-forge pip
#conda install -c nvidia -c conda-forge -c defaults python=3.13 matplotlib keras 
#pip install "jax[cuda13]"

#May be required if no system cuda nvcc libs exist
export XLA_FLAGS="--xla_gpu_cuda_data_dir=$CONDA_PREFIX"

export KERAS_BACKEND=jax
##Set this if you need to share the MIG slice (eg for slighyl less than 1/3 of the memory)
#os.environ["XLA_PYTHON_CLIENT_MEM_FRACTION"] = "0.3"
#XLA_PYTHON_CLIENT_MEM_FRACTION="0.3"
module load miniconda3
conda activate jax-keras
./mnist-jax.py
