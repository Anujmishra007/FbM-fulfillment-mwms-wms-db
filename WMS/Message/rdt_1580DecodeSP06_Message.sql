-- rdt_1580DecodeSP06
execute rdt.rdtDropMsg 248201, 248250

execute rdt.rdtAddMsg 248201, 10, '248201InvalidBarocde', 'us_english', 1580, 0, '248201 Invalid barcode'
execute rdt.rdtAddMsg 248202, 10, '248202Invalid SKU   ', 'us_english', 1580, 0, '248202 Invalid SKU'
execute rdt.rdtAddMsg 248203, 10, '248203Multi SKU     ', 'us_english', 1580, 0, '248203 Multi SKU barcode'
execute rdt.rdtAddMsg 248204, 10, '248204MSNO not found', 'us_english', 1580, 0, '248204 Master serial no not found'
execute rdt.rdtAddMsg 248205, 10, '248205NoOpen RcptDtl', 'us_english', 1580, 0, '248205 No open receiptdetail in the ASN'
execute rdt.rdtAddMsg 248206, 10, '248206Mix SKU or L01', 'us_english', 1580, 0, '248206 Mix SKU or Lottable01 on same ID'
execute rdt.rdtAddMsg 248207, 10, '248207InvalidBarocde', 'us_english', 1580, 0, '248207 Invalid barcode'

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 248201 AND 248250