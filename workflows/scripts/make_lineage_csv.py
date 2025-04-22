import os
import sys
import re
import ete3
import csv
from ete3 import Tree
from ete3 import NCBITaxa

ncbi = NCBITaxa()

def get_lineage(tree_file, output_csv):
    t = Tree(tree_file, format=1)
    tax_dict = {}

    ranks = ["Metazoa", "Vertebrata", "Mammalia", "Sauria", "Actinopterygii", "Arthropoda", "Viridiplantae", "Chlorophyta", "Embryophyta", "Fungi", "Others"]

    for leaf in t.iter_leaves():
        tax_id = leaf.name.split("_")[-1]
        lineage = ncbi.get_lineage(tax_id)
        tax_names = [ncbi.get_taxid_translator([id])[id] for id in lineage]
        tax_dict[leaf.name] = tax_names

    with open(output_csv, 'w', newline='') as csvfile:
        fieldNames = ['Leaf'] + ranks
        writer = csv.DictWriter(csvfile, fieldnames=fieldNames)
        writer.writeheader()

        for leaf, lineage in tax_dict.items():
            row = {rank: '' for rank in ranks}
            row['Leaf'] = leaf
            found = False
            for rank in ranks[:-1]:  # Exclude "Others" from this loop
                if rank in lineage:
                    row[rank] = rank
                    found = True
            if not found:
                row["Others"] = "Others"
            writer.writerow(row)

if __name__ == "__main__":
    tree_file = sys.argv[1]
    output_csv = sys.argv[2]
    get_lineage(tree_file, output_csv)