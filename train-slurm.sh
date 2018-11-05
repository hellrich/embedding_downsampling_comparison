#!/bin/bash
#SBATCH --cpus-per-task 10


DIR="/data/data_hellrich/tmp/emnlp2018/"
HYPERWORD_PATH="/home/hellrich/hyperwords/omerlevy-hyperwords-688addd64ca2"
TOOL_PATH="/home/hellrich/embedding_downsampling_comparison"
GLOVE_PATH="$TOOL_PATH/GloVe/build"

WINDOW="5"
DIM="500"
MEMORY=25.0
NUM_THREADS=10
SMOOTHING="0.75"

########################################### SGNS

function do_sgns_boot {
        local source_path=$1
        local target_path=$2
        local deterministic_subsample=$3
        local weighted_window=$4
        
        mkdir -p $target_path

        $TOOL_PATH/bootstrap.sh $source_path $target_path/bootstrapped_corpus
        $TOOL_PATH/word2vecw/word2vec -train $target_path/bootstrapped_corpus -output $target_path/sgns.words -size $DIM -window $WINDOW -sample 1e-4 -negative 5 -hs 0 -binary 0 -cbow 0 -min-count $MIN -ds $deterministic_subsample -ww $weighted_window
        python $HYPERWORD_PATH/hyperwords/text2numpy.py $target_path/sgns.words
        rm $target_path/bootstrapped_corpus
        echo "finished $target_path sgns"
}

function do_sgns {
        local source_path=$1
        local target_path=$2
        local deterministic_subsample=$3
        local weighted_window=$4
        
        mkdir -p $target_path
        #SGNS
        $TOOL_PATH/word2vecw/word2vec -train $source_path -output $target_path/sgns.words -size $DIM -window $WINDOW -sample 1e-4 -negative 5 -hs 0 -binary 0 -cbow 0 -min-count $MIN -ds $deterministic_subsample -ww $weighted_window
        python $HYPERWORD_PATH/hyperwords/text2numpy.py $target_path/sgns.words

        echo "finished $target_path sgns"
}


########################################### SVD
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
        echo "finished prepare"
        #PMI
        python $HYPERWORD_PATH/hyperwords/counts2pmi.py --cds $SMOOTHING $target_path/counts $target_path/pmi
        echo "finished ppmi"
        #PMI SVD
        python $HYPERWORD_PATH/hyperwords/pmi2svd.py --dim $DIM $target_path/pmi $target_path/svd_pmi
        
        copy $target_path pmi svd_pmi
        rm $target_path/counts $target_path/pmi.npz
        echo "finished $target_path pmi"
}

function do_pmi_boot {
        local source_path=$1
        local target_path=$2 
        local window_type=$3
        local sub1=$4
        local sub2=$5

        prepare_boot $source_path $target_path $window_type $sub1 $sub2
        echo "finished prepare"
        #PMI
        python $HYPERWORD_PATH/hyperwords/counts2pmi.py --cds $SMOOTHING $target_path/counts $target_path/pmi
        echo "finished ppmi"
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

        python $HYPERWORD_PATH/hyperwords/corpus2counts.py $source_path --win $WINDOW --thr $MIN $window_type $sub1 $sub2 > $target_path/counts
        python $HYPERWORD_PATH/hyperwords/counts2vocab.py $target_path/counts
}

function prepare_boot {
        local source_path=$1
        local target_path=$2
        local window_type=$3
        local sub1=$4
        local sub2=$5

        mkdir -p $target_path

        $TOOL_PATH/bootstrap.sh $source_path $target_path/bootstrapped_corpus

        python $HYPERWORD_PATH/hyperwords/corpus2counts.py $target_path/bootstrapped_corpus --win $WINDOW --thr $MIN $window_type $sub1 $sub2 > $target_path/counts
        python $HYPERWORD_PATH/hyperwords/counts2vocab.py $target_path/counts
        rm $target_path/bootstrapped_corpus
}

########################################### GloVe


function do_glove_boot {
        local source_path=$1
        local target_path=$2

        mkdir -p $target_path
        cd $target_path

        $TOOL_PATH/bootstrap.sh $source_path $target_path/bootstrapped_corpus

        $GLOVE_PATH/vocab_count -min-count $MIN < $target_path/bootstrapped_corpus > $target_path/vocab

        $GLOVE_PATH/cooccur -memory $MEMORY -vocab-file $target_path/vocab -window-size $WINDOW < $target_path/bootstrapped_corpus > $target_path/cooc

        $GLOVE_PATH/shuffle -memory $MEMORY < $target_path/cooc > $target_path/cooc_shuf

        $GLOVE_PATH/glove -verbose 1 -save-file $target_path/vectors -threads $NUM_THREADS -input-file $target_path/cooc_shuf -vector-size $DIM -binary 2 -vocab-file $target_path/vocab 

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
        cd $target_path

        $GLOVE_PATH/vocab_count -min-count $MIN < $source_path > $target_path/vocab

        $GLOVE_PATH/cooccur -memory $MEMORY -vocab-file $target_path/vocab -window-size $WINDOW < $source_path > $target_path/cooc

        $GLOVE_PATH/shuffle -memory $MEMORY < $target_path/cooc > $target_path/cooc_shuf

        $GLOVE_PATH/glove -verbose 1 -save-file $target_path/vectors -threads $NUM_THREADS -input-file $target_path/cooc_shuf -vector-size $DIM -binary 2 -vocab-file $target_path/vocab 

        python $HYPERWORD_PATH/hyperwords/text2numpy.py $target_path/vectors.txt

        rm $target_path/cooc
        rm $target_path/cooc_shuf
        echo "finished $target_path glove"
}


source ~/.bashrc && source activate jeseme
what=$1
i=$2
corpus=$3
MIN=$4
sampling=$5

case $what in 
        glove)  do_glove $DIR/$corpus $DIR/glove/$corpus/v$i
                ;;
        gloveb) do_glove_boot $DIR/$corpus $DIR/glove/$corpus/b$i 
                ;;
        ppmi)   case $sampling in
                none) do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ns_uw_v$i
                ;;
                weight) do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ws_ww_v$i "--ww" "--dsub" "1e-4"
                ;;
                prob) do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ps_dw_v$i "--dw" "--psub" "1e-4"
                ;;
                *) echo "Provide parameter what to do: none weight prob"
                ;;
            esac
            ;;
            #not executed for wiki due to size
            #do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ns_dw_v$i "--dw"
            #do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ns_ww_v$i "--ww"
            #do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ws_uw_v$i " " "--dsub" "1e-4"
            #do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ws_dw_v$i "--dw" "--dsub" "1e-4"  
            #do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ps_uw_v$i " " "--psub" "1e-4"
            #do_pmi $DIR/$corpus $DIR/pmi/${corpus}/ps_ww_v$i "--ww" "--psub" "1e-4"
        ppmib)  case $sampling in
                none) do_pmi_boot $DIR/$corpus $DIR/pmi/${corpus}/ns_uw_b$i
                ;;
                weight) do_pmi_boot $DIR/$corpus $DIR/pmi/${corpus}/ws_ww_b$i "--ww" "--dsub" "1e-4"
                ;;
                prob) do_pmi_boot $DIR/$corpus $DIR/pmi/${corpus}/ps_dw_b$i "--dw" "--psub" "1e-4"
                ;;
                *) echo "Provide parameter what to do: none weight prob"
                ;;
            esac
            ;;
            #not executed for wiki due to size
            #do_pmi_boot $DIR/$corpus $DIR/pmi/${corpus}/ns_dw_b$i "--dw"
            #do_pmi_boot $DIR/$corpus $DIR/pmi/${corpus}/ns_ww_b$i "--ww"
            #do_pmi_boot $DIR/$corpus $DIR/pmi/${corpus}/ws_uw_b$i " " "--dsub" "1e-4"
            #do_pmi_boot $DIR/$corpus $DIR/pmi/${corpus}/ws_dw_b$i "--dw" "--dsub" "1e-4"
            #do_pmi_boot $DIR/$corpus $DIR/pmi/${corpus}/ps_uw_b$i " " "--psub" "1e-4"
            #do_pmi_boot $DIR/$corpus $DIR/pmi/${corpus}/ps_ww_b$i "--ww" "--psub" "1e-4"
        w2v)    do_sgns $DIR/$corpus $DIR/sgns/$corpus/ps_dw_v$i 0 0 
                do_sgns $DIR/$corpus $DIR/sgns/$corpus/ns_dw_v$i 2 0
                #classic sgns options, not using the modifictions allowed by word2vecw
                ;;
        w2vb)   do_sgns_boot $DIR/$corpus $DIR/sgns/$corpus/ps_dw_b$i 0 0 
                do_sgns_boot $DIR/$corpus $DIR/sgns/$corpus/ns_dw_b$i 2 0
                #classic sgns options, not using the modifictions allowed by word2vecw
                ;;
        *)      echo "Provide parameter what to do: glove gloveb ppmi ppmib w2v w2vb"
                ;;
esac
