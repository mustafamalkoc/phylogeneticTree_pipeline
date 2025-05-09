#!/bin/bash

# Get from config/slurm/config.yaml
ACCOUNT=$1
RULE_NAME=$2
PROTEIN=${3:-NA}
PARTITION=$4
QOS=$5
CPUS=$6       
MEM_GB=$7     
JOB_CMD="${@:8}" 


# Set the log directory based on the rule name
if [ "$RULE_NAME" = "download_pfamDB" ] || [ "$RULE_NAME" = "hmmpress" ] || [ "$RULE_NAME" = "make_blastDB" ]; then
  LOG_DIR="logs/data_preparation"
elif [ "$RULE_NAME" = "download_query_protein" ] || [ "$RULE_NAME" = "change_protein_header" ]; then
  LOG_DIR="logs/${PROTEIN}/proteinData"
elif [ "$RULE_NAME" = "psiblast" ] || [ "$RULE_NAME" = "parse_psiblast" ]; then
  LOG_DIR="logs/${PROTEIN}/psiblast"
elif [ "$RULE_NAME" = "mafft_fftns" ] || [ "$RULE_NAME" = "clipkit_fftns" ]; then
  LOG_DIR="logs/${PROTEIN}/msa"
elif [ "$RULE_NAME" = "iqtree" ]; then
  LOG_DIR="logs/${PROTEIN}/iqtree"
elif [ "$RULE_NAME" = "midpoint_rooting" ] || [ "$RULE_NAME" = "add_lineage" ] || [ "$RULE_NAME" = "label_dup_nodes" ]; then
  LOG_DIR="logs/${PROTEIN}/tree_processing"
elif [ "$RULE_NAME" = "hmmscan" ] || [ "$RULE_NAME" = "parse_hmmscan" ]; then
  LOG_DIR="logs/${PROTEIN}/hmmscan"
elif [ "$RULE_NAME" = "make_lineage_csv" ] || [ "$RULE_NAME" = "make_domain_csv" ]; then
  LOG_DIR="logs/${PROTEIN}/generating_CSVs"
elif [ "$RULE_NAME" = "domain_visualization" ] || [ "$RULE_NAME" = "lineage_visualization" ] || [ "$RULE_NAME" = "combine_figures" ]; then
  LOG_DIR="logs/${PROTEIN}/visualizing"
elif [ "$RULE_NAME" = "generate_report" ]; then
  LOG_DIR="logs/report"
else
  echo "Unknown rule: $RULE_NAME" && exit 1
fi

# Create the log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Submit the job with SLURM
sbatch \
  -A $ACCOUNT \
  -p $PARTITION \
  -J ${RULE_NAME}_${PROTEIN} \
  --qos=$QOS \
  --mem=${MEM_GB}G \
  --cpus-per-task=$CPUS \
  -e ${LOG_DIR}/${RULE_NAME}_%A.err \
  -o /dev/null \
  --wrap "$JOB_CMD"