HYPERWORD_PATH="/home/hellrich/hyperwords/omerlevy-hyperwords-688addd64ca2/hyperwords"
WS_PATH="/home/hellrich/hyperwords/omerlevy-hyperwords-688addd64ca2/testsets/ws/"
ANA_PATH="/home/hellrich/hyperwords/omerlevy-hyperwords-688addd64ca2/testsets/analogy/"

function make_path { 
	local sep=","
	local base_path=$1
	local parts=${@:2}

	result=""
	for part in $parts
	do
		result=$result$base_path$part$sep
	done
	echo ${result::-1}
}

ws=$(make_path $WS_PATH bruni_men.txt radinsky_mturk.txt simlex999.txt ws353.txt)
ana=$(make_path $ANA_PATH google.txt msr.txt)


source ~/.bashrc && source activate jeseme


frequent=$1 #e.g. ~/tmp/emnlp2018/coha_1000_most_frequent
type=$2 #e.g. SVD
name=$3 #e.g. svd_pmi
dirs=${@:4} #e.g. ~/tmp/emnlp2018/pmi/coha/ws_ww_b*

# if [[ "$#" -eq 13 ]]; then
#     echo "good boy"
# else
# 	echo "bad argument"
# fi

python $HYPERWORD_PATH/evaluate_multiple.py --ws $ws --ana $ana --words $frequent $type $name $dirs