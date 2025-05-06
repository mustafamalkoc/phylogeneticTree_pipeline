library(ggplot2)
library(cowplot)
library(magick)

# Input arguments
args <- commandArgs(trailingOnly = TRUE)
domain_figure_path <- args[1]
lineage_figure_path <- args[2]
output_path <- args[3]

# Read the images
domain_figure <- ggdraw() + draw_image(domain_figure_path)
lineage_figure <- ggdraw() + draw_image(lineage_figure_path)

# Combine the figures side by side
combined_figure <- plot_grid(lineage_figure, domain_figure, ncol = 2, rel_widths = c(1, 1))

# Save the combined figure
ggsave(output_path, combined_figure, width = 40, height = 30, dpi = 600)