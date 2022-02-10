-- rdt_840SwapLot02
EXEC rdt.rdtDropMsg 140401 , 140450

execute rdt.rdtAddMsg 140401, 10, '40401^INVALID ORDER ', 'us_english', 840
execute rdt.rdtAddMsg 140402, 10, '40402^INVALID SKU   ', 'us_english', 840
execute rdt.rdtAddMsg 140403, 10, '40403^INVALID LOT02 ', 'us_english', 840
execute rdt.rdtAddMsg 140404, 10, '40404^SKU NOT IN ORD', 'us_english', 840
execute rdt.rdtAddMsg 140405, 10, '40405^INVALID LABEL ', 'us_english', 840
execute rdt.rdtAddMsg 140406, 10, '40406^DIFF HM ORDER ', 'us_english', 840
execute rdt.rdtAddMsg 140407, 10, '40407^SKU OVERPACKED', 'us_english', 840
execute rdt.rdtAddMsg 140408, 10, '40408^SWAP LOT FAIL ', 'us_english', 840
execute rdt.rdtAddMsg 140409, 10, '40409^SWAP LOT FAIL ', 'us_english', 840
execute rdt.rdtAddMsg 140410, 10, '40410^SWAP LOT FAIL ', 'us_english', 840
execute rdt.rdtAddMsg 140411, 10, '40411^SWAP LOT FAIL ', 'us_english', 840
execute rdt.rdtAddMsg 140412, 10, '40412^UpdLog Failed ', 'us_english', 840
execute rdt.rdtAddMsg 140413, 10, '40413^InsLog Failed ', 'us_english', 840
execute rdt.rdtAddMsg 140414, 10, '40414^InsPKHDR Fail ', 'us_english', 840
execute rdt.rdtAddMsg 140415, 10, '40415^UPDPKDET Fail ', 'us_english', 840
execute rdt.rdtAddMsg 140416, 10, '40416^GET LABEL Fail', 'us_english', 840
execute rdt.rdtAddMsg 140417, 10, '40417^INSPKDET Fail ', 'us_english', 840
execute rdt.rdtAddMsg 140418, 10, '40418^INSPKDET Fail ', 'us_english', 840
execute rdt.rdtAddMsg 140419, 10, '40419^UPDPKDET Fail ', 'us_english', 840
execute rdt.rdtAddMsg 140420, 10, '40420^UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 140421, 10, '40421^UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 140422, 10, '40422^INS PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 140423, 10, '40423^INS RefKeyFail', 'us_english', 840
execute rdt.rdtAddMsg 140424, 10, '40424^UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 140425, 10, '40425^UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 140426, 10, '40426^OFFSET ERROR  ', 'us_english', 840
execute rdt.rdtAddMsg 140427, 10, '40427^UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 140428, 10, '40428^nspGetRightErr', 'us_english', 840
execute rdt.rdtAddMsg 140429, 10, '40429^GenTLog3 Fail',  'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 140401 AND 140450


