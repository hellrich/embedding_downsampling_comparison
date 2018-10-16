#todo: struktur der ordner passt nicht, evtl. threads hardcoden? glaube paper sagt war default?

WORKING_DIR=/home/hellrich/embedding_downsampling_comparison
corpus=$1
min=$2

mkdir -p $WORKING_DIR/training_slurmout/
for what in glove gloveb ppmi ppmib w2v w2vb
do 
        for id in {0..9}
        do
                sbatch -o $WORKING_DIR/training_slurmout/${what}_$id train-slurm.sh $what $id $corpus $min
        done
done
