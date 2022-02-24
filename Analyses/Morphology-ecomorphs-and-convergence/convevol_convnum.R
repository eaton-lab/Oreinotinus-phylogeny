# In this notebook I am planning to run covnum in multiple simulations
# in order to determine if the number....


# install.packages("convevol")

library(convevol)

# set workdir
setwd("./")


#load tree
tree <- read.tree (file='RAxML_bipartitions.splvl_withrealAyava_100scaff_mcov025_rmcov01_mar2021__lastNamesApplied.tre')

# prunning tree to remove hirsutum and membranaceum
original_tree <- tree
tree <- drop.tip(original_tree, c("hirsutum","membranaceum"))

# plot(tree)

#load matrix  (tips in rows, variables in columns) to get types 
dat_raw <- read.table(file = 'LAST_new_splvl_matrix_means_Jan2022.csv', sep = ',', header = TRUE)

#Load pcs
#load matrix  (tips in rows, variables in columns)
dat_pcs <- read.table(file = 'LAST_selectedFeatures_and_trichomeQ_PCA_DF.csv', sep = ',', header = TRUE, row.names=1)


#create df for result
result <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(result) <- c('test', 'group', 'p-value', 'species')


# 
#   #####     ######   #####         
#  #     #    #     # #     #  ####  
#        #    #     # #       #      
#   #####     ######  #        ####  
#  #          #       #            # 
#  #          #       #     # #    # 
#  #######    #        #####   ####  
#                                    
# 

# name
test_name = "2 PCs"

#reorder rows to have the same order than the tips in the tree
pcs <- dat_pcs[match(tree$tip.label, row.names(dat_pcs)), ]

#extract variables to include in analysis, convert to numeric, and set names as index
pcs <- pcs[,c("pc1","pc2")] 

#convert again to numbers
pcs[] <- lapply(pcs, as.numeric)

#set index of matrix in the same order of the tips in the tree
# rownames(pcs) <- tree$tip.label

#define some global paremeter
simulations = 1000
set.seed(42)

#iterate over all types of leaves
for (lt in c("LPT","IGE","SGE","D")){
  convtips <- subset(dat_raw, type == lt, select = "new_name")
  answer<-convnumsig(tree,pcs,convtips,nsim=simulations,plot=FALSE,ellipse=NULL,plotellipse=NULL)
  title(sub=lt)
  result[nrow(result) + 1,] <- c(test_name, lt, answer[1], paste0(convtips))
}



# 
#  #     #                                                                          
#  #  #  # #####  # ##### ######    #####  ######  ####  #    # #      #####  ####  
#  #  #  # #    # #   #   #         #    # #      #      #    # #        #   #      
#  #  #  # #    # #   #   #####     #    # #####   ####  #    # #        #    ####  
#  #  #  # #####  #   #   #         #####  #           # #    # #        #        # 
#  #  #  # #   #  #   #   #         #   #  #      #    # #    # #        #   #    # 
#   ## ##  #    # #   #   ######    #    # ######  ####   ####  ######   #    ####  
#                                                                                   
# 



#export dataframe result
write.csv(result, "./Results/convevol_convnum_results.csv", row.names=FALSE)





# 
#  ######                         ######  #     #  #####  
#  #     # #       ####  #####    #     # ##   ## #     # 
#  #     # #      #    #   #      #     # # # # # #       
#  ######  #      #    #   #      ######  #  #  #  #####  
#  #       #      #    #   #      #       #     #       # 
#  #       #      #    #   #      #       #     # #     # 
#  #       ######  ####    #      #       #     #  #####  
#                                                         
# 





# SVG graphics device
svg("LPT_phylomorphospace.svg")

# for (lt in c("LPT","IGE","SGE")){
convtips <- subset(dat_raw, type == "LPT", select = "new_name")
answer<-convnum(tree,pcs,convtips,plot=TRUE,ellipse=NULL,plotellipse=NULL)
title(main="LPT")

# Close the graphics device
dev.off() 




# SVG graphics device
svg("IGE_phylomorphospace.svg")

# for (lt in c("LPT","IGE","SGE")){
convtips <- subset(dat_raw, type == "IGE", select = "new_name")
answer<-convnum(tree,pcs,convtips,plot=TRUE,ellipse=NULL,plotellipse=NULL)
title(main="IGE")


# Close the graphics device
dev.off() 





# SVG graphics device
svg("SGE_phylomorphospace.svg")

# for (lt in c("LPT","IGE","SGE")){
convtips <- subset(dat_raw, type == "SGE", select = "new_name")
answer<-convnum(tree,pcs,convtips,plot=TRUE,ellipse=NULL,plotellipse=NULL)
title(main="SGE")


# Close the graphics device
dev.off() 


# SVG graphics device
svg("D_phylomorphospace.svg")

# for (lt in c("LPT","IGE","SGE")){
convtips <- subset(dat_raw, type == "D", select = "new_name")
answer<-convnum(tree,pcs,convtips,plot=TRUE,ellipse=NULL,plotellipse=NULL)
title(main="D")


# Close the graphics device
dev.off() 







