#install library in console where NANUQ algoritm is
# install.packages("MSCquartets")

#load library
library("MSCquartets")

#Run nanuq
#In this step a nwk files with all trees obtained from TreeSlides was used.
nanuqDist = NANUQ("raxmlTrees_window2mb_msnip10_mcov9_IMAPED_100biggestScaff_300snps.nwk", 
      outfile = "NANUQdist_a1e-5b0.95", 
      alpha = 1e-5, #those values estimated following previous tests check video
      beta = 0.95,
      taxanames = NULL, #Names in the first tree are used  otherwise a vector with all names is required
      plot = TRUE) #Plot hypothesis triangular plots (simplex plot)


#After this point it is needed to process the outfile in Splitstree [https://uni-tuebingen.de/fakultaeten/mathematisch-naturwissenschaftliche-fakultaet/fachbereiche/informatik/lehrstuehle/algorithms-in-bioinformatics/software/splitstree/]
#Check script = network.splitstree
#Run splittree using 2.execute_splitstree.sh
