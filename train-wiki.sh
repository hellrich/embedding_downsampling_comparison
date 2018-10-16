#wikipedia was trained using slurm, older with locally run scripts

CORPUS=wiki
MIN=100
for what in glove gloveb ppmi ppmib w2v w2vb
do
	for i in 0 # {0..9}
	do
		./train-slurm.sh $what $i $CORPUS $MIN
	done
done
