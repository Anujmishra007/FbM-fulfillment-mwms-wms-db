--rdt_610DecodeSP06  (NYE018)
--Message range: 260351 - 260400

EXECUTE rdt.rdtdropmsg 260351, 260400

EXECUTE rdt.rdtAddMsg 260351, 10, '260351^InvFormat',       'us_english', 610, 0, '260351: Invalid QR format'
EXECUTE rdt.rdtAddMsg 260352, 10, '260352^DecodeFailure',   'us_english', 610, 0, '260352: Failed to decode barcode'
EXECUTE rdt.rdtAddMsg 260353, 10, '260353^InvalidSKU',      'us_english', 610, 0, '260353: Invalid SKU'
EXECUTE rdt.rdtAddMsg 260354, 10, '260354^NoDecodeConfig',  'us_english', 610, 0, '260354: No decode config found'
EXECUTE rdt.rdtAddMsg 260355, 10, '260355^InvalidDate',     'us_english', 610, 0, '260355: Invalid date format'
EXECUTE rdt.rdtAddMsg 260356, 10, '260356^InvalidSKU',      'us_english', 610, 0, '260356: Invalid SKU'
EXECUTE rdt.rdtAddMsg 260357, 10, '260357^InvFormat',       'us_english', 610, 0, '260357: Invalid QR format'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 260351 AND 260400
