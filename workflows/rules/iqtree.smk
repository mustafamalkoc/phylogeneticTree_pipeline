rule iqtree:
    input:
        trimmedMSA = rules.trim_msa.output.trimmed_msa
    output:
        tree_dir = "results/{protein}/iqtree/{protein}"
    threads: 8
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
            -pre {output.tree_dir} \
            -seed 12345 &&
          echo "`date -R`: iqtree ended successfully!"
        ) || (
          echo "`date -R`: iqtree failed..."
          exit 1
        ) > {log} 2>&1
        """
