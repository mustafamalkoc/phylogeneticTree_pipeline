rule midpoint_rooting:
    input:
        treeFile = rules.iqtree.output.treeFile,
    output:
        rootedTree = "results/{protein}/iqtree/{protein}_mid.nwk",
    log:
        "logs/{protein}/iqtree/{protein}_tree-processing.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (
          echo "`date -R`: midpoint rooting started..." &&
           python workflows/scripts/midpoint_rooting.py {input.treeFile} &&
          echo "`date -R`: midpoint rooting ended successfully!"
        ) || (
          echo "`date -R`: midpoint rooting failed..."
          exit 1
        ) > {log} 2>&1
        """

rule add_lineage:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree,
    output:
        lineageAddedTree = "results/{protein}/iqtree/{protein}_mid_lineage.nwk",
    log:
        "logs/{protein}/iqtree/{protein}_tree-processing.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (
          echo "`date -R`: adding lineage started..." &&
           python workflows/scripts/add_lineage.py {input.treeFile} &&
          echo "`date -R`: adding lineage ended successfully!"
        ) || (
          echo "`date -R`: adding lineage failed..."
          exit 1
        ) > {log} 2>&1
        """

rule label_dup_nodes:
    input:
        treeFile = rules.add_lineage.output.lineageAddedTree,
    output:
        tree_midLineageDup = "results/{protein}/iqtree/{protein}_mid_lineage_dup.nwk",
    log:
        "logs/{protein}/iqtree/{protein}_tree-processing.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (
          echo "`date -R`: labelling duplication nodes started..." &&
           python workflows/scripts/label_duplication_nodes.py {input.treeFile} &&
          echo "`date -R`: labelling duplication nodes ended successfully!"
        ) || (
          echo "`date -R`: labelling duplication nodes failed..."
          exit 1
        ) > {log} 2>&1
        """