--	rdt_557DecodeSP02
execute rdt.rdtDropMsg 247201 , 247250

execute rdt.rdtAddMsg 247201, 10, '247201 Invalid UCC  ',     'us_english', 557, 0, '247201: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 247202, 10, '247202 Invalid UCC  ',     'us_english', 557, 0, '247202: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 247203, 10, '247203 Invalid UCC  ',     'us_english', 557, 0, '247203: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 247204, 10, '247204 Invalid UCC  ',     'us_english', 557, 0, '247204: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 247205, 10, '247205 Invalid UCC  ',     'us_english', 557, 0, '247205 Invalid UCC(40 digit)'



SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 247201 AND 247250

