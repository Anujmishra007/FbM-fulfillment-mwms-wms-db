--Message Range 156051 - 156100 (rdtfnc_WavePK_tote_Inquiry)
execute rdt.rdtDropMsg 156051,156100

execute rdt.rdtAddMsg 156051, 10, '56051^Wave#/Tote Req', 'us_english',1844
execute rdt.rdtAddMsg 156052, 10, '56052^WavePKNotFound', 'us_english',1844
execute rdt.rdtAddMsg 156053, 10, '56053^PartialAssign', 'us_english',1844
execute rdt.rdtAddMsg 156054, 10, '56054^Tote#NotAssign', 'us_english',1844
execute rdt.rdtAddMsg 156055, 10, '56055^NoOrdersAssign', 'us_english',1844


--INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text,StoredProcName, EventType, Func, URL)
--VALUES (1844, 'ENG','FNC', 'WavePK & Tote Inquiry','rdtfnc_WavePK_tote_Inquiry',0 ,0,'')




