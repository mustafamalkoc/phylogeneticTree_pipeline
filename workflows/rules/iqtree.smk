def get_dynamic_cpus(resource_file):
    """Read the estimated CPU count from the resource file."""
    try:
        with open(resource_file, 'r') as f:
            for line in f:
                if line.startswith('ESTIMATED_CPUS='):
                    return int(line.split('=')[1].strip())
    except (FileNotFoundError, ValueError):
        pass
    return 6  # Default fallback

def get_dynamic_memory(resource_file):
    """Read the estimated memory requirement from the resource file."""
    try:
        with open(resource_file, 'r') as f:
            for line in f:
                if line.startswith('ESTIMATED_MEMORY_GB='):
                    return int(line.split('=')[1].strip())
    except (FileNotFoundError, ValueError):
        pass
    return 20  # Default fallback

rule modelfinder:
    input:
        trimmedMSA = rules.clipkit.output.trimmed_msa,
    output:
        log_file = "results/{protein}/modelfinder/{protein}_modelfinder.log",
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/modelfinder/modelfinder.log",
    benchmark:
        "logs/{protein}/modelfinder/modelfinder.benchmark",
    conda:
        "../envs/iqtree.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          iqtree \
            -s {input.trimmedMSA} \
            -st AA \
            -mset LG,JTT,Q.pfam,WAG \
            -m MF \
            -T AUTO \
            --prefix "results/{wildcards.protein}/modelfinder/{wildcards.protein}_modelfinder" \
            --seed 12345 &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """

rule parse_modelfinder_output:
    input:
        modelfinderLog = rules.modelfinder.output.log_file
    output:
        resource_file = "results/{protein}/modelfinder/{protein}_resources.txt"
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/modelfinder/parse_modelfinder.log",
    conda:
        "../envs/snakemake.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          python workflows/scripts/parseModelfinderOutput.py \
            {input.modelfinderLog} \
            {output.resource_file} &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """

rule iqtree:
    input:
        trimmedMSA = rules.clipkit.output.trimmed_msa,
        resource_file = rules.parse_modelfinder_output.output.resource_file
    output:
        treeFile = "results/{protein}/iqtree/{protein}_mafft_linsi.treefile",
        iqtreeLog = "results/{protein}/iqtree/{protein}_mafft_linsi.log",
    resources:
        protein_name = lambda wildcards: wildcards.protein,
        cpus = lambda wildcards, input: get_dynamic_cpus(input.resource_file),
        mem_gb = lambda wildcards, input: get_dynamic_memory(input.resource_file)
    log:
        "logs/{protein}/iqtree/iqtree_mafft_linsi.log",
    benchmark:
        "logs/{protein}/iqtree/iqtree_mafft_linsi.benchmark",
    conda:
        "../envs/iqtree.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          # Read the best model from the modelfinder output
          BEST_MODEL=$(python workflows/scripts/parseModelfinderOutput.py \
                       {input.resource_file} --get-model) &&
          iqtree \
            -s {input.trimmedMSA} \
            -st AA \
            -m "$BEST_MODEL" \
            -T {resources.cpus} \
            -bb 1000 \
            -alrt 1000 \
            -pre "results/{wildcards.protein}/iqtree/{wildcards.protein}_mafft_linsi" \
            -seed 12345 &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """
