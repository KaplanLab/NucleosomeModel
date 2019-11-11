## Nucleosome model from Kaplan et al. Nature 2009

__Full paper details:__

The DNA-encoded nucleosome organization of a eukaryotic genome.  
Kaplan N*, Moore IK*, Fondufe-Mittendorf Y, Gossett AJ, Tillo D, Field Y, LeProust EM, Hughes TR, Lieb JD, Widom J, Segal E.  
Nature, 2009 458(7236):362-6. doi: 10.1038/nature07667  

__Description:__

The probabilistic model was trained on MNase-Seq data measure on chicken histones reconstituted onto yeast genomic DNA at sub-physiological concentration (4:10 histone to DNA).

The code in this repository to the code previously hosted on the Segal Lab website: https://genie.weizmann.ac.il/pubs/nucleosomes08/index.html

Data is provided at GEO GSE13622 (https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE13622) and https://genie.weizmann.ac.il/pubs/nucleosomes08/index.html

__Running details:__

1. Extract e.g. `tar -xvzf ver3_64bit_nucleosome_prediction.tar.gz`
2. Run `make install` in the created directory. 
3. To test an example, run:
 
`perl nucleosome_prediction.pl -t title -s input.fa -c 0.03 -temp 1 -tab -p out`
 
These are the temperature and concentration parameters used in the paper to match in-vitro reconstituted nucleosome organization (i.e. low concentration; depending on aim, a higher concentration value may be appropriate). This should create a file `out.tab` containing the output.

__Troubleshooting:__

If the test output file is empty, it is usually due to its dependence on a linked library which is now old and thus missing from some libraries. To diagnose which library is missing on your system,
 
Use “perl nucleosome_prediction.pl –help” for more options.

__Additional usage notes:__

1. The code can only deal with nucleotides that are ACGT. For other nucleotides (e.g. N), one possible solution is to replace these with C, as it is relatively neutral.

