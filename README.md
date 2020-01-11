# BayesianPOSTagger
A Bayesian POS Tagger in Perl 5.
Algorithms implemented:

1) Naive Bayes
2) Complete Naive Bayes (CNB)
3) Gibbs Sampling: random extraction, max frequent on to_sample samples and max on position

Idea and algorithm described in the following papers:
1) For CNB: [Part of Speech Tagging with Naïve Bayes Methods](https://www.researchgate.net/publication/264743842_Part_of_Speech_Tagging_with_Naive_Bayes_Methods)
2) For Gibbs Sampling(Idea for the approach): [A Fully Bayesian Approach to Unsupervised Part-of-Speech Tagging](https://nlp.stanford.edu/pubs/goldwater_griffiths_acl07.pdf)

# Dataset
The dataset used is the Brown's corpus. You can find it [here](http://www.sls.hawaii.edu/bley-vroman/browntag_nolines.txt).
The meaning of the tags can be found [here](http://www.helsinki.fi/varieng/CoRD/corpora/BROWN/tags.html).
