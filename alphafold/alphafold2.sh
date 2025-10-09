#!/bin/bash
#SBATCH --job-name="alpha_monomer_cpu"  # job name
#SBATCH --time=48:00:00                 # max job run time hh:mm:ss
#SBATCH --nodes=1                       # number of nodes
#SBATCH --cpus-per-task=8               # tasks per compute node
#SBATCH --output=%x-%j.log              # job log
#SBATCH --gres=gpu:1
#SBATCH -p gpuq

### Change these #######
FASTAFILE=rcsb_pdb_7UNJ
OUTPUTDIR="/projects/scratch/tmp_${USER}/APOUT"
FASTADIR="$HOME/alphafold/alphafold_Files/"
##########################################
export AP2TMP=/projects/scratch/tmp_${USER}/APTMP

for d in "$OUTPUTDIR" "$AP2TMP"
do
	mkdir -p $d
done

#Set up runtime
module load apptainer
module load cuda12.8/blas/12.8.0     cuda12.8/fft/12.8.0 cuda12.8/toolkit/12.8.0
source /projects/apps/modules/miniconda/helpers/setup-miniconda-20250924
conda activate alpharun


# Check if we are gpu enabled
if [ -z ${CUDA_VISIBLE_DEVICES+x} ];
then
	echo "warning not gpu enabled"
       	extraopts="--use_gpu=False"
else
       	extraopts="--use_gpu=True"
fi

#Use precomputed msas if available
# Otherwise, we alphafold will spend about 30 mins (or more, is this per protein?)
# Running jackhmmr on the cpus
if [ -d "$OUTPUTDIR/${FASTA}" ];
then
	echo "Warning using precomputed mmsas from $OUTPUTDIR/${FASTAFILE}"
	echo "If your previous job on this fa file worked, this should only"
	echo "speed things up and not be a problem"
	echo "in case of issues, clean up $OUTPUTDIR/${FASTAFILE}"
       	extraopts="$extraopts --use_precomputed_msas"
else
       	extraopts="--use_gpu=True"
fi


python3  \
  $HOME/alphafold/run_singularity_alphafoldv2.py \
  --benchmark=true \
  --fasta_paths="$FASTADIR/${FASTAFILE}.fa"  \
  --max_template_date=2020-05-14 \
  --model_preset=monomer \
  --db_preset=reduced_dbs \
  $extraopts \
  --data_dir=/projects/protein_design/alphafold/alphafoldv2/alphafolddb \
  --output_dir="${OUTPUTDIR}" \
  --models_to_relax=all

