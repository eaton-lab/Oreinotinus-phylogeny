This folder contains all scripts and paremeters for running the Network analysis.

The scripts in this analysis are in three different files:

- `1_Reconstruct_trees_treeslider.ipynb`
- `2_NANUQ_execution.R`
- `3_splitstree_execution.sh`

They should be executed in that order.

In this folder can be found the output of script 1 and 2 independently: 
- `raxmlTrees_window2mb_msnip10_mcov9_IMAPED_100biggestScaff_300snps.nwk` It contains all trees with more than 300 snps
- `NANUQdist_a1e-5b0.95_alpha1e-05_beta0.95.nex` It contains the distance matrix 

Finally, there is the file `network.splitstree` that contains the parameters and instrucciones used by SplitsTree in order to reconstruct the network.

The subfolder `Testing_parameters` contains the notebooks where NANUQ parameters were explored.