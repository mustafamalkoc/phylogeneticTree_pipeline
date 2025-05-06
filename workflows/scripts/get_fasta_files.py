import os
import sys
import urllib.request

def download_fasta(uniprot_ids_file, output_dir):
    """
    Downloads FASTA files for UniProt IDs listed in a text file.

    Args:
        uniprot_ids_file (str): Path to the text file containing UniProt IDs (one per line).
        output_dir (str): Directory where the downloaded FASTA files will be saved.
    """
    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Base URL for downloading FASTA files from UniProt
    base_url = "https://www.uniprot.org/uniprotkb/{}.fasta"

    # Read UniProt IDs from the file
    with open(uniprot_ids_file, "r") as file:
        uniprot_ids = [line.strip() for line in file if line.strip()]

    # Download FASTA files for each UniProt ID
    for uniprot_id in uniprot_ids:
        try:
            # Construct the URL for the current UniProt ID
            fasta_url = base_url.format(uniprot_id)

            # Define the output file path
            output_file = os.path.join(output_dir, f"{uniprot_id}.fasta")

            # Download the FASTA file
            print(f"Downloading {uniprot_id}...")
            urllib.request.urlretrieve(fasta_url, output_file)
            print(f"Saved {uniprot_id} to {output_file}")
        except Exception as e:
            print(f"Failed to download {uniprot_id}: {e}")

if __name__ == "__main__":
    # Check if the correct number of arguments is provided
    if len(sys.argv) != 3:
        print("Usage: python download_fasta.py <uniprot_ids_file> <output_dir>")
        sys.exit(1)

    # Get the input file and output directory from command-line arguments
    uniprot_ids_file = sys.argv[1]
    output_dir = sys.argv[2]

    # Run the download function
    download_fasta(uniprot_ids_file, output_dir)