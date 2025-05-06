import sys
from collections import defaultdict

def get_fasta_dict(fasta_file):
    """Reads a FASTA file and returns a dictionary of sequences keyed by their headers."""
    fasta_dict = {}
    try:
        print(f"Reading FASTA file: {fasta_file}")
        with open(fasta_file, 'r') as f:
            header = None
            for line in f:
                if line.startswith('>'):
                    header = line.split()[0][1:]
                    fasta_dict[header] = ''
                else:
                    fasta_dict[header] += line.strip()
        print(f"Total sequences read from FASTA: {len(fasta_dict)}")
    except IOError:
        print(f"Could not read file {fasta_file}")
        sys.exit(1)
    return fasta_dict

def parse_blastp_out(psiblast_out_file, given_taxid):
    """Parses a BLASTP output file (outfmt 7) to extract the hits."""
    blast_dict = defaultdict(list)
    query_protein_accession = ""
    targetSpecies_prot_list = []
    try:
        with open(psiblast_out_file, 'r') as filein_:
            for line in filein_:
                if line.startswith("# Query: "):
                    query_info = line.split("Query:")[1].strip()
                    query_protein_accession = query_info.split("_")[1]
                    query_protein_name = query_info.split("_")[2]
                    query_tax_id = query_info.split("_")[-1]
                elif not line.startswith("#"):
                    fields = line.strip().split("\t")
                    query_acc_ver = fields[0]
                    subject_acc_ver = fields[1]
                    identity = fields[2]
                    alignment_length = fields[3]
                    mismatches = fields[4]
                    gap_opens = fields[5]
                    q_start = fields[6]
                    q_end = fields[7]
                    s_start = fields[8]
                    s_end = fields[9]
                    evalue = fields[10]
                    bit_score = fields[11]
                    
                    protein_accession, protein_name, tax_id = subject_acc_ver.split("_")[1],subject_acc_ver.split("_")[2],subject_acc_ver.split("_")[-1]
                    if tax_id == given_taxid and subject_acc_ver not in targetSpecies_prot_list:
                        targetSpecies_prot_list.append(subject_acc_ver)

                    if protein_accession not in blast_dict:
                        blast_dict[subject_acc_ver].append((protein_accession, protein_name, tax_id, identity, alignment_length, mismatches, gap_opens, q_start, q_end, s_start, s_end, evalue, bit_score))
                    else:
                        continue
            if targetSpecies_prot_list:
                with open(psiblast_out_file.replace("_blastOutput.txt", "_targetSpecies_prot_list.txt"), 'w') as f:
                    for item in targetSpecies_prot_list:
                        f.write(f"{item}\n")

    except IOError:
        print(f"Error: Could not read file {psiblast_out_file}")
        sys.exit(1)
    return blast_dict, query_protein_accession

def write_to_file(blast_hits, fasta_dict, output_file):
    """Writes the selected sequences to a FASTA file."""
    try:
        print(f"Writing selected sequences to: {output_file}")
        with open(output_file, 'w') as f:
            for header in blast_hits:
                sequence = fasta_dict.get(header, "")
                if sequence:
                    f.write(f">{header}\n{sequence}\n")
                else:
                    print(f"Sequence for {header} not found in FASTA file.")
        print(f"Completed writing sequences to: {output_file}")
    except IOError:
        print(f"Could not write to file {output_file}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python parse_psiblast.py <psiblast_out_file> <fasta_file> <output_file> <given_taxid>")
        sys.exit(1)

    psiblast_out_file = sys.argv[1]
    compiled_fasta_file = sys.argv[2]
    output_file = sys.argv[3]
    given_taxid = sys.argv[4]

    fasta_dict = get_fasta_dict(compiled_fasta_file)
    print(f"Total sequences in FASTA: {len(fasta_dict)}")
    blast_hits, query_protein_accession = parse_blastp_out(psiblast_out_file,given_taxid)
    write_to_file(blast_hits, fasta_dict, output_file)