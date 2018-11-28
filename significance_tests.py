# Skript für Mehrfachvergleiche zu
# 'Increasing Word Embedding Reliability by Changing Down-sampling Strategies'

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

data = open("significance_test_data")
header = data.readline().split()
comparison = data.readlines()
data.close()

comp = [x.split()[5:11] for x in comparison]

# Transformation für (verworfenen) Nemenyi-Test
friedarrays = []
for i in range(0,5):
    friedarrays.append([])
    for j in range(i, 30, 5):
        friedarrays[i].extend([float(x) for x in comp[j]])

# Arrays für Friedman- und Wilcoxontests
statarrays = []
for i in range(0,5):
    statarrays.append(np.array(friedarrays[i]))

# Test auf sämtlichen Modellen
scipy.stats.friedmanchisquare(*statarrays)
#FriedmanchisquareResult(statistic=40.506329113924046, pvalue=3.400838407282329e-08)
quade(pd.DataFrame(np.array(statarrays).T))
#(10.701205306157464, 1.3494277528725007e-07)

# Aus der scipy Dokumentation:
# https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.wilcoxon.html
# Because the normal approximation is used for the calculations,
# the samples used should be large. A typical rule is to require that n > 20.

_, p1 = scipy.stats.wilcoxon(statarrays[3], y=statarrays[4])
# WilcoxonResult(statistic=214.5, pvalue=0.09973669447863137)
_, p2 = scipy.stats.wilcoxon(statarrays[1], y=statarrays[3])
# WilcoxonResult(statistic=26.5, pvalue=2.285205227112723e-06)
_, p3 = scipy.stats.wilcoxon(statarrays[0], y=statarrays[3])
# WilcoxonResult(statistic=155.5, pvalue=0.008987819337280168)
_, p4 = scipy.stats.wilcoxon(statarrays[2], y=statarrays[3])
# WilcoxonResult(statistic=128.5, pvalue=0.00384145426183109)

# p-Wert-Korrektur nach Holm-Šídák
# http://www.statsmodels.org/dev/_modules/statsmodels/stats/multitest.html
multitest.multipletests([p1,p2,p3,p4], method='hs')
#(
# array([False,  True,  True,  True]),
# array([9.97366945e-02, 9.14078958e-06, 1.78948578e-02, 1.14801492e-02]),
# 0.012741455098566168, 0.0125)

# Das erste Array gibt an, welche Null-Hypothesen für das gegebene alpha verworfen werden können
# Das zweite Array gibt die korrigierten p-Werte an
# Die anderen beiden Werte geben korrigierte alpha-Werte für Šídák und Bonferroni-Methoden an
