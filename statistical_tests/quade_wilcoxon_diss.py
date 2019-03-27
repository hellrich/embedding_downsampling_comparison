# Skript for experiments in my thesis "Word Embeddings: Reliability & Semantic Change"

import os
import scipy.stats           # für Friedman, Wilcoxon-Rangsummen
import numpy as np
import statsmodels.stats.multitest as multitest # für Holm-Korrektur

import pandas as pd       # für Quade-Test
from scipy.stats import f # für Quade-Test

# Aus R-Code portiert
# Quelle: Angewandte Statistik : Methodensammlung mit R
# Jürgen Hedderich und Lothar Sachs
# doi:10.1007/978-3-662-56657-2
def quade(x) :
    """x: pandas.DataFrame

Führt den Quade-Test (Dana Quade (1979), doi:10.1080/01621459.1979.10481670)
auf dem DataFrame durch."""
    k = x.shape[0]
    b = x.shape[1]
    # Rangzahlen
    R = x.rank(axis=1)
    # Spannweiten
    yRange = x.max(axis=1) - x.min(axis=1)
    Qi = yRange.rank()
    # Quade-Teststatistik
    S = R - (b+1)/2
    S = S.mul(Qi, axis='index')
    # Scores
    A2 = (S**2).sum().sum()
    # Q-gesamt
    B = (S.sum()**2).sum() / k
    # Q-zwischen
    stat = (k-1)*B / (A2-B)
    # cdf: distribution function of the F-distribution
    pval = 1 - f.cdf(stat, b-1, (b-1)*(k-1))
    return (stat, pval)

data = open("newdata_repeval.txt")
header = data.readline().split()
comparison = data.readlines()
data.close()

comp = [x.split()[5:11] for x in comparison]

# Transformation für (verworfenen) Nemenyi-Test
friedarrays = []
for i in range(0,5):
    friedarrays.append([])
    for j in range(i, 20, 5):
        friedarrays[i].extend([float(x) for x in comp[j]])

# Arrays für Friedman- und Wilcoxontests
statarrays = []
for i in range(0,5):
    statarrays.append(np.array(friedarrays[i]))

# Test auf sämtlichen Modellen
scipy.stats.friedmanchisquare(*statarrays)
#FriedmanchisquareResult(statistic=40.506329113924046, pvalue=3.400838407282329e-08)
print(quade(pd.DataFrame(np.array(statarrays).T)))
#(10.701205306157464, 1.3494277528725007e-07)

# Aus der scipy Dokumentation:
# https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.wilcoxon.html
# Because the normal approximation is used for the calculations,
# the samples used should be large. A typical rule is to require that n > 20.

#svd weight vs sgns
_, p1 = scipy.stats.wilcoxon(statarrays[3], y=statarrays[4])
#svd none vs svd weight
_, p2 = scipy.stats.wilcoxon(statarrays[1], y=statarrays[3])
#glove vs svd w
_, p3 = scipy.stats.wilcoxon(statarrays[0], y=statarrays[3])
#svd p vs svd w
_, p4 = scipy.stats.wilcoxon(statarrays[2], y=statarrays[3])

print(p1,p2,p3,p4)
# p-Wert-Korrektur nach Holm-Šídák
# http://www.statsmodels.org/dev/_modules/statsmodels/stats/multitest.html
print(multitest.multipletests([p1,p2,p3,p4], method='hs'))


# Das erste Array gibt an, welche Null-Hypothesen für das gegebene alpha verworfen werden können
# Das zweite Array gibt die korrigierten p-Werte an
# Die anderen beiden Werte geben korrigierte alpha-Werte für Šídák und Bonferroni-Methoden an
