

-- rdtfnc_SerialNoCapture
execute rdt.rdtDropMsg 150501, 150550

execute rdt.rdtAddMsg 150501, 10,'50501^Receiptkeyneed', 'us_english', 645
execute rdt.rdtAddMsg 150502, 10,'50502^InvRECKEY', 'us_english', 645
execute rdt.rdtAddMsg 150503, 10,'50503^DiffFacility', 'us_english', 645
execute rdt.rdtAddMsg 150504, 10,'50504^DiffStorerkey', 'us_english', 645
execute rdt.rdtAddMsg 150505, 10,'50505^SKURequired', 'us_english', 645
execute rdt.rdtAddMsg 150506, 10,'50506^InvalidSKU', 'us_english', 645
execute rdt.rdtAddMsg 150507, 10,'50507^SKUNOTFound', 'us_english', 645
execute rdt.rdtAddMsg 150508, 10,'50508^MultiSKUBarcod', 'us_english', 645
execute rdt.rdtAddMsg 150509, 10,'50509^BatchCodeRequire', 'us_english', 645
execute rdt.rdtAddMsg 150510, 10,'50510^InvBatchCode', 'us_english', 645
execute rdt.rdtAddMsg 150511, 10,'50511^CartonSNReq', 'us_english', 645
execute rdt.rdtAddMsg 150512, 10,'50512^BottleSNReq', 'us_english', 645
execute rdt.rdtAddMsg 150513, 10,'50513^InsTIDFail', 'us_english', 645
execute rdt.rdtAddMsg 150514, 10,'50514^InvFormat', 'us_english', 645
execute rdt.rdtAddMsg 150515, 10,'50515^QtyNotBalace', 'us_english', 645
execute rdt.rdtAddMsg 150516, 10,'50516^QtyNotBalace', 'us_english', 645
execute rdt.rdtAddMsg 150517, 10,'50517^CartonScanned', 'us_english', 645
execute rdt.rdtAddMsg 150518, 10,'50518^BottleScanned', 'us_english', 645
execute rdt.rdtAddMsg 150519, 10,'50519^InvCartonID', 'us_english', 645

--wms18116
execute rdt.rdtAddMsg 150520, 10,'50520^InvFormat', 'us_english', 645