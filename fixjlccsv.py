#!/usr/bin/env python3
import csv
try:
  fixedcsvfile = open('jlc_fixed.csv', 'w', newline='')
except IOError:
    print("Could not write file")

with open('jlc.csv', encoding= 'unicode_escape') as csvfile:
  csvreader = csv.reader(csvfile, delimiter=',', quotechar='"')
  fixed_csv = csv.writer(fixedcsvfile);
  linenum = 0
  for row in csvreader:
        linenum += 1
        if (linenum == 1):
          fixed_csv.writerow(row)
          continue

        row[8]=row[8].replace("\xa1\xc0",'±')
        row[8]=row[8].replace("\xa1\xe6",'°C')
        row[8]=row[8].replace("\xa6\xb8",'Ω')
        pricelist = row[10].split(',')
        temparr = {}
        # Create array 'price':'quantity' to sort prices and take for 1pc
        for priceentry in pricelist:
          quantity = priceentry.split('-')
          price = priceentry.split(':')
          if (len(price) > 1):
            temparr[price[1]] = quantity[0]

        if (len(temparr) > 1):
          sortedarr = sorted(temparr.items(), key=lambda x: int(x[1]))
          row[10] = sortedarr[0][0]
          #print(sortedarr[0][0])
        else:
          # Unknown price
          row[10] = 99999

        fixed_csv.writerow(row)
