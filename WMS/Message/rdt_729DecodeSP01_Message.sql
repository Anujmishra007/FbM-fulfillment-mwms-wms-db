-- Drop existing messages
EXEC rdt.rdtDropMsg 257751, 257800

EXEC rdt.rdtAddMsg 257751, 10, '257751^UCC REQUIRED',        'us_english', 729, 0, '257751: UCC/Barcode required'
EXEC rdt.rdtAddMsg 257752, 10, '257752^INVALID FORMAT',      'us_english', 729, 0, '257752: Invalid barcode format'
EXEC rdt.rdtAddMsg 257753, 10, '257753^UCC NOT FOUND',       'us_english', 729, 0, '257753: UCC not found in system'
EXEC rdt.rdtAddMsg 257754, 10, '257754^DECODE FAILURE',      'us_english', 729, 0, '257754: Failed to decode QR code'
