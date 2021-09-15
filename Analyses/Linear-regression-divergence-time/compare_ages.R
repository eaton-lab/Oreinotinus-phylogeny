library(ape)
library(treeio)
library(phytools)
fp = "./"
fn1 = paste0(fp, "oreino_reltime.tre")
fn2 = paste0(fp, "oreino_landis2021.mcc.tre")
plot_fn = paste0(fp, "./supp_fig_3_reltime_age_comparison.pdf")
phy1 = read.tree(fn1)
phy2 = read.beast(fn2)

# homogenize names
phy2@phylo$tip.label = sapply( phy2@phylo$tip.label, function(x) { strsplit(x,split="_")[[1]][2] })
names(phy2@phylo$tip.label) = NULL
phy1$tip.label[phy1$tip.label=="stellato-tomentosum"] = "stellato"
phy1 = drop.tip(phy1, tip=c("venustum"))

# backbone nodes
clades = matrix(NA,nrow=0,ncol=2)
clades = rbind(clades, c("toronis", "dentatum"))
clades = rbind(clades, c("toronis", "loeseneri"))
clades = rbind(clades, c("toronis", "microphyllum"))
clades = rbind(clades, c("toronis", "jucundum"))
clades = rbind(clades, c("toronis", "obtusatum" ))
clades = rbind(clades, c("toronis", "hartwegii"))
clades = rbind(clades, c("toronis", "costaricanum"))
clades = rbind(clades, c("toronis", "undulatum"))
clades = rbind(clades, c("toronis", "seemenii"))
clades = rbind(clades, c("stenocalyx", "loeseneri"))
clades = rbind(clades, c("loeseneri", "microcarpum"))
clades = rbind(clades, c("ciliatum", "microcarpum"))
clades = rbind(clades, c("microphyllum", "acutifolium"))
clades = rbind(clades, c("lautum", "jucundum"))
clades = rbind(clades, c("lautum", "disjunctum"))
clades = rbind(clades, c("stellato", "villosum"))
clades = rbind(clades, c("undulatum", "subsessile"))
clades = rbind(clades, c("undulatum", "lasiophyllum"))
clades = rbind(clades, c("hallii", "pichinchense"))
n_clades = nrow(clades)
cat("n_clades = ", n_clades, "\n", sep="")

# name clades
clade_labels = c()
for (i in 1:n_clades) {
    lbl = paste0( LETTERS[i], " : ", clades[i,1], "+", clades[i,2] )
    clade_labels[i] = lbl
}

# gather age comparisons
bt1 = branching.times(phy1)
bt2 = branching.times(phy2@phylo)
ages = matrix(NA, nrow=nrow(clades), ncol=5)
colnames(ages) = c("reltime", "hpd_mean", "hpd_lower", "hpd_upper", "color")
for (i in 1:nrow(clades)) {
    idx1        = findMRCA(phy1, clades[i,])
    idx2        = findMRCA(phy2@phylo, clades[i,])
    ages[i,1]   = bt1[names(bt1)==idx1]
    ages[i,2]   = bt2[names(bt2)==idx2]
    ages[i,3:4] = unlist(phy2@data[ phy2@data$node==idx2, ]$age_0.95_HPD)
    if (ages[i,1] >= ages[i,3] && ages[i,1] <= ages[i,4]) {
        ages[i,5] = 1
    } else {
        ages[i,5] = 2
    }
}


# generate plot
pdf(file=plot_fn, height=8, width=8)
plot(NA, xlim=c(0,22), ylim=c(0,22), xlab="Reltime + RAD-seq ages (Ma)", ylab="RevBayes + cpDNA ages and CIs (Ma)")
abline(0,1,lty=2)
segments( x0=ages[,1], y0=ages[,3], x1=ages[,1], y1=ages[,4], col=ages[,5] )
points( ages[,1], ages[,2], bg="white", col=ages[,5], cex=2, pch=21 )
points( ages[,1], ages[,2], col=ages[,5], cex=0.8, pch=LETTERS[1:n_clades] )
text(labels=clade_labels, x=0, y=rev(seq(14,22,length.out=n_clades)), adj=0, cex=0.7, col=ages[,5])
dev.off()

# linear model
m = lm( ages[,2] ~ ages[,1] )
summary(m)

# Bayesian expectations of HPD
n_outlier = sum(ages[,5] == 2)
n_total = nrow(ages)
n_exp = 0.05 * n_total
ratio_error = n_outlier/n_exp

# what is the probability that we have n_outlier (or more) bad matches?
# By definition, any true node age is not covered by the HPD95 w/ prob 0.05.
# What is the total probability that n_outlier (or more) ages are not covered?
# This is the sum of binomial probabilities for n_outlier, n_outlier+1,
# n_outlier+2, ..., n_total outliers.
p_error = sum( dbinom( n_outlier:n_total, size=n_total, prob=0.05) )
cat("Prob. that we detect ", n_outlier, " (or more) outliers? ", p_error, "\n", sep="")
cat("Is this less likely than expected by chance (p<0.05)? ", p_error<0.05, "\n", sep="")


