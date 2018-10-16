#wikipedia was trained using slurm, older with locally run scripts

CORPUS=wiki
MIN=100
WORKING_DIR=/home/hellrich/embedding_downsampling_comparison

mkdir -p $WORKING_DIR/training_slurmout/

for what in glove gloveb ppmi ppmib w2v w2vb
do
	for i in 0 # {0..9}
	do
		sbatch -o $WORKING_DIR/training_slurmout/${what}_$i train-slurm.sh $what $i $CORPUS $MIN
	done
done



