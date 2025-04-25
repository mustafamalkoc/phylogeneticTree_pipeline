rule iqtree:
    input:
        trimmedMSA = rules.clipkit_fftns.output.trimmed_msa,
    output:
        treeFile = "results/{protein}/iqtree/{protein}_fftns.treefile",
        iqtreeLog = "results/{protein}/iqtree/{protein}_fftns.log",
        modelFile = "results/{protein}/iqtree/{protein}_fftns.model.gz"

    log:
        "logs/{protein}/iqtree/iqtree_fftns.log",
    benchmark:
        "logs/{protein}/iqtree/iqtree_fftns.benchmark",
    conda:
        "../envs/iqtree.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          iqtree2 \
            -s {input.trimmedMSA} \
            -st AA \
            -mset LG,JTT,Q.pfam \
            -m MFP \
            -T AUTO \
            -bb 1000 \
            -alrt 1000 \
            -pre "results/{wildcards.protein}/iqtree/{wildcards.protein}_fftns" \
            -seed 12345 &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """
