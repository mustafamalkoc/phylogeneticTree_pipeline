import sys
import json
import os
import re
from fasta_dict import *

def change_name(fasta_file, output_dir):
    fasta_dict1 = get_fasta_dict(fasta_file)
    
    # Get the first key and taxid
    first_key = next(iter(fasta_dict1))
    try:
        proteinID = first_key.split("|")[1]
    except IndexError:
        print("Error: proteinID not found in the header.")
        return
    

    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Write the new FASTA file
    output_file = os.path.join(output_dir, f"{proteinID}_newHeader.fasta")
    with open(output_file, 'w') as f:
        for a, v in fasta_dict1.items():
            new_a = a.split(" ")[0] + "_" + a.split("OX=")[1].split(" ")[0]
            new_a = re.sub(r'[^\w>]', '_', new_a)
            f.write(">" + new_a + "\n" + v + "\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python change_headers_uniprot.py <input_fasta> <output_dir>")
        sys.exit(1)
    
    fasta_file = sys.argv[1]
    output_dir = sys.argv[2]
    change_name(fasta_file, output_dir)