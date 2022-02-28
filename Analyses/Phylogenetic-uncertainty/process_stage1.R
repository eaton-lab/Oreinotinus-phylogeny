library(ape)
library(stringr)
library(phytools)
library(treeio)

csv_fn = "taxon_names.csv"
df = read.table(csv_fn, header=T, sep=",")
phy_fn = "RAxML_bootstrap.splvl_withrealAyava_100scaff_mcov025_rmcov01_FEB2022_forboostrapping.tre"

# read in original bootstrap trees
phy = read.tree(phy_fn)

# process each tree
for (i in 1:length(phy)) {

    # correct taxon labels (file provided by Carlos)
    lbl_idx = match(phy[[i]]$tip.label, df[,1])
    phy[[i]]$tip.label = df[lbl_idx,2]
    phy[[i]]$tip.label[ phy[[i]]$tip.label=="new_name_1" ] = "triphyllum_new"
    phy[[i]]$tip.label[ phy[[i]]$tip.label=="new_name_2" ] = "dumatorum"
    phy[[i]]$tip.label[ phy[[i]]$tip.label=="new_sp_2" ] = "newsp.2"
    phy[[i]]$tip.label[ phy[[i]]$tip.label=="new_sp_1" ] = "newsp.1" 
    
    # add root the RAxML phylogeny on dentatum, while using the mean internal branch
    # length as the stem branch length leading to Oreinotinus (excl. dentatum)
    outgroup_idx = which( phy[[i]]$tip.label=="dentatum" )
    outgroup_brlen = phy[[i]]$edge.length[ phy[[i]]$edge[,2] == outgroup_idx ]
    avg_len = mean( phy[[i]]$edge.length[ phy[[i]]$edge[,2] > Ntip(phy[[i]]) ] )
    phy[[i]] = phytools::reroot(phy[[i]], node.number=which(phy[[i]]$tip.label=="dentatum"), position=avg_len)
    
    # our biogeographic analyses need our true outgroup, dentatum,
    # but mega-cc reltime will always prune off the outgroup. we
    # add a faux-outgroup so that dentatum remains after applying
    # reltime via mega-cc.
    s = write.tree(phy[[i]])
    s = str_replace(s, ";", "")
    s = paste0( "(", s, ":0.0001,faux_outgroup:", outgroup_brlen-avg_len, ");" ) 
    phy_newick = read.tree( text=s )

    # prepare stage 1 output
    out_fn = paste0("stage1/oreino_",i,".tre")
    write.tree(phy_newick, file=out_fn)

}
