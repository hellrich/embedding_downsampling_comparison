# Skript für Mehrfachvergleiche zu
# 'SVD Word Embeddings can be Perfectly Reliable'

import os
import scipy.stats           # für Friedman, Wilcoxon-Rangsummen
import scikit_posthocs as sp # für Nemenyi
import numpy as np
import statsmodels.stats.multitest as multitest # für Holm-Korrektur

os.chdir("/home/tech/Dokumente/EMNLP")
data = open("emnlpdata")
header = data.readline().split()
comparison = data.readlines()
data.close()

comp = [x.split()[5:11] for x in comparison]

# Nemenyi-Test nimmt Liste von Listen entgegen
friedarrays = []
for i in range(0,12):
    friedarrays.append([])
    for j in range(i, 48, 12):
        friedarrays[i].extend([float(x) for x in comp[j]])

# Arrays für Friedman- und Wilcoxontests
statarrays = []
for i in range(0,12):
    statarrays.append(np.array(friedarrays[i]))

# Sämtliche Modelle
#scipy.stats.friedmanchisquare(*statarrays)
#FriedmanchisquareResult(statistic=76.44669306349904, pvalue=7.148601356378572e-12)

# Die interessanten Modelle, mit GloVe
main4 = [statarrays[1], statarrays[8], statarrays[10], statarrays[11]]
scipy.stats.friedmanchisquare(*main4)
#FriedmanchisquareResult(statistic=29.529661016949177, pvalue=1.7330401341748304e-06)

# Ohne GloVe, immer noch signifikant
#main3 = [statarrays[1], statarrays[8], statarrays[10]]
#scipy.stats.friedmanchisquare(*main3)
#FriedmanchisquareResult(statistic=9.182795698924712, pvalue=0.010138676120387848)

# Wird nicht mehr verwendet
#sp.posthoc_nemenyi(friedarrays)

# Aus der scipy Dokumentation:
# https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.wilcoxon.html
# Because the normal approximation is used for the calculations,
# the samples used should be large. A typical rule is to require that n > 20.

_, p1 = scipy.stats.wilcoxon(statarrays[1], y=statarrays[8])
# WilcoxonResult(statistic=19.0, pvalue=0.0002938801169079549)
_, p2 = scipy.stats.wilcoxon(statarrays[10], y=statarrays[8])
# WilcoxonResult(statistic=124.0, pvalue=0.45756817506250735)
_, p3 = scipy.stats.wilcoxon(statarrays[11], y=statarrays[8])
# WilcoxonResult(statistic=13.5, pvalue=0.00015255033994867706)

# p-Wert-Korrektur nach Holm-Šídák
# http://www.statsmodels.org/dev/_modules/statsmodels/stats/multitest.html
multitest.multipletests([p1,p2,p3], method='hs')
#(
# array([ True, False,  True]),
# array([0.00058767, 0.45756818, 0.00045758]),
# 0.016952427508441503, 0.016666666666666666)

# Das erste Array gibt an, welche Null-Hypothesen für das gegebene alpha verworfen werden können
# Das zweite Array gibt die korrigierten p-Werte an
# Die anderen beiden Werte geben korrigierte alpha-Werte für Šídák und Bonferroni-Methoden an
