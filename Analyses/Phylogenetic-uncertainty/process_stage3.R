library(ape)
library(stringr)
library(phytools)
library(treeio)


n_phy = 100
min_age = 6.66
max_age = 14.82

for (i in 1:n_phy) {
    in_fn = paste0("stage2/oreino_reltime_",i,"_nexus.tre")
    out_fn = paste0("stage3/oreino_",i,".tre")
    phy = treeio::read.nexus(in_fn)
    phy = treeio::drop.tip(phy, tip="faux_outgroup")

    # correct tip labels for use with biogeography
    #phy$tip.label[ phy$tip.label=="new_name_1" ] = "triphyllum_new"
    #phy$tip.label[ phy$tip.label=="new_name_2" ] = "dumatorum"
    #phy$tip.label[ phy$tip.label=="new_sp_2" ] = "newsp.2"
    #phy$tip.label[ phy$tip.label=="new_sp_1" ] = "newsp.1"
    
    # find Oreinotinus crown node age
    mrca_idx = getMRCA(phy, tip=c("ciliatum","lautum"))
    bt = branching.times(phy)
    mrca_age = bt[ names(bt)==mrca_idx ]

    # rescale tree by crown age to u ~ Unif(min_age,max_age)
    mrca_rescale = runif(1,min_age,max_age) / mrca_age
    phy$edge.length = phy$edge.length * mrca_rescale

    # save tree
    write.tree(phy, file=out_fn)
}
