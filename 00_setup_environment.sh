#!/usr/bin/env bash

#Setting the constant for the directories
WORKDIR="/data/users/${USER}/assembly_annotation_course"
LOGDIR="$WORKDIR/log"
RESULTDIR=$WORKDIR/results
DATADIR=$WORKDIR/data

#Creating the directories for the environment
mkdir -p $LOGDIR
mkdir -p $RESULTDIR
mkdir -p $RESULTDIR/Pacbio
mkdir -p $RESULTDIR/RNASeq
mkdir -p $DATADIR


#Linking the data
ln -sf /data/courses/assembly-annotation-course/raw_data/Lu-1 $DATADIR
ln -sf /data/courses/assembly-annotation-course/raw_data/RNAseq_Sha $DATADIR