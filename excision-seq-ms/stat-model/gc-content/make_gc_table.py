#! /usr/bin/env python

import sys
import pdb

from numpy import mean, isnan
from genomedata import Genome
from collections import Counter

__version__ = '$Revision$'

def make_gc_table(gdfilename, signal_trackname, resolution, verbose):

    with Genome(gdfilename) as genome:

        for chromosome in genome:

            coord_range = xrange(chromosome.start, chromosome.end,
                                 resolution)                         
            for start in coord_range:
                end = start + resolution

                seq = chromosome.seq[start:end].tostring()
                gc_content = calc_gc_content(seq)

                mean_signal = mean(chromosome[start:end, signal_trackname])
                if isnan(mean_signal): continue
                
                fields = (mean_signal, gc_content, resolution)
                print '\t'.join(map(str, fields))

def calc_gc_content(seq):
    nucs = Counter(seq)

    total = float(sum(nucs.values()))
    num_gc = float(nucs['C'] + nucs['G'])

    return num_gc / total

def parse_options(args):
    from optparse import OptionParser

    usage = "%prog [OPTION]... GENOMEDATADIR"
    version = "%%prog %s" % __version__
    description = ("")

    parser = OptionParser(usage=usage, version=version,
                          description=description)

    parser.add_option("-t", "--trackname", action="store",
        default=None, help="signal trackname (default: %default)")

    parser.add_option("-r", "--resolution", action="store", type='int',
        default=50, help="resolution (default: %default)")

    parser.add_option("-v", "--verbose", action="store_true",
        default=False, help="verbose output (default: %default)")

    options, args = parser.parse_args(args)

    if len(args) < 1:
        parser.error("specify genomedata filename")

    return options, args

def main(args=sys.argv[1:]):
    options, args = parse_options(args)

    if not options.trackname:
        parser.error("specify signal trackname")

    gdfilename = args[0]
    kwargs = {'signal_trackname':options.trackname,
              'resolution':options.resolution,
              'verbose':options.verbose}
    return make_gc_table(gdfilename, **kwargs)

if __name__ == '__main__':
    sys.exit(main()) 
