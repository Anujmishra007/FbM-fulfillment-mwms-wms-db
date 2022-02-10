--rdt_840DecodeSP01
execute rdt.rdtDropMsg 157501 , 157550

execute rdt.rdtAddMsg 157501, 10, '57501^Invalid SKU',     'us_english', 840
execute rdt.rdtAddMsg 157502, 10, '57502^Invalid SKU',     'us_english', 840
execute rdt.rdtAddMsg 157503, 10, '57503^Invalid Lot02',   'us_english', 840
execute rdt.rdtAddMsg 157504, 10, '57504^No OrderKey',     'us_english', 840

--WMS-17200
execute rdt.rdtAddMsg 157505, 10, '57505^No PickSlip No',  'us_english', 840
execute rdt.rdtAddMsg 157506, 10, '57506^No Lbl',          'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 157501 AND 157550