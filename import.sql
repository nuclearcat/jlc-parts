.mode csv
.import jlc.csv jlc
UPDATE jlc SET Stock = CAST(Stock AS INTEGER)
