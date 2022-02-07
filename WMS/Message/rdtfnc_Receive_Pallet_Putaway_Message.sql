--Message Range 156501 - 156550 (rdtfnc_Receive_Pallet_Putaway)
execute rdt.rdtDropMsg 156501,156550

execute rdt.rdtAddMsg 156501, 10, '156501^PalletID Req', 'us_english',1845
execute rdt.rdtAddMsg 156502, 10, '56502^InvalidPallet#', 'us_english',1845
execute rdt.rdtAddMsg 156503, 10, '156503^NoQtyToMove#', 'us_english',1845
execute rdt.rdtAddMsg 156504, 10, '156504^No Empty Loc', 'us_english',1845
execute rdt.rdtAddMsg 156505, 10, '156505^LOC Req', 'us_english',1845
execute rdt.rdtAddMsg 156506, 10, '156506^Not Bulk Loc', 'us_english',1845
execute rdt.rdtAddMsg 156507, 10, '156507^No Ucc No', 'us_english',1845


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 156501 AND 156550

--INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text,StoredProcName, EventType, Func, URL)
--VALUES (1845, 'ENG','FNC', 'Receiving Pallet Putaway','rdtfnc_Receive_Pallet_Putaway',2 ,0,'')



