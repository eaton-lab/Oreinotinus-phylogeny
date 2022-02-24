# Checking multimodality in clusters that mix SGE+IGE


# load packages and set ggplot theme
library(tidyverse)
library(ggplot2)
library(ggpubr)
library(svglite)


#### set-up ####

# Which feature will be plotted
feature = "area"

# set dir
setwd("./")

# bring in data
data <- read.csv("4_STALKED_LAST_indvDF_withClusters.csv", header = T, sep = ",", na.strings = "")

# remove membranaceum and hirsutum
data <- data %>% filter(new_name != "hirsutum" & 
                        new_name != "membranaceum")


# detect the kmean group that is the mix using acutifolium as indicator
acuti <- data %>% filter(new_name == "acutifolium")             
kmean_group = as.numeric(acuti$kmeans_nmds_euclidean[1])

# select only columns of interests
data <- data[,c("type","kmeans_nmds_euclidean",feature)]


# be sure all variables in correct format
data$type <- as.factor(data$type)
data$kmeans_nmds_euclidean <- as.factor(data$kmeans_nmds_euclidean)
# data[feature] <- as.numeric(data[feature])

# create subsets of interest
sge <- data %>% filter(type == "SGE")
ige <- data %>% filter(type == "IGE")
mixture <- data %>% filter(kmeans_nmds_euclidean == kmean_group)

# create a cointainer for putting all subsets
## unify names, in ecotypes is type and in mixture is kmeans_nmds_euclidean
names(sge)[1] = "group"
names(ige)[1] = "group"
names(mixture)[2] = "group"
# purge unused columns
sge <- sge[,c(feature,"group")] 
ige <- ige[,c(feature,"group")] 
mixture <- mixture[,c(feature,"group")] 

# change cluster number with the word Cluster
mixture$group <- as.character(mixture$group)
mixture$group[mixture$group == kmean_group] <- "Cluster"

## merge dataframes
container <- rbind(mixture, sge, ige)


# make a theme
theme_clim <- function(){
  theme_bw() +
    theme(axis.text = element_text(size = 16), 
          # text = element_text(family = "Arial"),
          axis.title = element_text(size = 18),
          axis.line.x = element_line(color = "black"), 
          axis.line.y = element_line(color = "black"),
          panel.border = element_blank(),
          panel.grid.major.x = element_blank(),                                          
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_blank(),  
          plot.margin = unit(c(1, 1, 1, 1), units = , "cm"),
          plot.title = element_text(size = 18, vjust = 1, hjust = 0),
#           legend.text = element_text(size = 12),          
#           legend.title = element_blank(),                              
#           legend.position = c(0.95, 0.15), 
#           legend.key = element_blank(),
#           legend.background = element_rect(color = "black", 
#                                            fill = "transparent", 
#                                            size = 2, linetype = "blank"),
          strip.text = element_text(size = 10, color = "black", face = "bold.italic"),
          strip.background = element_rect(color = "white", fill = "white", size = 1))
}

# load  function for geom_flat_violin
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")



# make a test plot
(plot <- 
    ggplot(data = container, aes(x = group, y = get(feature), fill = group)) +
    geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.7) +
    geom_point(aes(y = get(feature), color = group), 
               position = position_jitter(width = 0.15), size = 1, alpha = 0.3) +
    geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.8) +
    labs(y = feature, x = "Group") +
    guides(fill = "none", color = "none") +
    # scale_y_continuous(limits = c(0, 100)) +
    scale_fill_manual(values = c("#ff0000", "#fa8c61", "#8c9eca")) +
    scale_colour_manual(values = c("#ff0000", "#fa8c61", "#8c9eca")) +
    # facet_wrap(vars(group), nrow = 2, ncol = 2, 
    #            labeller = labeller(group = labels)) +
    stat_compare_means(comparisons = list(c("Cluster", "IGE"), c("Cluster", "SGE"), 
                                          c("IGE", "SGE")), size = 3,
                                          # method = "t.test",
                                          ) + # apparently default is wilcox.test
    # scale_x_discrete(labels=c("Cluster", "IGE", "SGE")) +
    theme_clim())


# ggsave(plot , filename = paste0("cluster_vs_igesge_",feature,"_.svg"),
#        height = 5, width = 5)

