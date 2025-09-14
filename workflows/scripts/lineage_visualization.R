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

# Read the lineage data
lineage <- read.table(csv_path, sep=",", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)

# Convert leaf_name to rownames
rownames(lineage) <- lineage$Leaf
lineage$Leaf <- NULL

# Read the FASTA file
fasta_lines <- readLines(fasta_path)
fasta_header <- fasta_lines[1]  # Get the first line (header)

# Extract protein name and accession number from the header
# Header format: >sp_uniprotID_proteinName_speciesName_speciesID
header_parts <- strsplit(sub("^>", "", fasta_header), "_")[[1]]
accession_number <- header_parts[2]  # Extract uniprotID
protein_name <- header_parts[3]      # Extract proteinName

# Define a dictionary for color-rank matches
color_dict <- c(
  "Metazoa" = "#8C6B6B",  # Muted coral
  "Vertebrata" = "#A8A8A8",  # Light gray
  "Mammalia" = "#B86B6B",  # Soft brown with a hint of red
  "Sauria" = "#D4B9A8",  # Warm beige
  "Actinopterygii" = "#6A8EAE",  # Soft, muted blue
  "Arthropoda" = "#a7917b",  # Earthy taupe
  "Viridiplantae" = "#496e4c",  # Deep green
  "Chlorophyta" = "#9CBA9E",  # Soft green
  "Embryophyta" = "#588157",  # Darker green
  "Fungi" = "#F2E3B3",  # Light pastel yellow
  "Others" = "#9AB8C8"   # Soft light blue
)

# Filter out columns with all NA values
lineage <- lineage[, colSums(is.na(lineage)) < nrow(lineage)]

# Define the taxonomic rank groups
taxonomic_groups <- list(
  "Group1" = c("Metazoa", "Viridiplantae", "Fungi", "Others"),
  "Group2" = c("Vertebrata", "Arthropoda", "Chlorophyta", "Embryophyta"),
  "Group3" = c("Mammalia", "Sauria", "Actinopterygii")
)

# Update the taxonomic groups list to remove ranks not present in the CSV file
for (group in names(taxonomic_groups)) {
  taxonomic_groups[[group]] <- taxonomic_groups[[group]][taxonomic_groups[[group]] %in% colnames(lineage)]
}

# Create a new dataframe to store the combined lineage information
combined_lineage <- data.frame(matrix(ncol = length(taxonomic_groups), nrow = nrow(lineage)))
colnames(combined_lineage) <- names(taxonomic_groups)
rownames(combined_lineage) <- rownames(lineage)

# Fill the combined lineage dataframe
for (group in names(taxonomic_groups)) {
  for (rank in taxonomic_groups[[group]]) {
    combined_lineage[group] <- ifelse(lineage[[rank]] != "", rank, combined_lineage[[group]])
  }
}

# Create the color mapping list using the dictionary and present ranks
present_ranks <- unique(unlist(combined_lineage))
present_ranks <- present_ranks[!is.na(present_ranks)]
color_mapping <- color_dict[present_ranks]

# Rotate the tree
rotate_all <- function(tree) {
  for (idx in seq(tree$Nnode + 2, nrow(tree$edge) + 1)) {
    tree <- ape::rotate(tree, idx)
  } 
  tree
}
rotated_tree <- rotate_all(tree)

# Function to extract common species count from duplication node labels
extract_common_species <- function(label) {
  if (is.na(label) || !grepl("^Dup_", label)) {
    return(0)
  }
  # Extract the ratio part (e.g., "2/7" from "Dup_2/7|old_name")
  ratio_match <- regmatches(label, regexpr("\\d+/\\d+", label))
  if (length(ratio_match) > 0) {
    parts <- strsplit(ratio_match, "/")[[1]]
    return(as.numeric(parts[1]))
  }
  return(0)
}

# Function to calculate root clade comparison
calculate_root_comparison <- function(tree) {
  # Find the actual root node - it's the node that appears in edge[,1] but never in edge[,2]
  all_parents <- unique(tree$edge[,1])
  all_children <- unique(tree$edge[,2])
  root_node <- setdiff(all_parents, all_children)[1]
  
  # Find direct children of root
  root_children_indices <- which(tree$edge[,1] == root_node)
  
  if (length(root_children_indices) == 2) {
    # Get the node numbers of the two sister clades
    child1_node <- tree$edge[root_children_indices[1], 2]
    child2_node <- tree$edge[root_children_indices[2], 2]
    
    # Function to get all leaf descendants of a node
    get_descendants <- function(node, tree) {
      if (node <= length(tree$tip.label)) {
        # It's a tip
        return(node)
      } else {
        # It's an internal node, get all descendants
        children_indices <- which(tree$edge[,1] == node)
        descendants <- c()
        for (child_idx in children_indices) {
          child_node <- tree$edge[child_idx, 2]
          descendants <- c(descendants, get_descendants(child_node, tree))
        }
        return(descendants)
      }
    }
    
    # Get leaves for each sister clade
    leaves1_indices <- get_descendants(child1_node, tree)
    leaves2_indices <- get_descendants(child2_node, tree)
    
    leaves1 <- tree$tip.label[leaves1_indices]
    leaves2 <- tree$tip.label[leaves2_indices]
    
    # Extract species IDs from leaf names (last element after splitting by "_")
    species1 <- unique(sapply(leaves1, function(x) tail(strsplit(x, "_")[[1]], 1)))
    species2 <- unique(sapply(leaves2, function(x) tail(strsplit(x, "_")[[1]], 1)))
    
    # Calculate common species
    common_species <- length(intersect(species1, species2))
    min_clade_size <- min(length(species1), length(species2))
    
    return(list(comparison = paste0(common_species, "/", min_clade_size), root_node = root_node))
  }
  return(list(comparison = "", root_node = NULL))
}

# Create the tree plot
p <- ggtree(rotated_tree, ladderize = FALSE, layout = "rectangular")

# Add circles for significant duplication nodes (≥2 common species) and labels
p <- p + 
  geom_point2(
    aes(subset = !is.na(label) & grepl("^Dup_", label) & 
          sapply(label, extract_common_species) > 2),
    color = "#5b0712", size = 4
  ) +
  geom_text2(
    aes(subset = !is.na(label) & grepl("^Dup_", label) & 
          sapply(label, extract_common_species) > 2, 
        label = sub("^(Dup_[^/]*/[^/]*)/.*$", "\\1", label)),  # Keep only up to second slash
    color = "#5b0712", fontface = "bold", size = 4, hjust = -0.1
  )

# Add human protein labels for leaves with taxid 9606
human_labels <- sapply(rotated_tree$tip.label, function(x) {
  parts <- strsplit(x, "_")[[1]]
  if (length(parts) >= 5 && parts[length(parts)] == "9606") {
    return(paste0(parts[2], "_", parts[3]))  # protein_ID_name
  }
  return(NA)
})

# Add root comparison information
root_result <- calculate_root_comparison(rotated_tree)
if (root_result$comparison != "" && !is.null(root_result$root_node)) {
  p <- p + 
    geom_text2(
      aes(subset = node == root_result$root_node, 
          label = paste0("Root: ", root_result$comparison)),
      color = "black", fontface = "bold", size = 5, hjust = -0.1, vjust = -1
    )
}

# Create the heatmap
heatmap <- gheatmap(p, combined_lineage, width = 0.2,
                    offset = 0.01, color = NULL, 
                    colnames_angle = 90, colnames = FALSE, 
                    colnames_offset_y = 0.25, hjust = 0, font.size = 2) +
  scale_fill_manual(values = color_mapping, limits = present_ranks, na.value = "white",
                    breaks = c("Metazoa", "Vertebrata", "Mammalia", "Sauria", "Actinopterygii", 
                               "Arthropoda", "Viridiplantae", "Embryophyta","Chlorophyta", "Fungi", "Others")) +
  theme(legend.position = "right", legend.title = element_text(size = 20), 
        legend.text = element_text(size = 14), legend.key.size = unit(16, 'mm'),
        plot.title = element_text(hjust = 0.5, size = 24, face = "bold")) +
  labs(fill = "Taxonomic Ranks") +
  ggtitle(paste("Lineage Tree of ", protein_name, "_", accession_number, sep = ""))

# Add human protein labels positioned right after the heatmap
# First, get the plot data to determine positioning
plot_data <- heatmap$data
tip_data <- plot_data[plot_data$isTip, ]

# Create a data frame for human protein labels
human_tip_data <- tip_data[!is.na(human_labels[tip_data$label]), ]
if (nrow(human_tip_data) > 0) {
  human_tip_data$human_label <- human_labels[human_tip_data$label]
  
  # Calculate a consistent position based on the heatmap width and offset
  tree_width <- max(plot_data$x[plot_data$isTip], na.rm = TRUE)
  heatmap_start <- tree_width + 0.01
  heatmap_end <- heatmap_start + (tree_width * 0.2)
  label_x_position <- heatmap_end - 0.3 # Fixed offset from heatmap end
  
  heatmap <- heatmap + 
    geom_text(
      data = human_tip_data,
      aes(x = label_x_position, y = y, label = human_label),
      color = "black", fontface = "italic", size = 4, hjust = 0, angle = 0,
      inherit.aes = FALSE
    )
} 

# Save the plot
ggsave(output_path, plot = heatmap, width = 20, height = 30, dpi = 600)