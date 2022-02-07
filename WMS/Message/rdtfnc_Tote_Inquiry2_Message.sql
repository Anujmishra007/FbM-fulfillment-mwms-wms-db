--rdtfnc_Tote_Inquiry
execute rdt.rdtdropmsg 157101, 157150

execute rdt.rdtAddMsg 157101, 10, '157101^Tote# Req', 'us_english'
execute rdt.rdtAddMsg 157102, 10, '157102^Invalid Tote#', 'us_english'
execute rdt.rdtAddMsg 157103, 10, '157103^ToteNotNum', 'us_english'

--INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text,StoredProcName, EventType, Func, URL)
--VALUES (1846, 'ENG','FNC', 'Tote Inquiry2','rdtfnc_Tote_Inquiry2',2 ,0,'')


