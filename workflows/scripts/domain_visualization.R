# Load the necessary libraries
library(ggtree)
library(tidyverse)
library(RColorBrewer)
library(ape)

# Get command-line arguments
args <- commandArgs(trailingOnly = TRUE)
csv_path <- args[1]
tree_path <- args[2]
output_path <- args[3]
fasta_path <- args[4]

# Read the tree data
tree <- read.tree(tree_path)

# Read the domain data
domains <- read.table(csv_path, sep=",", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)

# Convert leaf_name to rownames
rownames(domains) <- domains$leaf_name
domains$leaf_name <- NULL
colnames(domains) <- sub("\\.$", "", colnames(domains))

# Read the FASTA file
fasta_lines <- readLines(fasta_path)
fasta_header <- fasta_lines[1]  # Get the first line (header)

# Extract protein name and accession number from the header
# Header format: >sp_uniprotID_proteinName_speciesName_speciesID
header_parts <- strsplit(sub("^>", "", fasta_header), "_")[[1]]
accession_number <- header_parts[2]  # Extract uniprotID
protein_name <- header_parts[3]      # Extract proteinName

# Check the number of columns in domains
if (ncol(domains) > 1) {
  # Calculate the frequency of each domain
  domain_counts <- apply(domains, 2, function(x) sum(x != ""))
  
  # Reorder the columns based on the frequency
  domains <- domains[, order(domain_counts, decreasing = TRUE)]
}

# Generate a color palette based on the number of domains
num_domains <- ncol(domains)
colors <- colorRampPalette(brewer.pal(9, "Set3"))(num_domains)

# Create a named vector for colors
color_mapping <- setNames(colors, colnames(domains))

rotate_all <- function(tree) {
  for (idx in seq(tree$Nnode + 2, nrow(tree$edge) + 1)) {
    tree <- ape::rotate(tree, idx)
  } 
  tree
}
rotated_tree <- rotate_all(tree)

# Ensure the row names of domains match the tip labels of the tree
if (!all(rotated_tree$tip.label %in% rownames(domains))) {
  stop("Mismatch between tree tip labels and domain row names.")
}

# Create the tree plot
p <- ggtree(rotated_tree, ladderize = FALSE, layout = "rectangular")

# Create the heatmap
heatmap <- gheatmap(p, domains, width = 0.4, offset = 0.01, color = NULL,
                    colnames_angle = 90, colnames = FALSE, colnames_offset_y = 0.25, hjust = 0, font.size = 2) +
  scale_fill_manual(values = color_mapping, limits = colnames(domains), na.value = "white") +
  theme(legend.position = "right", legend.title = element_text(size = 20), 
        legend.text = element_text(size = 18), legend.key.size = unit(12, 'mm'),
        plot.title = element_text(hjust = 0.5, size = 24, face = "bold")) +
  labs(fill = "Domains") +
  ggtitle(paste("Domain Tree of ", protein_name, "_", accession_number, sep = "")) 

# Save the plot
ggsave(output_path, plot = heatmap, width = 20, height = 30, dpi = 600)