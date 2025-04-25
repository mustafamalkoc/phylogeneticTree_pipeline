rule midpoint_rooting:
    input:
        treeFile = rules.iqtree.output.treeFile
    output:
        rootedTree = "results/{protein}/iqtree/{protein}_fftns_mid.nwk"
    log:
        "logs/{protein}/tree_processing/midpoint_rooting.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
           python workflows/scripts/midpoint_rooting.py {input.treeFile} &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """

rule add_lineage:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree
    output:
        lineageAddedTree = "results/{protein}/iqtree/{protein}_fftns_mid_lineage.nwk"
    log:
        "logs/{protein}/tree_processing/add_lineage.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
           python workflows/scripts/add_lineage.py {input.treeFile} &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """

rule label_dup_nodes:
    input:
        treeFile = rules.add_lineage.output.lineageAddedTree
    output:
        tree_midLineageDup = "results/{protein}/iqtree/{protein}_fftns_mid_lineage_dup.nwk"
    log:
        "logs/{protein}/tree_processing/label_dup_nodes.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
           python workflows/scripts/label_duplication_nodes.py {input.treeFile} &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """