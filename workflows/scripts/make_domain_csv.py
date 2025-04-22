import os
import sys
import csv
import ete3
from ete3 import Tree
import json
from fasta_dict import *



def make_domain_file(tree_path, domtbl_path, output_path):
    t = Tree(tree_path, format = 1)
    fileObject = open(domtbl_path, "r")
    jsonContent = fileObject.read()
    eu_domain_dict = json.loads(jsonContent)

    all_domains = []
    domain_dict = {}
    domain_dict.update(eu_domain_dict)
    domain_count = {}
    for k in domain_dict.keys():
        for domain in domain_dict[k]:
            if not domain in domain_count.keys():
                domain_count[domain] = 1
            else:
                domain_count[domain] += 1
    #print(domain_count)
    for seq in domain_dict.keys():
        for domain in domain_dict[seq].keys():
            if 10 <= domain_count.get(domain, 0):
                if not domain in all_domains:
                    all_domains.append(domain)

                
    domain_architecture = {}
    for leaf in t:
        domain_architecture[leaf.name] = []
        for domain in all_domains:
            try:
                if domain in domain_dict[leaf.name].keys():
                    domain_architecture[leaf.name].append(domain)
                else:
                    domain_architecture[leaf.name].append("")
            except:
                domain_architecture[leaf.name].append("")

    #print(domain_architecture)
    with open(output_path,'w') as f:
        writer = csv.writer(f)
        header = ["leaf_name"]
        header = header + all_domains
        writer.writerow(header)
        for leaf in t:
            data = []
            data.append(leaf.name)
            data = data + domain_architecture[leaf.name]
            writer.writerow(data)

    f.close()

if __name__ == "__main__":
    tree_path = sys.argv[1]
    domtbl_path = sys.argv[2]
    output_file = sys.argv[3]
    make_domain_file(tree_path, domtbl_path, output_file)