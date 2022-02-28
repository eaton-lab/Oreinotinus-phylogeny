mkdir -p stage1 stage2 stage3
rm stage1/*.*
rm stage2/*.*
rm stage3/*.*

# stage 1: add decoy outgroup taxon
Rscript process_stage1.R

# stage 2: run reltime using mega-cc
python process_stage2.py

# stage 3: sample geological timescale, correct tip labels
Rscript process_stage3.R

# done!
