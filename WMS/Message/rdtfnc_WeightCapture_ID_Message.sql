--Message Range 145301-145350 (rdtfnc_WeightCapture_ID)
execute rdt.rdtDropMsg 145551,145600

execute rdt.rdtAddMsg 145551, 10, '145551^Need ID', 'us_english'
execute rdt.rdtAddMsg 145552, 10, '145552^Invalid ID', 'us_english'
execute rdt.rdtAddMsg 145553, 10, '145553^Need Weight', 'us_english'
execute rdt.rdtAddMsg 145555, 10, '145554^InvalidFormat', 'us_english'
execute rdt.rdtAddMsg 145554, 10, '145555^InvalidWeight', 'us_english'
execute rdt.rdtAddMsg 145556, 10, '145556^InsertIDFail', 'us_english'
execute rdt.rdtAddMsg 145557, 10, '145557^UpdateIDFail', 'us_english'


--INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text,StoredProcName, EventType, Func, URL)
--VALUES (1839, 'ENG','FNC', 'WEIGHT CAPTURE BY ID','rdtfnc_WeightCapture_ID',9 ,0,'')

