#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# Author: Fabien Coelho
# License: Public Domain
#

import argparse
ap = argparse.ArgumentParser(description='show stats about data: count average stddev [min q1 median q3 max]...')
ap.add_argument('--median', default=True, action='store_true',
				help='compute median and quartile values')
ap.add_argument('--no-median', dest='median', default=True,
				action='store_false',
				help='do not compute median and quartile values')
ap.add_argument('--more', default=False, action='store_true',
				help='show some more stats')
ap.add_argument('--limit', type=float, default=None,
				help='set limit for counting below limit values')
ap.add_argument('--length', type=int, default=None,
				help='set expected length, assume 0 if beyond')
ap.add_argument('--precision', type=int, default=1,
				help='floating point precision')
ap.add_argument('file', nargs='*', help='list of files to process')
opt = ap.parse_args()

# option consistency
if opt.limit != None:
	opt.more = True
if opt.more:
	opt.median = True

# reset arguments for fileinput
import sys
sys.argv[1:] = opt.file

import fileinput

n, skipped, vals = 0, 0, []
k, vmin, vmax = None, None, None
sum1, sum2 = 0.0, 0.0

for line in fileinput.input():
	try:
		v = float(line)
		if opt.median: # keep track only if needed
			vals.append(v)
		if k is None: # first time
			k, vmin, vmax = v, v, v
		else: # next time
			vmin = min(vmin, v)
			vmax = max(vmax, v)
		n += 1
		vmk = v - k
		sum1 += vmk
		sum2 += vmk * vmk
	except ValueError: # float conversion failed
		skipped += 1

if n == 0:
	# avoid ops on None below
	k, vmin, vmax = 0.0, 0.0, 0.0

if opt.length:
	assert "some data seen", n > 0
	missing = int(opt.length) - len(vals)
	assert "positive number of missing data", missing >= 0
	if missing > 0:
		print("warning: %d missing data, expanding with zeros" % missing)
		if opt.median:
			vals += [ 0.0 ] * missing
		vmin = min(vmin, 0.0)
		sum1 += - k * missing
		sum2 += k * k * missing
		n += missing
		assert len(vals) == int(opt.length)

if opt.median:
	assert "consistent length", len(vals) == n

# five numbers...
# numpy.percentile requires numpy at least 1.9 to use 'midpoint'
# statistics.median requires python 3.4 (?)
def median(vals, start, length):
	if len(vals) == 1:
		start, length = 0, 1
	m, odd = divmod(length, 2)
	#return 0.5 * (vals[start + m + odd - 1] + vals[start + m])
	return  vals[start + m] if odd else \
		0.5 * (vals[start + m-1] + vals[start + m])

# return ratio of below limit (limit included) values
def below(vals, limit):
	# hmmm... short but generates a list
	#return float(len([ v for v in vals if v <= limit ])) / len(vals)
	below_limit = 0
	for v in vals:
		if v <= limit:
			below_limit += 1
	return float(below_limit) / len(vals)

# float prettyprint with precision
def f(v):
	return ('%.' + str(opt.precision) + 'f') % v

# output
if skipped:
	print("warning: %d lines skipped" % skipped)

if n > 0:
	# show result (hmmm, precision is truncated...)
	from math import sqrt
	avg, stddev = k + sum1 / n, sqrt((sum2 - (sum1 * sum1) / n) / n)
	if opt.median:
		vals.sort()
		med = median(vals, 0, len(vals))
		# not sure about odd/even issues here... q3 needs fixing if len is 1
		q1 = median(vals, 0, len(vals) // 2)
		q3 = median(vals, (len(vals)+1) // 2, len(vals) // 2)
		# build summary message
		msg = "avg over %d: %s ± %s [%s, %s, %s, %s, %s]" % \
			  (n, f(avg), f(stddev), f(vmin), f(q1), f(med), f(q3), f(vmax))
		if opt.more:
			limit = opt.limit if opt.limit != None else 0.1 * med
			# msg += " <=%s:" % f(limit)
			msg += " %s%%" % f(100.0 * below(vals, limit))
	else:
		msg = "avg over %d: %s ± %s [%s, %s]" % \
			  (n, f(avg), f(stddev), f(vmin), f(vmax))
else:
	msg = "no data seen."

print(msg)
