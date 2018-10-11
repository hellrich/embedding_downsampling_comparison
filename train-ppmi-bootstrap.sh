DIR="/data/data_hellrich/tmp/emnlp2018/"
HYPERWORD_PATH="/home/hellrich/hyperwords/omerlevy-hyperwords-688addd64ca2"
WINDOW="5"
SMOOTHING="0.75"
DIM="500"


function copy {
        #wieso nicht immer von base?
        local target_path=$1
        local from_name=$2
        local to_name=$3

        cp $target_path/${from_name}.words.vocab $target_path/${to_name}.words.vocab
        cp $target_path/${from_name}.contexts.vocab $target_path/${to_name}.contexts.vocab
}

function do_pmi {
        local source_path=$1
        local target_path=$2 
        local window_type=$3
        local sub1=$4
        local sub2=$5

        prepare $source_path $target_path $window_type $sub1 $sub2
        #PMI
        python $HYPERWORD_PATH/hyperwords/counts2pmi.py --cds $SMOOTHING $target_path/counts $target_path/pmi
        #PMI SVD
        python $HYPERWORD_PATH/hyperwords/pmi2svd.py --dim $DIM $target_path/pmi $target_path/svd_pmi
        copy $target_path pmi svd_pmi
        
        rm $target_path/counts $target_path/pmi.npz
        echo "finished $target_path pmi"
}

function prepare {
        local source_path=$1
        local target_path=$2
        local window_type=$3
        local sub1=$4
        local sub2=$5

        mkdir -p $target_path

        /home/hellrich/emnlp2018/bootstrap.sh $source_path $target_path/bootstrapped_corpus

        python $HYPERWORD_PATH/hyperwords/corpus2counts.py $target_path/bootstrapped_corpus --win $WINDOW --thr $MIN $window_type $sub1 $sub2 > $target_path/counts
        python $HYPERWORD_PATH/hyperwords/counts2vocab.py $target_path/counts
        rm $target_path/bootstrapped_corpus
}


#####################
source ~/.bashrc && source activate jeseme

corpus=$1
start=$2
end=$3
MIN=$4
for i in $(seq $start $end)
do
        do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ns_uw_b$i
        do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ns_dw_b$i "--dw"
        do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ns_ww_b$i "--ww"
        do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ws_uw_b$i " " "--dsub" "1e-4"
        do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ws_dw_b$i "--dw" "--dsub" "1e-4"
        do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ws_ww_b$i "--ww" "--dsub" "1e-4"
        do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ps_uw_b$i " " "--psub" "1e-4"
        do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ps_dw_b$i "--dw" "--psub" "1e-4"
        do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ps_ww_b$i "--ww" "--psub" "1e-4"
done
