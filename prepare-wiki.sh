#done by hand before, should work

DIR="/data/data_hellrich/tmp/emnlp2018/"
TMP="$DIR/wiki_tmp_folder"
OPEN_NLP_PATH="/home/hellrich/embedding_downsampling_comparison/apache-opennlp-1.8.4/bin"

mkdir -p $TMP

(
cd $TMP
#downloads and cleans en wiki corpus (one article per line) from https://linguatools.org/tools/corpora/wikipedia-monolingual-corpora/

SED='s/&apos;/'"'"'/g;s/&lt;/</g;s/&gt/>/g;s/&quot;/"/g;s/&amp;/\&/g' #is used twice to process escaped stuff
wget https://www.dropbox.com/s/j8kg3q6r7v7afd1/enwiki-20140707-corpus.xml.bz2 && bzip2 -d enwiki-20140707-corpus.xml.bz2 && perl xml2txt.pl -article-per-line -nomath -notables -nodisambig enwiki-20140707-corpus.xml enwiki-20140707-corpus.txt && sed $SED enwiki-20140707-corpus.txt | sed $SED > enwiki-20140707-corpus.clean.txt 

$OPEN_NLP_PATH/opennlp SimpleTokenizer < $TMP/enwiki-20140707-corpus.clean.txt | sed "s/[[:upper:]]*/\L&/g;s/[^[:alnum:]]*[ \t\n\r][^[:alnum:]]*/ /g;s/[^a-z0-9]*$/ /g;s/  */ /g;/^\s*$/d" > "$DIR/wiki"
)