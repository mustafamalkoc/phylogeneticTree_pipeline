# DNA Repair Protein Workflow Pipeline

This repository contains a Snakemake-based pipeline for automating the construction of phylogenetic trees from DNA repair proteins, along with associated analyses such as HMM domain scanning and lineage determination.

## Overview

1. **PSI-BLAST Search**  
   - Input: Query protein FASTA (e.g., `initial_data/query_proteins.fasta`)  
   - Output: Raw BLAST results (`results/{protein_name}/psiblast/{protein_name}_blasthits.txt`)  

2. **Parse BLAST Output**  
   - Converts raw BLAST results into a FASTA file (`results/blast_hits.fasta`).  

3. **hmmscan**  
   - Runs hmmscan against a local PFAM database.  
   - Output: Parsed results in CSV (`results/hmmscan/hmmscan.csv`). 

4. **Multiple Sequence Alignment (MSA)**  
   - Uses MAFFT with the `-fftns` option (and optionally `einsi` if needed).  
   - Output: Aligned sequences (`results/msas/alignment.fasta`).  

5. **Trimming**  
   - Uses ClipKit to remove poorly aligned regions.  
   - Output: Trimmed alignment (`results/msas/trimmed_alignment.fasta`).  

6. **Phylogenetic Tree Construction**  
   - Uses IQ-TREE to build a maximum-likelihood tree.  
   - Output: Main tree file (e.g., `results/trees/iqtree_result.tree`).  
   - Midpoint rooting step produces `results/trees/midpoint_rooted.tree`.   

7. **Lineage Search**  
   - Determines the taxonomic lineage for each sequence.  
   - Output: `results/lineage/lineage.csv`.  

8. **Generate Final Figures**  
   - Combines `midpoint_rooted.tree`, `hmmscan.csv`, and `lineage.csv` to produce lineage/domain figures.

## Conditional MSA Rebuild

- If the initial tree is of poor quality, the pipeline will allow rebuilding the MSA with MAFFT’s `einsi` option, then re-running from trimming onward.

## Requirements

- **Snakemake** (≥6.0)  
- **Python** (≥3.7)  
- **MAFFT**  
- **ClipKit**  
- **IQ-TREE**  
- **BLAST+**  
- **hmmer**  
- **PFAM database** (locally installed, indexed for hmmscan)  
- **R** or **Python** (whichever is used for final figure generation)  

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/dna-repair-pipeline.git
   cd dna-repair-pipeline
