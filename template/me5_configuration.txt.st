################################################################################
#
# Copyright (c) 2009 The MadGraph Development team and Contributors
#
# This file is a part of the MadGraph 5 project, an application which 
# automatically generates Feynman diagrams and matrix elements for arbitrary
# high-energy processes in the Standard Model and beyond.
#
# It is subject to the MadGraph license which should accompany this 
# distribution.
#
# For more information, please visit: http://madgraph.phys.ucl.ac.be
#
################################################################################
#
# This File contains some configuration variable for MadGraph/MadEvent
# This File is use if the file ~/.mg5/mg5_configuration.txt is NOT present.
# If you place this files in ~/.mg5/mg5_configuration.txt then all path should
# be absolute.
#
################################################################################

# Prefered Fortran Compiler
# If None: try to find g77 or gfortran on the system
fortran_compiler = None #  

# Prefered Text Editor
#  Default: use the shell default Editor
#           or try to find one available on the system
#  Be careful: Only shell based editor are allowed
text_editor = None #  

# Prefered WebBrower
# If None: try to find one available on the system
web_browser = None #  

# Prefered PS viewer
# If None: try to find one available on the system
eps_viewer = None #  

# Time allowed to answer question (if no answer takes default value)
# 0: No time limit
timeout = 20 #  

# Pythia8 Path.
# Define the path to the pythia8 directory.
# relative path start from mg5 directory
pythia8_path = None #  

################################################################################
#  INFO FOR MADEVENT 
################################################################################
# If this file is in a MADEVENT Template. 'main directory' is the directory
# containing the SubProcesses directory. Otherwise this is the madgraph5 main
# directory (containing the directories madgraph and Template)

# Allow/Forbid the automatic opening of the web browser  (on the status page)
#when launching MadEvent [True/False]
automatic_html_opening = False #  

# Default Running mode 
# 0: single machine/ 1: cluster / 2: multicore
run_mode = 0 #  

# Cluster Type [pbs|sge|condor|lsf|ge] Use for cluster run only
# And cluster queue
cluster_type = condor #  
cluster_queue = madgraph #  

# Nb_core to use (None = all) This is use only for multicore run
nb_core = None #  

# Pythia-PGS Package
# relative path start from main directory
#  
pythia-pgs_path = $pythiapgs$ #  

# Delphes Package
# relative path start from main directory
#
delphes_path = /home/wavewave/repo/ext/MadGraph5_v1_4_8_4/Delphes #  

# MadAnalysis Package [For Drawing output]
# relative path start from main directory
#
madanalysis_path = /home/wavewave/repo/ext/MadGraph5_v1_4_8_4/MadAnalysis #  

# ExRootAnalysis Package
# relative path start from main directory
#
exrootanalysis_path = /home/wavewave/repo/ext/MadGraph5_v1_4_8_4/ExRootAnalysis #  

# TOPDRAWER PATH
# Path to the directory containing td executables
# relative path start from main directory
#
td_path = /home/wavewave/repo/ext/MadGraph5_v1_4_8_4/td #  





group_subprocesses = Auto 
ignore_six_quark_processes = False 
