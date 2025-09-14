rule domain_visualization:
    input:
        treeFile = rules.label_dup_nodes.output.tree_midLineageDup,
        domain_csv = rules.make_domain_csv.output.domain_csv,
        fastaFile = "resources/proteinSeqs/{protein}_newHeader.fasta",
    output:
        domain_figure = report("results/{protein}/figures/{protein}_domains_onTree.png", category="{protein}", subcategory="Figures"),
    log:
        "logs/{protein}/visualizing/{protein}_domain_visualization.log"
    resources:
        protein_name = lambda wildcards: wildcards.protein
    conda:
        "../envs/visualize.yaml"
    shell:
        """
        (echo "`date -R`: domain visualization started... " &&
          Rscript workflows/scripts/domain_visualization.R \
            {input.domain_csv} \
            {input.treeFile} \
            {output.domain_figure} \
            {input.fastaFile} && 
          echo "`date -R`: domain visualization ended successfully!" ||
          {{ echo "`date -R`: domain visualization failed..."; exit 1; }}  )  > {log} 2>&1
        """
   
rule lineage_visualization:
    input:
        treeFile = rules.label_dup_nodes.output.tree_midLineageDup,
        lineage_csv = rules.make_lineage_csv.output.lineage_csv,
        fastaFile = "resources/proteinSeqs/{protein}_newHeader.fasta",
    output:
        lineage_figure = report("results/{protein}/figures/{protein}_lineage_onTree.png", category="{protein}", subcategory="Figures"),
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/visualizing/{protein}_lineage_visualization.log"
    conda:
        "../envs/visualize.yaml"
    shell:
        """
        (echo "`date -R`: lineage visualization started..." &&
          Rscript workflows/scripts/lineage_visualization.R \
            {input.lineage_csv} \
            {input.treeFile} \
            {output.lineage_figure} \
            {input.fastaFile} && 
          echo "`date -R`: lineage visualization ended successfully!" ||
          {{ echo "`date -R`: lineage visualization failed..."; exit 1; }}  )  > {log} 2>&1
        """

rule combine_figures:
    input:
        lineageFigure = rules.lineage_visualization.output.lineage_figure,
        domainFigure = rules.domain_visualization.output.domain_figure,
    output:
        combinedFigure = report("results/{protein}/figures/{protein}_combinedTreeFigure.png", category="{protein}", subcategory="Figures"),
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/visualizing/{protein}_combinedFigure_visualization.log"
    conda:
        "../envs/visualize.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          Rscript workflows/scripts/combine_figures.R \
            {input.lineageFigure} \
            {input.domainFigure} \
            {output.combinedFigure} && 
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  > {log} 2>&1
        """