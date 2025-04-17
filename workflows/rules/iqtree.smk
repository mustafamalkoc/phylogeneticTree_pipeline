rule iqtree:
    input:
        trimmedMSA = rules.trim_msa.output.trimmed_msa,
    output:
        treeFile = "results/{protein}/iqtree/{protein}.treefile",
        iqtreeLog = "results/{protein}/iqtree/{protein}.log",
        modelFile = "results/{protein}/iqtree/{protein}.model.gz",

    log:
        "logs/{protein}/iqtree/{protein}_fftns.log",
    benchmark:
        "logs/{protein}/iqtree/{protein}_fftns.benchmark",
    conda:
        "../envs/iqtree.yaml"
    shell:
        """
        (
          echo "`date -R`: iqtree started..." &&
          iqtree2 \
            -s {input.trimmedMSA} \
            -st AA \
            -mset LG,JTT,Q.pfam \
            -m MFP \
            -T AUTO \
            -bb 1000 \
            -alrt 1000 \
            -pre "results/{wildcards.protein}/iqtree/{wildcards.protein}" \
            -seed 12345 &&
          echo "`date -R`: iqtree ended successfully!"
        ) || (
          echo "`date -R`: iqtree failed..."
          exit 1
        ) > {log} 2>&1
        """
