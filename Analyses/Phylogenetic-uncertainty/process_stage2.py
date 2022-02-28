import sys
import os

n_phy = 100

for i in range(n_phy):
    in_fn1  = 'stage1/oreino_' + str(i+1) + '.tre'
    out_fn1 = 'stage2/oreino_reltime_' + str(i+1) + '.tre'
    cmd     = 'megacc -a reltime_blens.mao -t ' + in_fn1 + ' -g outgroup.txt -o ' + out_fn1
    os.system(cmd)

    idx = i + 1
    in_fn2  = 'stage2/oreino_reltime_'+str(idx)+'_nexus.tre'
    out_fn2 = 'stage2/oreino_reltime_'+str(idx)+'_nexus_nooutgroup.tre'
    f_in = open(in_fn2, 'r')
    s_out = ''
    for line in f_in:
        if 'Dimensions ntax=42;' in line:
            s_out += '\tDimensions ntax=41;\n'
        elif 'faux_outgroup' in line:
            s_out += ''
        elif '41 dentatum,' in line:
            s_out += '\t\t41 dentatum\n'
        else:
            s_out += line
    f_in.close()

    f_out = open(in_fn2, 'w')
    f_out.write(s_out)
    f_out.close()
