-- rdt_1812DecodeSP04
-- FCR-5753
execute rdt.rdtDropMsg 240251 , 240300

execute rdt.rdtAddMsg 240251, 10, '223651 Invalid Barcode',    'us_english', 1812, 0, '223651 Invalid Barcode'
execute rdt.rdtAddMsg 240252, 10, '240252 FetchSKUFail',       'us_english', 1812, 0, '240252 Fetch SKU Fail'
execute rdt.rdtAddMsg 240253, 10, '240253 FetchWgtFail',       'us_english', 1812, 0, '240253 Fetch Weight Fail'
execute rdt.rdtAddMsg 240254, 10, '240254 InvalidWgt',         'us_english', 1812, 0, '240254 Invalid Weight'
execute rdt.rdtAddMsg 240255, 10, '240255 DecodeFail',         'us_english', 1812, 0, '240255 Decode Fail'


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 240251 AND 240300

