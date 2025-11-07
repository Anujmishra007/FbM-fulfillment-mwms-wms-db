--rdt_610DecodeSP04_Message
execute rdt.rdtDropMsg 247151 , 247200

execute rdt.rdtAddMsg 247151, 10, '247151 Invalid UCC  ',     'us_english', 610, 0, '247151: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 247152, 10, '247152 Invalid UCC  ',     'us_english', 610, 0, '247152: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 247153, 10, '247153 Invalid UCC  ',     'us_english', 610, 0, '247153: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 247154, 10, '247154 Invalid UCC  ',     'us_english', 610, 0, '247154: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 247155, 10, '247155 Invalid UCC  ',     'us_english', 610, 0, '247155 Invalid UCC(40 digit)'



SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 247151 AND 247200

