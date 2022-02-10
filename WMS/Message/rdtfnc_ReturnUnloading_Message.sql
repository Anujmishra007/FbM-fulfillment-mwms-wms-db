-- rdtfnc_ReturnUnloading
rdt.rdtDropMsg 163401, 163450

execute rdt.rdtAddMsg 163401, 10, '163401^GetKey Fail  ', 'us_english', 1852
execute rdt.rdtAddMsg 163402, 10, '163402^Need Seal No ', 'us_english', 1852
execute rdt.rdtAddMsg 163403, 10, '163403^Need Option  ', 'us_english', 1852
execute rdt.rdtAddMsg 163404, 10, '163404^Invalid Opt  ', 'us_english', 1852
execute rdt.rdtAddMsg 163405, 10, '163405^Need Bag No  ', 'us_english', 1852
execute rdt.rdtAddMsg 163406, 10, '163406^Need AWB     ', 'us_english', 1852
execute rdt.rdtAddMsg 163407, 10, '163407^AWB Not Exist', 'us_english', 1852
execute rdt.rdtAddMsg 163408, 10, '163408^Invalid AWB  ', 'us_english', 1852
execute rdt.rdtAddMsg 163409, 10, '163409^StatusNotOpen', 'us_english', 1852
execute rdt.rdtAddMsg 163410, 10, '163410UpdReceiptFail', 'us_english', 1852
execute rdt.rdtAddMsg 163411, 10, '163411^Need Option  ', 'us_english', 1852
execute rdt.rdtAddMsg 163412, 10, '163412^Invalid Opt  ', 'us_english', 1852
execute rdt.rdtAddMsg 163413, 10, '163413^Need Bag No  ', 'us_english', 1852
execute rdt.rdtAddMsg 163414, 10, '163414NeedTrackingNo', 'us_english', 1852
execute rdt.rdtAddMsg 163415, 10, '163415^OrderNotExist', 'us_english', 1852
execute rdt.rdtAddMsg 163416, 10, '163416^Invalid RTO  ', 'us_english', 1852
execute rdt.rdtAddMsg 163417, 10, '163417^GenRecKeyFail', 'us_english', 1852
execute rdt.rdtAddMsg 163418, 10, '163418^INS Rec Fail ', 'us_english', 1852
execute rdt.rdtAddMsg 163419, 10, '163419^INSRecDtFail ', 'us_english', 1852


SELECT TOP 100 * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 163401 and 163450



