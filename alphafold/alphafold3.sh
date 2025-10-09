#!/bin/bash
#SBATCH --job-name="alpha_monomer_cpu"  # job name
#SBATCH --time=48:00:00                 # max job run time hh:mm:ss
#SBATCH --nodes=1                       # number of nodes
#SBATCH --cpus-per-task=12              # cores per compute node
#SBATCH --mem-per-cpu=3400M             # memory per cpu
#SBATCH --output=%x-%j.log              # job log
#SBATCH --gres=gpu:1
#SBATCH -p gpuq
module load apptainer
module load cuda12.8/blas/12.8.0     cuda12.8/fft/12.8.0 cuda12.8/toolkit/12.8.0

# I think this one doesnt work as it is missing entries for ccd or maybe smiles
#export FASTAFILE=rcsb_pdb_7UNJ
# I found this one, which "works"
export FASTAFILE=corrected
export FASTAFILE=rcsb_pdb_2PV7
DATABASE_DIR=/projects/protein_design/alphafold/alphafoldv3/alphafolddb
INPUT_DIR=$HOME/alphafold/alphafold_Files/
OUTPUT_DIR=$HOME/afoutputs
MODEL_DIR=/projects/protein_design/alphafold/alphafoldv3/parameters/

mkdir -p $OUTPUT_DIR

export APPTAINER_CACHEDIR=/projects/$USER/containers/apptainer
export APPTAINER_BIND="$INPUT_DIR,$OUTPUT_DIR,$DATABASE_DIR"

set -x

run_docker()
{
docker run -it \
    --volume $INPUT_DIR:/root/af_input \
    --volume $OUTPUT_DIR:/root/af_output \
    --volume $MODEL_DIR:/root/models \
    --volume $DATABASE_DIR:/root/public_databases \
    --gpus all \
    alphafold3 \
    python run_alphafoldv3.py \
    --json_path="$INPUT_DIR/${FASTAFILE}.json" \
    --model_dir=/root/models \
    --db_dir=/root/public_databases \
    --db_dir=/root/public_databases_fallback \
    --output_dir=/root/af_output
}

run_container()
{
  EXT=$1
  PRE=$2
  PRG=$3
  BIND=$4
  OPTS="--nv -f --writable-tmpfs"

echo   $PRG run $OPTS \
    $BIND $INPUT_DIR:/root/af_input \
    $BIND $OUTPUT_DIR:/root/af_output \
    $BIND $MODEL_DIR:/root/models \
    $BIND $DATABASE_DIR:/root/public_databases \
    ${PRE}alphafold3${EXT} \
    python run_alphafold.py \
    --json_path="$INPUT_DIR/${FASTAFILE}.json" \
    --model_dir=/root/models \
    --db_dir=/root/public_databases \
    --db_dir=/root/public_databases_fallback \
    --output_dir=/root/af_output

  $PRG run $OPTS \
    $BIND $INPUT_DIR:/root/af_input \
    $BIND $OUTPUT_DIR:/root/af_output \
    $BIND $MODEL_DIR:/root/models \
    $BIND $DATABASE_DIR:/root/public_databases \
    ${PRE}alphafold3${EXT} \
    python run_alphafold.py \
    --json_path="$INPUT_DIR/${FASTAFILE}.json" \
    --model_dir=/root/models \
    --db_dir=/root/public_databases \
    --db_dir=/root/public_databases_fallback \
    --output_dir=/root/af_output

}

run_apptainer(){
EXT=".sif"
PRE="/projects/protein_design/alphafold/alphafoldv3/containers/"
PRG=apptainer
BIND="--bind"
run_container "$EXT" "$PRE"  "$PRG" "$BIND"
}

run_apptainer
