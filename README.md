# embedding_downsampling_comparison
Experiments on different word embedding algorithms and how down-sampling of frequent words or nearby words affects them, especially in regards to reliability.
 
Probabilistic down-sampling seems to be worse than weighting in most scenarios.

Inlcudes a modified word2vec(w) which uses weighting, not beneficial here. Assumes conda for dependency managament and [my modified version of hyperwords](https://github.com/hellrich/hyperwords)
