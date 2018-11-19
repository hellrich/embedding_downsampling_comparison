#!/bin/sh
DIR="/data/data_hellrich/tmp/emnlp2018/"
FREQUENT="$DIR/wiki_1000_most_frequent"
CORPUS="wiki"
RESULTS="/home/hellrich/embedding_downsampling_comparison/results/results-${CORPUS}"

for x in $DIR/pmi/$CORPUS
do
	for y in $x/*v0 #assumes everything ready
	do
		base=${y::-2}
		normal=$(./evaluate-variant.sh $FREQUENT SVD svd_pmi "$base"v*)
		bootstrapped=$(./evaluate-variant.sh $FREQUENT SVD svd_pmi "$base"b*)

		labels=${base/*\//}; 
		label1=${labels::-4}
		label2=${labels:3:-1}

		echo "SVD	$CORPUS	$label1	$label2	n	$normal" > $RESULTS
		echo "SVD	$CORPUS	$label1	$label2	b	$bootstrapped" >> $RESULTS
	done
done

for x in $DIR/sgns/$CORPUS
do
	for y in $x/*v0 #assumes everything ready
	do
		base=${y::-2}
		normal=$(./evaluate-variant.sh $FREQUENT SGNS sgns "$base"v*)
		bootstrapped=$(./evaluate-variant.sh $FREQUENT SGNS sgns "$base"b*)

		labels=${base/*\//}; 
		label1=${labels::-4}
		label2=${labels:3:-1}

		echo "SGNS	$CORPUS	$label1	$label2	n	$normal" >> $RESULTS
		echo "SGNS	$CORPUS	$label1	$label2	b	$bootstrapped" >> $RESULTS
	done
done

function correct_names {
	for y in $@
	do
		mv $y/vectors.txt.npy $y/vectors.words.npy 2>/dev/null
		mv $y/vectors.txt.vocab $y/vectors.words.vocab 2>/dev/null
	done
}

for x in $DIR/glove/$CORPUS
do
	for y in $x/*v0 #assumes everything ready
	do
		base=${y::-2}
		correct_names "$base"v*
		correct_names "$base"b*

		normal=$(./evaluate-variant.sh $FREQUENT SGNS vectors "$base"v*)
		bootstrapped=$(./evaluate-variant.sh $FREQUENT SGNS vectors "$base"b*)

		label1=ws
		label2=ww

		echo "GloVe	$CORPUS	$label1	$label2	n	$normal" >> $RESULTS
		echo "GloVe	$CORPUS	$label1	$label2	b	$bootstrapped" >> $RESULTS
	done
done
