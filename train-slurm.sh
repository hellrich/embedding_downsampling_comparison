#!/bin/bash
#SBATCH -J sgns_impl_comparison
#SBATCH --mem 10g
#SBATCH --cpus-per-task 10

#muss anhand der alten skripte komplette überarbeitet werden
WORKING_DIR=/home/hellrich/tmp/sgns_implementation_comparison
WORKING_TMP=/data/data_hellrich/tmp

CORPUS_NAME=corpus #debug
WIN=5
MIN=100
DOWNSAMPLE=1e-4
DIM=500
ITER=5


function do_hyper {
        source activate sgns_impl_hyper
        local id=$1
        local threads=$2

        local IN=$WORKING_DIR/$CORPUS_NAME
        local OUT=$WORKING_DIR/models/${threads}_threads/hyper_default/$id

        #iter set in child script
        (
                export WORKING_DIR=$WORKING_DIR
                export ITER=$ITER
                export RND=0
                export TMP=$WORKING_TMP/${threads}_threads/hyper_default/$id
                bash hyperwords_corpus2sgns.sh $IN $OUT --dyn --del --thr $MIN --win $WIN --sub $DOWNSAMPLE --cds 0.75 --dim $DIM --neg 5 --cpu $threads
        )
        echo "done hyper default $id"
}

function do_hyper_random {
        source activate sgns_impl_hyper
        local id=$1
        local threads=$2

        local IN=$WORKING_DIR/$CORPUS_NAME
        local OUT=$WORKING_DIR/models/${threads}_threads/hyper_random/$id

        #iter set in child script
        (
                export WORKING_DIR=$WORKING_DIR
                export ITER=$ITER
                export RND=1
                export TMP=$WORKING_TMP/${threads}_threads/hyper_random/$id
                bash hyperwords_corpus2sgns.sh $IN $OUT --dyn --del --thr $MIN --win $WIN --sub $DOWNSAMPLE --cds 0.75 --dim $DIM --neg 5 --cpu $threads
        )
        echo "done hyper random $id"
}

function do_word2vec {
        cd $WORKING_DIR
        local id=$1    
        local threads=$2

        local IN=$WORKING_DIR/$CORPUS_NAME
        local OUT=$WORKING_DIR/models/${threads}_threads/word2vec/$id
        mkdir -p $OUT
        word2vec/word2vec -train $IN -output $OUT/vec -size $DIM -window $WIN -sample $DOWNSAMPLE -negative 5 -cbow 0 -min-count $MIN -threads $threads -iter $ITER
        echo "done word2vec $id"
}

function do_gensim_default {
        source activate sgns_impl_gensim
        local id=$1
        local threads=$2

        local IN=$WORKING_DIR/$CORPUS_NAME
        local OUT=$WORKING_DIR/models/${threads}_threads/gensim_default/$id
        mkdir -p $OUT
        python train_gensim.py $IN $OUT --dim $DIM --threads $threads --window $WIN --min $MIN --sample $DOWNSAMPLE --iter $ITER
        echo "done gensim $id"    
}

function do_gensim_random {
        source activate sgns_impl_gensim
        local id=$1
        local threads=$2

        local IN=$WORKING_DIR/$CORPUS_NAME
        local OUT=$WORKING_DIR/models/${threads}_threads/gensim_random/$id
        mkdir -p $OUT
        python train_gensim.py $IN $OUT --dim $DIM --threads $threads --window $WIN --min $MIN --sample $DOWNSAMPLE --iter $ITER --random
        echo "done gensim random $id"    
}

function do_gensim_deterministic {
        source activate sgns_impl_gensim
        local id=$1
        local threads=$2

        local IN=$WORKING_DIR/$CORPUS_NAME
        local OUT=$WORKING_DIR/models/${threads}_threads/gensim_deterministic/$id
        mkdir -p $OUT
        (
                export PYTHONHASHSEED=0
                python train_gensim.py $IN $OUT --dim $DIM --threads $threads --window $WIN --min $MIN --sample $DOWNSAMPLE --iter $ITER
        )
        echo "done gensim deterministic $id"    
}

#prevents conda bugs
source ~/.bashrc

id=$2
threads=$3

case $1 in 
        hyper1) do_hyper $id $threads
                ;;
        hyper2) do_hyper_random $id $threads
                ;;
        word2vec) do_word2vec $id $threads
                ;;
        gensim1) do_gensim_default $id $threads
                ;;
        gensim2) do_gensim_deterministic $id $threads
                ;;
        gensim3) do_gensim_random $id $threads
                ;;
        *)      echo "Provide parameter what to do: hyper1 / hyper2 / word2vec / gensim1 / gensim2 / gensim3"
                ;;
esac