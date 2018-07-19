#done by hand before, should work

TMP="/home/hellrich/tmp/emnlp2018/news_tmp_folder"
OPEN_NLP_PATH="/home/hellrich/emnlp2018/apache-opennlp-1.8.4/bin"

mkdir -p $TMP

(
cd $TMP
#wget http://data.statmt.org/wmt18/translation-task/news.2017.en.shuffled.deduped.gz
#gunzip news.2017.en.shuffled.deduped.gz
$OPEN_NLP_PATH/opennlp SimpleTokenizer < $TMP/news.2017.en.shuffled.deduped | sed "s/[[:upper:]]*/\L&/g;s/[^[:alnum:]]*[ \t\n\r][^[:alnum:]]*/ /g;s/[^a-z0-9]*$/ /g;s/  */ /g;/^\s*$/d" > /home/hellrich/tmp/emnlp2018/news
)