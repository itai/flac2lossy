#!/bin/zsh
#
# File:     parallel_flac_to_mp3.zsh
# Author:   Itai Fiat <itai.fiat@gmail.com>
# Revision: 2009-05-05
#
# Converts FLAC files in a directory to MP3 in a parallel directory structure.
#
# TODO: Remove from DST_DIR files and directories that have been removed from
#       SRC_DIR.
#       
#       Think about getting canonical path without using readlink.

#{{{ Command line arguments
if [[ $# -ne 2 ]];
then
    echo "Usage: $0 <FLAC directory> <MP3 directory>"
    echo ""
    echo "Converts and copies FLAC file hierarchy to MP3 directory."
    echo ""
    echo "Warning! This script deletes all MP3s in target directory which do not have a FLAC equivalent (this will be controlled by a switch eventually)."
    exit -1
fi
SRC_DIR=`readlink -f $1`
DST_DIR=`readlink -f $2`
if [[ ! -d $SRC_DIR ]];
then
    echo "FLAC directory does not exist."
    exit -1
fi
#}}}

#{{{ Delete all temporary files on SIGTERM, exit
trap "rm -f $DST_DIR/**/*.mp3.tmp(.N)" TERM EXIT
#}}}

#{{{ Create destination directory (if not already existing)
mkdir -p $DST_DIR
#}}}

#{{{ Get directories, files
cd $SRC_DIR
DIRS=(**/*(/N))
FILES=(**/*(.N))
#}}}

#{{{ Copy directories
cd $DST_DIR
[[ -n $DIRS ]] && mkdir -p $DIRS
#}}}

#{{{ Convert files
cd $DST_DIR
for f ($FILES)
do
    SOURCE_FILE=$SRC_DIR/$f
    TARGET_FILE=$DST_DIR/$f:r.mp3

    [[ ( ! -e $TARGET_FILE) || ( $SOURCE_FILE -nt $TARGET_FILE ) ]] &&
        single_flac_to_mp3.pl $SOURCE_FILE $TARGET_FILE.tmp &&
        mv $TARGET_FILE.tmp $TARGET_FILE
done
#}}}

#{{{ Delete MP3s without a FLAC equivalent
no_flac() { [[ ! -e $SRC_DIR/$REPLY:r.flac ]] }
cd $DST_DIR
rm -f **/*(e:no_flac:)
#}}}

# vim:foldmethod=marker:
