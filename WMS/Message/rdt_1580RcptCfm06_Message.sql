-- rdt_1580RcptCfm06
execute rdt.rdtDropMsg 121401, 121450

execute rdt.rdtAddMsg 121401, 10, '121401Style NotInASN',   'us_english', 1580
execute rdt.rdtAddMsg 121402, 10, '121402Style over RCV',   'us_english', 1580
execute rdt.rdtAddMsg 121403, 10, '121403UPD RDtl Fail ',   'us_english', 1580
execute rdt.rdtAddMsg 121404, 10, '121404SKU not in PO ',   'us_english', 1580
execute rdt.rdtAddMsg 121405, 10, '121405SKU over RCV  ',   'us_english', 1580
execute rdt.rdtAddMsg 121406, 10, '121406Invalid QTY   ',   'us_english', 1580
