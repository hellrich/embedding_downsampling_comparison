source ~/.bashrc && source activate jeseme

python most_frequent_words.py 1000 ~/tmp/emnlp2018/coha > ~/tmp/emnlp2018/coha_1000_most_frequent &
python most_frequent_words.py 1000 ~/tmp/emnlp2018/news > ~/tmp/emnlp2018/news_1000_most_frequent & 

wait
echo "done"
