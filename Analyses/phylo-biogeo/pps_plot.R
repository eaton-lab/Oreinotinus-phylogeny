library(ape)
library(geiger)
library(phytools)
library(ggplot2)
library(reshape2)
library(cowplot)

# function
convert_num_to_regions = function(x, key) {
    
    m = matrix(0, nrow=nrow(x), ncol=12)
    
    codes = list( ENA=1,
                  ECMx=2,
                  WMx=3,
                  Oax=4,
                  Chps=5,
                  Crb=6,
                  CRPa=7,
                  WCol=8,
                  ECol=9,
                  SCol=10,
                  Per=11,
                  Bol=12 )

    for (i in 1:nrow(x)) {
        y = key$label[ key$state==x[i,2] ]
        tok = strsplit(y, "\\+")[[1]]
        idx = c()
        for (j in 1:length(tok)) {
            idx = c(idx, codes[[ tok[j] ]])
        }
        m[i, idx] = 1
    }
    rownames(m) = x[,1]
    colnames(m) = names(codes)
    return(m)
}

# file paths
fp       = "./"
param_fn = paste0(fp, "output/out.model.log")
phy_fn   = paste0(fp, "oreino_reltime.tre")
sim_fp   = paste0(fp, "output/pps/")
plot_fn  = paste0(fp, "sm_fig11_PPS_regional_leaftypes.pdf")

# read files
dat      = read.csv(param_fn, sep="\t", header=T)
phy      = read.tree(phy_fn)
col_dat = read.csv(paste0(fp, "n12_colors.txt"), sep=",", header=T)

# process PPS files
sim_files = list.files( sim_fp )
sim_morph = list()
sim_bg = list()
k = 1
for (i in 1:length(sim_files)) {
    sim_fn = sim_files[[i]]
    sim_tok = strsplit(sim_fn, "_")[[1]]
    sim_id = as.numeric(sim_tok[length(sim_tok)])
    # morph data
    morph_fn = paste0( sim_fp, sim_fn, "/m_morph.nex")
    x = unlist( read.nexus.data( morph_fn ) )
    x = x[ names(x) != "dentatum" ]
    sim_morph[[k]] = x
    # bg data
    bg_fn = paste0( sim_fp, sim_fn, "/m_bg.tsv")
    y = read.csv( bg_fn, header=F, sep="\t" )
    y = y[ y[,1] != "dentatum", ]
    y = convert_num_to_regions(y, col_dat)
    #y = y[ y,-c(1) ]
    y = y[ , 2:ncol(y) ]
    sim_bg[[k]] = y
    # mask ENA lineages (optional)
    y[,1] = 0
    # next sim
    k = k + 1
}

# tabulate number of leaftypes per region
n_sim = length(sim_bg)
n_2type = c()
n_3type = c()
for (i in 1:n_sim) {
    
    # get data
    taxa = rownames(sim_bg[[i]])
    dm = sim_morph[[i]]
    dbg = sim_bg[[i]]
    
    # fill out matrix
    x = matrix(0, ncol=4, nrow=11)
    for (j in 1:length(taxa)) {
        tj = taxa[j]
        bg_idx = which( dbg[ rownames(dbg) == tj, ] == 1 )
        m_idx = as.numeric( dm[ names(dm) == tj ] ) + 1
        if (m_idx == 0) { print( c(bg_idx, m_idx) ) }
        x[ bg_idx, m_idx ] = 1
    }
    
    # count number 2-type regions
    n_2type = c( n_2type, sum(rowSums(x) >= 2) )
    
    # count number 3-type regions
    n_3type = c( n_3type, sum(rowSums(x) >= 3) )
}

# summarize counts across replicates
n_2type = factor(n_2type, ordered=T, levels=0:11)
n_3type = factor(n_3type, ordered=T, levels=0:11)

t_2type = table(n_2type)
t_3type = table(n_3type)

p_2type = sum(t_2type[10:12]) / sum(t_2type)
p_3type = sum(t_3type[6:12]) / sum(t_3type)

cat("Num. 2+ leaftypes in 9+ regions = ", sum(t_2type[10:12]), "\n", sep="")
cat("Num. 3+ leaftypes in 5+ regions = ", sum(t_3type[6:12]), "\n", sep="")

cat("Freq. 2+ leaftypes in 9+ regions = ", p_2type, "\n", sep="")
cat("Freq. 3+ leaftypes in 5+ regions = ", p_3type, "\n", sep="")

# generate plots
df_2type = data.frame( n_region=0:11, freq=as.vector(t_2type)/sum(t_2type))
p = ggplot(df_2type, aes(x=n_region, y=freq))
p = p + geom_line()
p = p + geom_vline(xintercept = 9, color="red", lty=2)
p = p + scale_x_continuous( limits=c(0,11), breaks=c(0,3,6,9)) + ylim(0,1)
p = p + xlab("Num. regions") + ylab("Probability")
p = p + ggtitle("Num. regions with 2+ leaf types")
p = p + theme(panel.background = element_rect(fill = "white", colour = "grey50"),
              plot.title = element_text(hjust = 0.5))
p2 = p

df_3type = data.frame( n_region=0:11, freq=as.vector(t_3type)/sum(t_3type))
p = ggplot(df_3type, aes(x=n_region, y=freq))
p = p + geom_line()
p = p + geom_vline(xintercept = 5, color="red", lty=2)
p = p + scale_x_continuous( limits=c(0,11), breaks=c(0,3,6,9)) + ylim(0,1)
p = p + xlab("Num. regions") + ylab("Probability")
p = p + ggtitle("Num. regions with 3+ leaf types")
p = p + theme(panel.background = element_rect(fill = "white", colour = "grey50"),
              plot.title = element_text(hjust = 0.5))
p3 = p


pg = plot_grid(p2, p3, align="hv")
pg

pdf(plot_fn, height=4, width=8)
print(pg)
dev.off()
