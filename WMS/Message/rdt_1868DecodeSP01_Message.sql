-- rdt_1868DecodeSP01 NYE018 FCR-9889
-- 258751 - 258800
EXEC rdt.rdtDropMsg 258751, 258800

EXEC rdt.rdtAddMsg 258751, 10, '258751^QRCODE REQUIRED',          'us_english', 1868
EXEC rdt.rdtAddMsg 258752, 10, '258752^INVALID FORMAT',           'us_english', 1868
EXEC rdt.rdtAddMsg 258753, 10, '258753^SERIALNO NOT FOUND',       'us_english', 1868
EXEC rdt.rdtAddMsg 258754, 10, '258754^DECODE FAILURE',           'us_english', 1868
EXEC rdt.rdtAddMsg 258755, 10, '258755^SERIALNO NOT PACKED',      'us_english', 1868
