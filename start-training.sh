#todo: struktur der ordner passt nicht, evtl. threads hardcoden? glaube paper sagt war default?

WORKING_DIR=/home/hellrich/tmp/sgns_implementation_comparison

threads=$1

mkdir -p $WORKING_DIR/training_slurmout/${threads}_threads
for what in hyper1 hyper2 word2vec gensim1 gensim2 gensim3
do 
        for id in {0..9}
        do
                sbatch -o $WORKING_DIR/training_slurmout/${threads}_threads/${what}_$id train-slurm.sh $what $id $threads
        done
done
