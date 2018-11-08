#wikipedia was trained using slurm, older with locally run scripts

CORPUS=wiki
MIN=750
WORKING_DIR="/home/hellrich/embedding_downsampling_comparison"
LOG_DIR="$WORKING_DIR/training_slurmout/wiki"
mkdir -p $LOG_DIR

function train_sgns {
	local MEM="20G"
	for what in w2v w2vb
	do
		for i in {0..9}
		do
			local name=${what}_$i
			sbatch --mem $MEM --job-name $name --output $LOG_DIR/$name train-slurm.sh $what $i $CORPUS $MIN
		done
	done
}

function train_glove {
	local MEM="40G"
	for what in glove gloveb
	do
		for i in {0..9}
		do
			local name=${what}_$i
			sbatch --mem $MEM --job-name $name --output $LOG_DIR/$name train-slurm.sh $what $i $CORPUS $MIN
		done
	done
}

function train_pmi {
	local MEM="80G"
	for what in ppmi ppmib 
	do
		for i in {0..9}
		do
			for sampling in none weight prob
			do
				local name=${what}_${sampling}_$i
				sbatch --mem $MEM --job-name $name --output $LOG_DIR/$name train-slurm.sh $what $i $CORPUS $MIN $sampling
			done
		done
	done
}

train_glove
train_sgns
train_pmi





