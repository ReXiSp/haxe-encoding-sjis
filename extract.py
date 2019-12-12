import csv

with open('table.csv', 'r') as in_f:
    reader = csv.reader(in_f)
    header = next(reader)
    representative = ""
    for row in reader:
        if row[1].strip() == "":
            continue
        print("    w31j2uni[{}] = {};".format(row[0], row[1]))
        print("    uni2w31j[{}] = {};".format(row[1], row[0]))

