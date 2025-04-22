# Load the necessary libraries
library(ggtree)
library(tidyverse)
library(RColorBrewer)

# Get command-line arguments
args <- commandArgs(trailingOnly = TRUE)
csv_path <- args[1]
tree_path <- args[2]
output_path <- args[3]

# Read the tree data
tree <- read.tree(tree_path)

# Read the domain data
domains <- read.table(csv_path, sep=",", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)

# Convert leaf_name to rownames
rownames(domains) <- domains$leaf_name
domains$leaf_name <- NULL
colnames(domains) <- sub("\\.$", "", colnames(domains))

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

# # Debugging: Print the number of leaves and the number of rows in domains
# cat("Number of leaves in tree:", length(rotated_tree$tip.label), "\n")
# cat("Number of rows in domains:", nrow(domains), "\n")
# 
# # Debugging: Print the first few tip labels and row names to check alignment
# cat("First few tip labels in tree:", head(rotated_tree$tip.label), "\n")
# cat("First few row names in domains:", head(rownames(domains)), "\n")

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
  theme(legend.position = "right", legend.title = element_text(size = 20), legend.text = element_text(size = 18), legend.key.size = unit(12, 'mm'))+
  labs(fill = "Domain")

# Save the plot
ggsave(output_path, width = 20, height = 30)