DIR="/data/data_hellrich/tmp/emnlp2018/"
HYPERWORD_PATH="/home/hellrich/hyperwords/omerlevy-hyperwords-688addd64ca2"
WINDOW="5"
DIM="500"

function do_sgns {
        local source_path=$1
        local target_path=$2
        local deterministic_subsample=$3
        local weighted_window=$4
        
	mkdir -p $target_path

        /home/hellrich/emnlp2018/bootstrap.sh $source_path $target_path/bootstrapped_corpus
        word2vecw/word2vec -train $target_path/bootstrapped_corpus -output $target_path/sgns.words -size $DIM -window $WINDOW -sample 1e-4 -negative 5 -hs 0 -binary 0 -cbow 0 -min-count $MIN -ds $deterministic_subsample -ww $weighted_window
        python $HYPERWORD_PATH/hyperwords/text2numpy.py $target_path/sgns.words
        rm $target_path/bootstrapped_corpus
        echo "finished $target_path sgns"
}


#####################
source ~/.bashrc && source activate jeseme

corpus=$1
start=$2
end=$3
MIN=$4

for i in $(seq $start $end)
do
        #probabilistic window
        do_sgns $DIR/$corpus $DIR/sgns/$corpus/ps_dw_b$i 0 0 #classic sgns
        do_sgns $DIR/$corpus $DIR/sgns/$corpus/ws_dw_b$i 1 0
        do_sgns $DIR/$corpus $DIR/sgns/$corpus/ns_dw_b$i 2 0
       
        #weighted window
        do_sgns $DIR/$corpus $DIR/sgns/$corpus/ps_ww_b$i 0 1
        do_sgns $DIR/$corpus $DIR/sgns/$corpus/ws_ww_b$i 1 1
        do_sgns $DIR/$corpus $DIR/sgns/$corpus/ns_ww_b$i 2 1
        
        #uniform window
        do_sgns $DIR/$corpus $DIR/sgns/$corpus/ps_uw_b$i 0 2
        do_sgns $DIR/$corpus $DIR/sgns/$corpus/ws_uw_b$i 1 2
        do_sgns $DIR/$corpus $DIR/sgns/$corpus/ns_uw_b$i 2 2      
done

