rule psiblast:
    input:
        query_protein = "resources/proteinSeqs/{protein}_newHeader.fasta"
    output:
        txt=report("results/{protein}/psiblast/{protein}_blastOutput.txt", category="{protein}", subcategory="PSI-BLAST Hits"),
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/psiblast/psiblast.log"
    conda:
        "../envs/blast.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          psiblast \
            -query {input.query_protein} \
            -db resources/blastDB/blastDB \
            -out {output.txt} \
            -num_iterations 3 \
            -max_target_seqs 6000 \
            -num_threads {resources.cpus} \
            -outfmt 7 &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1 
        """

rule parse_psiblast:
    input:
        blastOutput = rules.psiblast.output.txt,
        compiled_proteomes = lambda wildcards: config["allProteomesFasta"],
        query_fasta = rules.psiblast.input.query_protein
    output:
        fasta=report("results/{protein}/psiblast/{protein}_blasthits.fasta", category="{protein}", subcategory="PSI-BLAST Hits"),
        targetSpecies_prot_list=report("results/{protein}/psiblast/{protein}_targetSpecies_prot_list.txt", category="{protein}", subcategory="PSI-BLAST Hits"),
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/psiblast/parse_psiblast.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (
        echo "`date -R`: {rule} started..." &&
          python workflows/scripts/parse_psiblast.py \
            {input.blastOutput} \
            {input.compiled_proteomes} \
            {output.fasta} \
            {config[subject_taxid]} &&
          echo "`date -R`: {rule} ended successfully!" ||
        {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """
