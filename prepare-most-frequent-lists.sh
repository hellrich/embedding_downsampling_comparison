DIR="/data/data_hellrich/tmp/emnlp2018/"
source ~/.bashrc && source activate jeseme

python most_frequent_words.py 1000 $DIR/coha > $DIR/coha_1000_most_frequent &
python most_frequent_words.py 1000 $DIR/news > $DIR/news_1000_most_frequent & 
python most_frequent_words.py 1000 $DIR/wiki > $DIR/wiki_1000_most_frequent &
wait
echo "done"
