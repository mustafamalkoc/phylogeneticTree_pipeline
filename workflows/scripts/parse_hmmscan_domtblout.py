import os
import sys
import subprocess
import logging
import math
import json


def parse_hmmscan_file(hmmscan_against_profiles_files_path):
    acc_no_to_result_dict = {}
    start_parsing = False

    with open(hmmscan_against_profiles_files_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            start_parsing = True
            words = line.split()
            acc_no = words[3]
            score = float(words[7])
            align_start = int(words[17])
            align_stop = int(words[18])
            e_value = float(words[6])
            align_length = align_stop - align_start
            domain = words[0]
            
            if acc_no not in acc_no_to_result_dict:
                acc_no_to_result_dict[acc_no] = {domain: {'e_value': e_value, 'score': score, 'align_length': align_length, 'align_start': align_start, 'align_stop': align_stop}}
            else:
                acc_no_to_result_dict[acc_no].update({domain: {'e_value': e_value, 'score': score, 'align_length': align_length, 'align_start': align_start, 'align_stop': align_stop}})

    return acc_no_to_result_dict


if __name__ == '__main__':
    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]

    acc_no_to_result_dict = parse_hmmscan_file(input_file_path)
    with open(output_file_path, 'w') as fp:
        json.dump(acc_no_to_result_dict, fp)