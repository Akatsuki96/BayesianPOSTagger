# BayesianPOSTagger
A Bayesian POS Tagger in Perl 5.
Algorithms implemented:

1) Naive Bayes
2) Complete Naive Bayes (CBN)
3) Gibbs Sampling: random extraction, max frequent on to_sample samples and max on position

Idea and algorithm described in the following papers:
1) [Part of Speech Tagging with Naïve Bayes Methods](https://www.researchgate.net/publication/264743842_Part_of_Speech_Tagging_with_Naive_Bayes_Methods)

#Dataset
The dataset used is the Brown's corpus. You can find it [here](http://www.sls.hawaii.edu/bley-vroman/browntag_nolines.txt).
The meaning of the tags can be found [here](http://www.helsinki.fi/varieng/CoRD/corpora/BROWN/tags.html).
