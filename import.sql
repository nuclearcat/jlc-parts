.mode csv
.import jlc_fixed.csv jlc
UPDATE jlc SET Stock = CAST(Stock AS INTEGER)
