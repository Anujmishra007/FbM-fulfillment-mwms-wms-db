--rdt_840DecodeSP03
execute rdt.rdtDropMsg 179201 , 179250

execute rdt.rdtAddMsg 179201, 10, '179201 Invalid SKU  ',   'us_english', 840
execute rdt.rdtAddMsg 179202, 10, '179202 Invalid SKU  ',   'us_english', 840
execute rdt.rdtAddMsg 179203, 10, '179203 Invalid Lot02',   'us_english', 840
execute rdt.rdtAddMsg 179204, 10, '179204 No OrderKey  ',   'us_english', 840
execute rdt.rdtAddMsg 179205, 10, '179205 No PickSlipNo',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 179201 AND 179250