# Phylogenetic Tree Pipeline

A Snakemake workflow for protein homolog discovery, Pfam domain annotation, multiple sequence alignment, maximum-likelihood phylogenetic inference, and integrated tree visualization — starting from one or more UniProt accessions.

![Example combined phylogenetic tree and domain visualization](example_combined_tree_figure.png)

---

## Table of Contents

- [Overview](#overview)
- [Workflow](#workflow)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Output Structure](#output-structure)
- [Resource Management](#resource-management)
- [Tool Versions and Citations](#tool-versions-and-citations)
- [Troubleshooting](#troubleshooting)

---

## Overview

This pipeline automates the construction and visualization of protein family phylogenies. Given a set of UniProt accessions, the workflow retrieves the query sequences, identifies homologs by iterative PSI-BLAST against a user-supplied proteome database, annotates Pfam domains via HMMER, builds a curated multiple sequence alignment with MAFFT E-INS-i, trims it with ClipKIT, selects a substitution model with ModelFinder, and infers a maximum-likelihood tree with IQ-TREE. Post-inference, trees are midpoint-rooted, annotated with NCBI lineage labels, and duplication nodes are flagged. Final outputs are publication-ready figures that overlay lineage and domain architecture onto the phylogeny.

The workflow is parallelized across proteins and scales to HPC environments via a SLURM submission profile. Resource requirements for IQ-TREE (threads and memory) are estimated dynamically from the ModelFinder run, avoiding over- or under-allocation on the cluster.

---

## Workflow

```
UniProt accession(s)
        │
        ▼
 download_query_protein        ← wget from UniProt REST API
        │
        ▼
 change_protein_header         ← standardize FASTA headers for downstream parsing
        │
        ├──────────────────────────────────────────────────────────────┐
        ▼                                                              ▼
 make_blastDB                                                  download_pfamDB
 (makeblastdb on compiled proteome FASTA)                     (Pfam-A.hmm from EBI FTP + md5 check)
        │                                                              │
        ▼                                                              ▼
   psiblast                                                       hmmpress
 (3 iterations, e-value ≤ 1e-6, max 500 hits)                (index Pfam HMM for hmmscan)
        │
        ▼
  parse_psiblast                ← extract hit sequences + target-species protein list
        │
        ├───────────────────────────────────────┐
        ▼                                       ▼
   mafft_einsi                             hmmscan (--cut_ga, --noali)
 (E-INS-i, max 1000 iterations)                │
        │                                       ▼
        ▼                               parse_hmmscan          make_domain_csv
     clipkit                            (domtblout → JSON)            │
 (kpic-smart-gap trimming)                                            │
        │                                                             │
        ▼                                                             │
  modelfinder                                                         │
 (-mset LG,JTT,Q.pfam,WAG)                                           │
        │                                                             │
        ▼                                                             │
 parse_modelfinder_output       ← extract best model, CPUs, memory   │
        │                                                             │
        ▼                                                             │
     iqtree                                                           │
 (ML inference, 1000 UFBoot + 1000 SH-aLRT, fixed seed 12345)        │
        │                                                             │
        ▼                                                             │
 midpoint_rooting                                                     │
        │                                                             │
        ▼                                                             │
   add_lineage                  ← annotate tips with NCBI lineage     │
        │                                                             │
        ▼                                                             │
 label_dup_nodes                ← flag inferred duplication nodes     │
        │                                                             │
        ├─────────────────────────────────────────────────────────────┘
        │                               │
        ▼                               ▼
 lineage_visualization          domain_visualization
 (ggtree + R)                   (ggtree + R)
        │                               │
        └───────────────┬───────────────┘
                        ▼
                combine_figures
           ({protein}_combinedTreeFigure.png)
```

---

## Requirements

### System

- Linux (tested on x86-64; SLURM HPC recommended for multi-protein runs)
- Internet access during setup (UniProt, EBI FTP, conda channels)

### Software

| Tool | Version | Channel |
|---|---|---|
| Snakemake | 9.3.0 | bioconda |
| Mamba | 2.1.0 | conda-forge |
| BLAST+ | 2.16.0 | bioconda |
| HMMER | 3.4 | bioconda |
| MAFFT | 7.526 | conda-forge |
| ClipKIT | 2.4.1 | bioconda |
| IQ-TREE | 3.0.1 | bioconda |
| Python | 3.10 | conda-forge |
| R | 4.3.1 | conda-forge |

All per-rule Conda environments are defined in `workflows/envs/` and are created automatically by Snakemake on the first run. The only manual prerequisite is a working Snakemake installation (see [Installation](#installation)).

### Data

Before running the pipeline, you must supply a compiled proteome FASTA file. This is the sequence database against which PSI-BLAST will search for homologs. Place the file at the path specified by `compiledProteomesFasta` in `config/config.yaml` (default: `resources/proteomes/compiled_subset.updated.faa`).

FASTA headers must follow the format:

```
>sp_<UniProtAccession>_<ProteinName>_<SpeciesTag>_<NCBI_TaxID>
```

For example: `>sp_P49842_STK19_HUMAN_9606`. This format is required for PSI-BLAST parsing and lineage annotation to work correctly.

---

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd phylogeneticTree_pipeline
```

### 2. Create the Snakemake environment

```bash
conda env create -f workflows/envs/snakemake.yaml
conda activate snakemake
```

### 3. Place your compiled proteome FASTA

```bash
mkdir -p resources/proteomes
cp /path/to/your/proteomes.faa resources/proteomes/compiled_subset.updated.faa
```

All other databases (BLAST DB, Pfam HMM) are built automatically by the pipeline.

---

## Configuration

### Primary config — `config/config.yaml`

```yaml
proteins:
  - P49842
  - Q8TAQ2

compiledProteomesFasta: "resources/proteomes/compiled_subset.updated.faa"

pfamDB_URL: "http://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam38.0/Pfam-A.hmm.gz"
md5_URL:    "http://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam38.0/md5_checksums"

subject_taxid: "9606"   # NCBI taxonomy ID of your focal species
```

| Parameter | Description |
|---|---|
| `proteins` | List of UniProt accessions to analyze. Each accession is processed independently. |
| `compiledProteomesFasta` | Path to the local proteome FASTA used to build the BLAST database. |
| `pfamDB_URL` | Direct URL to the Pfam-A HMM file. Update to change Pfam release. |
| `md5_URL` | Corresponding MD5 checksum file. Used to validate the Pfam download. |
| `subject_taxid` | NCBI taxonomy ID of the organism of primary interest. Hits from this taxon are tracked separately (e.g., human proteins: `9606`). |

### SLURM profile — `config/slurm/config.yaml`

The SLURM profile controls cluster submission and default resource allocations. Before running on a cluster, update the following fields to match your HPC environment:

```yaml
default-resources:
  account: <your-account>
  partition: <your-partition>
  qos: <your-qos>
```

Rule-specific resource overrides (CPUs, memory) are defined under `set-resources`. Note that IQ-TREE CPU and memory are set dynamically at runtime from ModelFinder output — do not override them here unless you want to force fixed values.

---

## Usage

### Dry run (recommended before any real run)

```bash
snakemake --dry-run --profile config/slurm
```

This prints the full execution plan and resolves all dependencies without submitting any jobs. Review the output to ensure all inputs are present and the DAG looks correct.

### Run on a SLURM cluster

```bash
snakemake --profile config/slurm
```

Jobs are submitted via `workflows/scripts/submit_slurm.sh`. The profile enforces a maximum of 100 concurrent jobs, a 60-second latency wait for NFS-mounted filesystems, and automatic resubmission of incomplete jobs.

### Local run (small datasets / testing)

```bash
snakemake --use-conda --cores <N>
```

### Re-running failed jobs

Snakemake marks interrupted jobs as incomplete. To resume:

```bash
snakemake --profile config/slurm --rerun-incomplete
```

---

## Output Structure

All results are written to `results/{protein}/`. Logs for every rule are written to `logs/{protein}/`.

```
results/{protein}/
├── psiblast/
│   ├── {protein}_blastOutput.txt              # Raw PSI-BLAST output (outfmt 7)
│   ├── {protein}_blasthits.fasta              # FASTA of all homologous sequences
│   └── {protein}_targetSpecies_prot_list.txt  # Hits restricted to subject_taxid
│
├── hmmscan/
│   ├── {protein}_domtblout.txt                # Raw hmmscan domain table
│   ├── {protein}_parsed_domtbl.json           # Parsed domain hits (JSON)
│   └── {protein}_domains.csv                  # Domain annotations keyed to tree tips
│
├── msa/
│   ├── {protein}_mafft_einsi.fasta            # Raw MAFFT E-INS-i alignment
│   └── {protein}_trimmed_clipkit_einsi.fasta  # ClipKIT-trimmed alignment (kpic-smart-gap)
│
├── modelfinder/
│   ├── {protein}_modelfinder.log              # ModelFinder IQ-TREE log
│   └── {protein}_resources.txt               # Best model, estimated CPUs and memory
│
├── iqtree/
│   ├── {protein}_mafft_einsi.treefile         # Raw ML tree (Newick, with UFBoot/SH-aLRT support)
│   ├── {protein}_mafft_einsi_mid.nwk          # Midpoint-rooted tree
│   ├── {protein}_mafft_einsi_mid_lineage.nwk  # Lineage-annotated tree
│   └── {protein}_mafft_einsi_mid_lineage_dup.nwk  # Lineage + duplication node labels
│
├── lineage/
│   └── {protein}_lineage.csv                  # Per-tip lineage metadata for visualization
│
└── figures/
    ├── {protein}_domains_onTree.png            # Pfam domain architecture overlaid on phylogeny
    ├── {protein}_lineage_onTree.png            # Taxonomic lineage overlaid on phylogeny
    └── {protein}_combinedTreeFigure.png        # Final combined figure (primary deliverable)
```

The combined figure (`{protein}_combinedTreeFigure.png`) is the primary output for biological interpretation. It places lineage context and inferred domain architecture side-by-side on the same tree topology.

---

## Resource Management

IQ-TREE thread and memory requirements scale with alignment size and are not known until ModelFinder has run. This pipeline uses a two-step dynamic resource allocation strategy:

1. **`modelfinder`** runs IQ-TREE in model-selection mode (`-m MF`) with automatic thread detection (`-T AUTO`).
2. **`parse_modelfinder_output`** parses the ModelFinder log to extract the best-fit model, recommended thread count, and estimated RAM, and writes these to a `{protein}_resources.txt` file.
3. **`iqtree`** reads `{protein}_resources.txt` at rule evaluation time via Snakemake lambda resource functions, submitting the job with the correct CPU and memory allocation.

Fallback values (6 CPUs, 20 GB RAM, model `LG+F+R4`) are used if parsing fails. The model search space is restricted to `LG`, `JTT`, `Q.pfam`, and `WAG` to reduce ModelFinder runtime while covering the most common protein substitution models.


## Troubleshooting

**`compiledProteomesFasta` not found**
Confirm that the file exists at the exact path in `config/config.yaml`. The pipeline does not download or generate this file.

**PSI-BLAST returns no hits or very few sequences**
Check that FASTA headers in your proteome file conform to the `sp_<Accession>_<Name>_<Species>_<TaxID>` format. Malformed headers will cause `parse_psiblast.py` to silently skip sequences. Also verify that `subject_taxid` is correct for your target organism.

**`hmmscan` fails or produces an empty domtblout**
Delete any partial files under `resources/pfamDB/` and re-run. The `download_pfamDB` rule validates the download via MD5 checksum; a corrupted or incomplete download will cause `hmmpress` to fail.

**IQ-TREE job is killed on the cluster (OOM or timeout)**
The dynamic resource estimation from ModelFinder is a lower-bound estimate. If the IQ-TREE job is killed, inspect `results/{protein}/modelfinder/{protein}_resources.txt`, manually increase `ESTIMATED_MEMORY_GB`, and re-run with `--rerun-incomplete`.

**Conda environment creation fails**
Configure strict channel priority and ensure `conda-forge` and `bioconda` are in your channel list:
```bash
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
```

**Snakemake reports a locked working directory**
A previous run may not have released the lock. Remove it with:
```bash
snakemake --unlock --profile config/slurm
```

---

## License

See [LICENSE](LICENSE) for details.