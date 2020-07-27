import csv
import json
import re
import ast
import argparse

parser = argparse.ArgumentParser(description="Take input file & process transcription text")
parser.add_argument("--input_file", required=True,
                    help="Input filename for classification data .csv")

args = parser.parse_args()
reduced_shapedata_file = open(args.input_file)
file_reader = csv.reader(reduced_shapedata_file)
next(file_reader)

rows = []
rows_to_write = []

for row in file_reader:
    rows.append(row)

    s_id = row[0]
    wf_id = row[1]
    reduced_json_string = row[16]

    reduced_data = ast.literal_eval(reduced_json_string)

    for m in reduced_data:
        measurement_str = ''
        for d in m:
            try:
                measurement_str += d['consensus_text'] + "|"
            except:
                continue
        rows_to_write.append((s_id, wf_id, m, measurement_str[:-1]))


with open("text_output.csv", 'w', newline = '') as writefile:
    writer = csv.writer(writefile)
    writer.writerow(["Subject ID", "Workflow ID", "Text reducer output", "Consensus strings"])
    for row in rows_to_write:
        writer.writerow(row)

writefile.close()
