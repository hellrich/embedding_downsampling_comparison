CORPUS="news"
FREQUENT="/home/hellrich/tmp/emnlp2018/${CORPUS}_1000_most_frequent"

function correct_names {
	for y in $@
	do
		mv $y/vectors.txt.npy $y/vectors.words.npy 2>/dev/null
		mv $y/vectors.txt.vocab $y/vectors.words.vocab 2>/dev/null
	done
}

(
for x in /home/hellrich/tmp/emnlp2018/pmi/$CORPUS
do
	for y in $x/*v0 #assumes everything ready
	do
		base=${y::-2}
		normal=$(./evaluate-variant.sh $FREQUENT SVD svd_pmi "$base"v*)
		bootstrapped=$(./evaluate-variant.sh $FREQUENT SVD svd_pmi "$base"b*)

		labels=${base/*\//}; 
		label1=${labels::-4}
		label2=${labels:3:-1}

		echo "SVD	$CORPUS	$label1	$label2	n	$normal"
		echo "SVD	$CORPUS	$label1	$label2	b	$bootstrapped"
	done
done 
) > ${1}_svd &

 (
 for x in /home/hellrich/tmp/emnlp2018/sgns/$CORPUS
 do
 	for y in $x/*v0 #assumes everything ready
 	do
 		base=${y::-2}
 		normal=$(./evaluate-variant.sh $FREQUENT SGNS sgns "$base"v*)
 		bootstrapped=$(./evaluate-variant.sh $FREQUENT SGNS sgns "$base"b*)

 		labels=${base/*\//}; 
 		label1=${labels::-4}
 		label2=${labels:3:-1}

 		echo "SGNS	$CORPUS	$label1	$label2	n	$normal"
 		echo "SGNS	$CORPUS	$label1	$label2	b	$bootstrapped"
 	done
 done
 ) > ${1}_sgns &

 (
 for x in /home/hellrich/tmp/emnlp2018/glove/$CORPUS
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

 		echo "GloVe	$CORPUS	$label1	$label2	n	$normal"
 		echo "GloVe	$CORPUS	$label1	$label2	b	$bootstrapped"
 	done
 done
 ) > ${1}_glove &

wait
cat ${1}_svd ${1}_sgns ${1}_glove > ${1}
#rm ${1}_svd ${1}_sgns ${1}_glove
