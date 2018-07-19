from __future__ import print_function
import numpy as np
import sys
from docopt import docopt
from scipy import stats

data = []


def load_results(file_name):
    with open(file_name) as f:
        data = []
        for line in f:
            d = {}
            algorithm, corpus, frequent, window, bootstrapped, ws0, ws1, ws2, ws3, ana0, ana1, reliability = line.strip().split("\t")
            d["algorithm"] = algorithm
            if corpus == "coha":
                d["corpus"] = "COHA"
            else:
                d["corpus"] = corpus
            d["frequent"] = frequent
            d["window"] = window
            d["bootstrapped"] = bootstrapped
            d["ws0"] = [float(x) for x in ws0.split()]
            d["ws1"] = [float(x) for x in ws1.split()]
            d["ws2"] = [float(x) for x in ws2.split()]
            d["ws3"] = [float(x) for x in ws3.split()]
            d["ana0"] = [float(x) for x in ana0.split()]
            d["ana1"] = [float(x) for x in ana1.split()]
            d["reliability"] = [float(x) for x in reliability.split()]
            d["hmean_of_means"] = 7.0 / sum([1 / np.mean(c) for c in [d["ws0"], d["ws1"], d[
                                            "ws2"], d["ws3"], d["ana0"], d["ana1"], d["reliability"]]])
            d["hmean_separate"] = [7.0 / sum([1 / c[i] for c in [d["ws0"], d["ws1"], d["ws2"], d[
                                             "ws3"], d["ana0"], d["ana1"], d["reliability"]]]) for i in range(len(d["ws0"]))]
            d["whmean_separate"] = [12.0 / sum([1 / c[i] for c in [d["ws0"], d["ws1"], d["ws2"], d["ws3"], d["ana0"], d["ana1"], d[
                                               "reliability"], d["ana0"], d["ana1"], d["reliability"], d["reliability"], d["reliability"]]]) for i in range(len(d["ws0"]))]
            data.append(d)
    return data


# terrible code, modifies data
def mark_significant(data, column, emph1="", emph2="*", column_condition=lambda x: True, stddev=False):
    column_entries = []
    data_to_edit = []
    for d in data:
        if column_condition(d):
            data_to_edit.append(d)
            column_entries.append(d[column])
    means = [np.mean(c) for c in column_entries]
    maximum = max(means)
    if stddev:
        stddev = [np.std(c) for c in column_entries]
    max_indices = [i for i, m in enumerate(means) if m >= maximum]

    replace = []
    for i, m in enumerate(means):
        m = "{:.3f}".format(m)
        if stddev:
            m += "+/- "+"{:.3f}".format(stddev[i])
        if i in max_indices or (not column == "hmean_of_means" and any([stats.ttest_ind(column_entries[i], column_entries[mi])[1] > 0.05 for mi in max_indices])):
            m = emph1 + m + emph2
        replace.append(m)
    for i, d in enumerate(data_to_edit):
        d[column] = replace[i]


# terrible code, modifies data
def pretty_print(data, columns, sep="\t", header=True, column_condition=lambda x: True, ommit_corpus=False, latex=False):
    final= "\\\\" if latex else "" 
    info = "corpus bootstrapped algorithm frequent window".split() + columns
    if latex:
        info.remove("bootstrapped")
    nicer_abbreviations(data)
    if header:
        print(sep.join(info[1:]) + final)

    #hacky way to prevent multiple identical entries
    last_corpus=False
    last_algo=False
    last_frequent=False
    for d in data:
        if column_condition(d):
            to_print = [d[i] for i in info]
            #hacky way to prevent multiple identical entries
            if latex:
                if d["bootstrapped"] == "b" or d["bootstrapped"] == "yes":
                    d["corpus"] += "-Bootstr."
                if last_corpus == d["corpus"]:
                    to_print[0] = " "
                else:
                    last_corpus = d["corpus"]
                    to_print[0] = "\\multirow{19}{*}{"+d["corpus"]+"}"
                if last_algo == d["algorithm"]:
                    to_print[1] = " "
                else:
                    last_algo = d["algorithm"]
                    if d["algorithm"] == "SVD":
                        to_print[1] = "\\multirow{9}{*}{\\svdpmi}"
                    elif d["algorithm"] == "SGNS":
                        to_print[1] = "\\multirow{9}{*}{\\sgns}"
                    elif d["algorithm"] == "GloVe":
                        to_print[1] = "\\glove"
                if last_frequent == d["frequent"]: # and not last_algo == d["algorithm"]:
                    to_print[2] = " "
                else:
                    last_frequent = d["frequent"]
                    if d["algorithm"] == "SVD" or d["algorithm"] == "SGNS":
                        to_print[2] = "\\multirow{3}{*}{"+d["frequent"]+"}"
            if ommit_corpus:
                to_print = to_print[1:]
            print(sep.join(to_print) + final)

# terrible code, modifies data
def remove_most_sgns(data):
    to_remove = [d for d in data if d["algorithm"] == "SGNS" and (
        d["frequent"] == "ws" or d["window"] == "ww" or d["window"] == "uw")]
    for t in to_remove:
        data.remove(t)


# terrible code, modifies data
def nicer_abbreviations(data):
    for d in data:
        if d["frequent"] == "ws":
            d["frequent"] = "weight"
        elif d["frequent"] == "ns":
            d["frequent"] = "none"
        elif d["frequent"] == "ps":
            d["frequent"] = "prob."
        if d["window"] == "ww":
            d["window"] = "weight"
        elif d["window"] == "uw":
            d["window"] = "none"
        elif d["window"] == "dw":
            d["window"] = "prob."
        if d["bootstrapped"] == "b":
            d["bootstrapped"] = "yes"
        elif d["bootstrapped"] == "n":
            d["bootstrapped"] = "no"


def main(file_name, latex=False, split=False, stddev=False):
    global data
    data = load_results(file_name)
    #remove_most_sgns(data)
    # columns = "ws0 ws1 ws2 ws3 ana0 ana1 reliability hmean_of_means
    # hmean_separate whmean_separate".split()
    columns = "ws0 ws1 ws2 ws3 ana0 ana1 reliability".split()
    if latex:
        for column in columns:
            mark_significant(data, column, emph1="\\textbf{", emph2="}", column_condition=lambda x:  x[
                             "bootstrapped"] == "n" or x["bootstrapped"] == "no", stddev=stddev)
            mark_significant(data, column, emph1="\\textbf{", emph2="}", column_condition=lambda x: x[
                             "bootstrapped"] == "b" or x["bootstrapped"] == "yes", stddev=stddev)
        ommit_corpus = split
        pretty_print(data, columns, sep=" & ", header=True, column_condition=lambda x:  x[
                     "bootstrapped"] == "n" or x["bootstrapped"] == "no", ommit_corpus=ommit_corpus, latex=True)
        if split:
            print("\n\nBootstrapped\n")
        else:
            print("\\hline")
        pretty_print(data, columns, sep=" & ", header=False, column_condition=lambda x: x[
                     "bootstrapped"] == "b" or x["bootstrapped"] == "yes", ommit_corpus=ommit_corpus, latex=True)
    else:
        for column in columns:
            mark_significant(data, column, emph1="", emph2="*",
                             column_condition=lambda x: x["bootstrapped"] == "n" or x["bootstrapped"] == "no", stddev=stddev)
            mark_significant(data, column, emph1="*", emph2="",
                             column_condition=lambda x: x["bootstrapped"] == "b" or x["bootstrapped"] == "yes", stddev=stddev)
        pretty_print(data, columns, header=True,
                     column_condition=lambda x: x["bootstrapped"] == "n" or x["bootstrapped"] == "no")
        pretty_print(data, columns, header=False,
                     column_condition=lambda x: x["bootstrapped"] == "b" or x["bootstrapped"] == "yes")

if __name__ == "__main__":
    args = docopt("""
        Usage:
            analyze-results.py [options] <file_name>

        Options:
            --latex    Latex pretty print results
            --split    Split between (non-)bootstraped
            --stddev   Show standard deviations
    """)
    main(args["<file_name>"], args["--latex"], args["--split"], args["--stddev"])
