-- rdtfnc_ReturnUnloading
rdt.rdtDropMsg 163401, 163450

execute rdt.rdtAddMsg 163401, 10, '163401GetKey Fail   ', 'us_english', 1852
execute rdt.rdtAddMsg 163402, 10, '163402Need Seal No  ', 'us_english', 1852
execute rdt.rdtAddMsg 163403, 10, '163403Need Option   ', 'us_english', 1852
execute rdt.rdtAddMsg 163404, 10, '163404Invalid Opt   ', 'us_english', 1852
execute rdt.rdtAddMsg 163405, 10, '163405Need Bag No   ', 'us_english', 1852
execute rdt.rdtAddMsg 163406, 10, '163406Need AWB      ', 'us_english', 1852
execute rdt.rdtAddMsg 163407, 10, '163407AWB Not Exist ', 'us_english', 1852
execute rdt.rdtAddMsg 163408, 10, '163408Invalid AWB   ', 'us_english', 1852
execute rdt.rdtAddMsg 163409, 10, '163409StatusNotOpen ', 'us_english', 1852
execute rdt.rdtAddMsg 163410, 10, '163410UpdReceiptFail', 'us_english', 1852
execute rdt.rdtAddMsg 163411, 10, '163411Need Option   ', 'us_english', 1852
execute rdt.rdtAddMsg 163412, 10, '163412Invalid Opt   ', 'us_english', 1852
execute rdt.rdtAddMsg 163413, 10, '163413Need Bag No   ', 'us_english', 1852
execute rdt.rdtAddMsg 163414, 10, '163414NeedTrackNo   ', 'us_english', 1852
execute rdt.rdtAddMsg 163415, 10, '163415OrderNotExist ', 'us_english', 1852
execute rdt.rdtAddMsg 163416, 10, '163416Invalid RTO   ', 'us_english', 1852
execute rdt.rdtAddMsg 163417, 10, '163417GenRecKeyFail ', 'us_english', 1852
execute rdt.rdtAddMsg 163418, 10, '163418INS Rec Fail  ', 'us_english', 1852
execute rdt.rdtAddMsg 163419, 10, '163419INSRecDtFail  ', 'us_english', 1852
execute rdt.rdtAddMsg 163420, 10, '163420INS TLog2 Fail', 'us_english', 1852
execute rdt.rdtAddMsg 163421, 10, '163421INS TLog2 Fail', 'us_english', 1852

SELECT TOP 100 * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 163401 and 163450



