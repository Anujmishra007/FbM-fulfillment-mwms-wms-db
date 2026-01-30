-- Drop existing messages
EXEC rdt.rdtDropMsg 257751, 257800

EXEC rdt.rdtAddMsg 257751, 10, '257751^UCC REQUIRED',        'us_english', 729, 0, '257751: UCC/Barcode required'
EXEC rdt.rdtAddMsg 257752, 10, '257752^INVALID FORMAT',      'us_english', 729, 0, '257752: Invalid barcode format'
EXEC rdt.rdtAddMsg 257753, 10, '257753^UCC NOT FOUND',       'us_english', 729, 0, '257753: UCC not found in system'
EXEC rdt.rdtAddMsg 257754, 10, '257754^DECODE FAILURE',      'us_english', 729, 0, '257754: Failed to decode QR code'
EXEC rdt.rdtAddMsg 257755, 10, '257755^INVALID SEGMENT',     'us_english', 729, 0, '257755: Invalid QR segment structure'
EXEC rdt.rdtAddMsg 257756, 10, '257756^STORER MISMATCH',     'us_english', 729, 0, '257756: UCC does not match storer'
EXEC rdt.rdtAddMsg 257757, 10, '257757^PARSE ERROR',         'us_english', 729, 0, '257757: Error parsing barcode segments'
