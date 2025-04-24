rule domain_visualization:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree,
        domain_csv = rules.make_domain_csv.output.domain_csv,
    output:
        domain_figure = "results/{protein}/figures/{protein}_domains_onTree.pdf",
    log:
        "logs/{protein}/visualizing/{protein}_domain_visualization.log"
    conda:
        "../envs/visualize.yaml"
    shell:
        """
        (echo "`date -R`: domain visualization started..." &&
          Rscript workflows/scripts/domain_visualization.R \
            {input.domain_csv} \
            {input.treeFile} \
            {output.domain_figure} && 
          echo "`date -R`: domain visualization ended successfully!" ||
          {{ echo "`date -R`: domain visualization failed..."; exit 1; }}  )  > {log} 2>&1
        """
   
rule lineage_visualization:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree,
        lineage_csv = rules.make_lineage_csv.output.lineage_csv,
    output:
        lineage_figure = "results/{protein}/figures/{protein}_lineage_onTree.pdf",
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
            {output.lineage_figure} && 
          echo "`date -R`: lineage visualization ended successfully!" ||
          {{ echo "`date -R`: lineage visualization failed..."; exit 1; }}  )  > {log} 2>&1
        """