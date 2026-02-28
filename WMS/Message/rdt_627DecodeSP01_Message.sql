-- rdt_627DecodeSP01 NYE018 FCR-9890
EXEC rdt.rdtDropMsg 258451, 258500

EXEC rdt.rdtAddMsg 258451, 10, '258451^BARCODE REQUIRED',         'us_english', 627
EXEC rdt.rdtAddMsg 258452, 10, '258452^INVALID FORMAT',           'us_english', 627
EXEC rdt.rdtAddMsg 258453, 10, '258453^SERIALNO NOT FOUND',       'us_english', 627
EXEC rdt.rdtAddMsg 258454, 10, '258454^DECODE FAILURE',           'us_english', 627