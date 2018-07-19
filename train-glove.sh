HYPERWORD_PATH="/home/hellrich/hyperwords/omerlevy-hyperwords-688addd64ca2"
WINDOW="5"
DIM="500"
GLOVE_PATH="/home/hellrich/emnlp2018/GloVe/build"
MEMORY=10.0
NUM_THREADS=10

function do_glove_boot {
        local source_path=$1
        local target_path=$2

        mkdir -p $target_path

        /home/hellrich/emnlp2018/bootstrap.sh $source_path $target_path/bootstrapped_corpus

        $GLOVE_PATH/vocab_count -min-count $MIN < $target_path/bootstrapped_corpus > $target_path/vocab

        $GLOVE_PATH/cooccur -memory $MEMORY -vocab-file $target_path/vocab -window-size $WINDOW < $target_path/bootstrapped_corpus > $target_path/cooc

        $GLOVE_PATH/shuffle -memory $MEMORY < $target_path/cooc > $target_path/cooc_shuf

        $GLOVE_PATH/glove -save-file $target_path/vectors -threads $NUM_THREADS -input-file $target_path/cooc_shuf -vector-size $DIM -binary 2 -vocab-file $target_path/vocab 

        python $HYPERWORD_PATH/hyperwords/text2numpy.py $target_path/vectors.txt

        rm $target_path/bootstrapped_corpus
        rm $target_path/cooc
        rm $target_path/cooc_shuf
        echo "finished $target_path glove boot"
}

function do_glove {
        local source_path=$1
        local target_path=$2

        mkdir -p $target_path

        $GLOVE_PATH/vocab_count -min-count $MIN < $source_path > $target_path/vocab

        $GLOVE_PATH/cooccur -memory $MEMORY -vocab-file $target_path/vocab -window-size $WINDOW < $source_path > $target_path/cooc

        $GLOVE_PATH/shuffle -memory $MEMORY < $target_path/cooc > $target_path/cooc_shuf

        $GLOVE_PATH/glove -save-file $target_path/vectors -threads $NUM_THREADS -input-file $target_path/cooc_shuf -vector-size $DIM -binary 2 -vocab-file $target_path/vocab 

        python $HYPERWORD_PATH/hyperwords/text2numpy.py $target_path/vectors.txt

        rm $target_path/cooc
        rm $target_path/cooc_shuf
        echo "finished $target_path glove"
}



#####################
source ~/.bashrc && source activate jeseme

corpus=$1
start=$2
end=$3
MIN=$4

for i in $(seq $start $end)
do
        do_glove /home/hellrich/tmp/emnlp2018/$corpus /home/hellrich/tmp/emnlp2018/glove/$corpus/v$i 
        do_glove_boot /home/hellrich/tmp/emnlp2018/$corpus /home/hellrich/tmp/emnlp2018/glove/$corpus/b$i 
done
