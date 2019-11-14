## Nucleosome model from Kaplan et al. Nature 2009

__Full paper details:__

_The DNA-encoded nucleosome organization of a eukaryotic genome_  
Kaplan N*, Moore IK*, Fondufe-Mittendorf Y, Gossett AJ, Tillo D, Field Y, LeProust EM, Hughes TR, Lieb JD, Widom J, Segal E.  
Nature, 2009 458(7236):362-6. doi: 10.1038/nature07667

Major contributions to this code by Yair Field, Yaniv Lubling, Eran Segal

__Description:__

The probabilistic model was trained on MNase-Seq data measure on chicken histones reconstituted onto yeast genomic DNA at sub-physiological concentration (4:10 histone to DNA).

The code in this repository to the code previously hosted on the Segal Lab website: https://genie.weizmann.ac.il/pubs/nucleosomes08/index.html

Data is provided at GEO GSE13622 (https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE13622) and https://genie.weizmann.ac.il/pubs/nucleosomes08/index.html

__Running details:__

This is the linux 64 bit version.

1. Run `make install`. 
2. To test an example, run:
 
`perl nucleosome_prediction.pl -t title -s input.fa -c 0.03 -temp 1 -tab -p out`
 
These are the temperature and concentration parameters used in the paper to match in-vitro reconstituted nucleosome organization (i.e. low concentration; depending on aim, a higher concentration value may be appropriate). This should create a file `out.tab` containing the output.

__Troubleshooting:__

If the test output file is empty, it is usually due to its dependence on a linked library which is now old and thus missing from some libraries. To diagnose which library is missing on your system:

1. Add the `XXX/lib/` directory to your `LD_LIBRARY_PATH` environment variable, where XXX is the folder where you installed the software (since some of the needed libraries are located there).
2. Run `XXX/bin/map_learn_static`. You will get an error message showing you which library is missing.
3. Download the missing library.

For example, if you use Centos 7, you should get an error message that you are missing `libstdc++.so.5`, and to get it you would use `yum install compat-libstdc++-33.x86_64`.

__Additional usage notes:__

1. Use `perl nucleosome_prediction.pl –help` for more options.
2. The code can only deal with nucleotides that are ACGT. For other nucleotides (e.g. N), one possible solution is to replace these with C, as it is relatively neutral. Still keep in mind that predictions made on such regions may be unreliable.
3. It is important to remember that concentration effects are included in the model, and these can create strong long-range positioning near boundaries. This means that it is better to make predictions on entire chromosomes and then extract specific regions of interest, or alternatively add >5 kb of flanking sequence to each region of interest in order to buffer any boundary effects.

__Contact:__

For any questions please contact Noam Kaplan noam.kaplan@technion.ac.il



