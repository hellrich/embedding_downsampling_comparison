#todo: struktur der ordner passt nicht, evtl. threads hardcoden? glaube paper sagt war default?

RESULTS="/home/hellrich/embedding_downsampling_comparison/results"

mkdir -p "$RESULTS"

for method in pmi glove sgns
do
	sbatch -o $RESULTS/results-wiki-$method --mem 60G -c 24 --job-name eval_$method evaluate-wiki.sh $method
done