rule download_query_protein:
    output:
        "resources/proteinSeqs/{protein}_raw.fasta"
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/proteinData/{protein}_download_query_protein.log"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          mkdir -p resources/proteinSeqs &&
          wget "https://www.uniprot.org/uniprotkb/{resources.protein_name}.fasta" -O {output} &&
          echo "`date -R`: {rule} ended successfully!" || 
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """

rule change_protein_header:
    input:
        old_fasta = rules.download_query_protein.output,
    output:
        "resources/proteinSeqs/{protein}_newHeader.fasta"
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/proteinData/{protein}_change_protein_header.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          python workflows/scripts/change_protein_headers.py {input.old_fasta} "resources/proteinSeqs/" &&
          rm -f {input.old_fasta} &&
          echo "`date -R`: {rule} ended successfully!" || 
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """

rule make_blastDB:
    input: 
        allProteomesFasta = config["allProteomesFasta"]
    output:
        blastdb_pdb = "resources/blastDB/blastDB.pdb",
    log:
        "logs/data_preparation/make_blastDB.log"
    conda:
        "../envs/blast.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          mkdir -p resources/blastDB &&
          makeblastdb \
            -in {input.allProteomesFasta} \
            -out resources/blastDB/blastDB \
            -dbtype prot \
            -parse_seqids &&
          echo "`date -R`: {rule} ended successfully!" || 
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """
rule download_pfamDB:
    output:
        pfamDB = "resources/pfamDB/Pfam-A.hmm"
    log:
        "logs/data_preparation/download_pfamDB.log"
    conda:
        "../envs/hmmer.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          mkdir -p resources/pfamDB &&
          wget {config[pfamDB_URL]} -O resources/pfamDB/Pfam-A.hmm.gz &&
          wget {config[md5_URL]} -O resources/pfamDB/md5_checksums &&
          grep "Pfam-A.hmm.gz" resources/pfamDB/md5_checksums > resources/pfamDB/Pfam-A.hmm.gz.md5 &&
          cd resources/pfamDB &&
          md5sum -c Pfam-A.hmm.gz.md5 &&
          gunzip -f Pfam-A.hmm.gz &&
          rm -f Pfam-A.hmm.gz md5_checksums Pfam-A.hmm.gz.md5 &&
          echo "`date -R`: {rule} ended successfully!" || 
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """

rule hmmpress:
    input:
        pfamDB = rules.download_pfamDB.output.pfamDB
    output:
        pfamDB_1 = "resources/pfamDB/Pfam-A.hmm.h3f",
        pfamDB_2 = "resources/pfamDB/Pfam-A.hmm.h3i",
        pfamDB_3 = "resources/pfamDB/Pfam-A.hmm.h3m",
        pfamDB_4 = "resources/pfamDB/Pfam-A.hmm.h3p",
    log:
        "logs/data_preparation/hmmpress.log"
    conda:
        "../envs/hmmer.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          hmmpress {input.pfamDB} &&
          echo "`date -R`: {rule} ended successfully!" || 
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """