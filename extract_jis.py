import csv

with open('jis2004.csv', 'r') as in_f:
    reader = csv.reader(in_f)
    header = next(reader)
    representative = ""
    for row in reader:
        if row[1].strip() == "":
            continue
        print("        table[{}] = true;".format(row[1]))

