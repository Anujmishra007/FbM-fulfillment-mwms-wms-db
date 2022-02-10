--Message Range 145301-145350 (rdtfnc_PickJobCapture)
execute rdt.rdtDropMsg 145301,145350

execute rdt.rdtAddMsg 145301, 10, '145301^Need UserID', 'us_english'
execute rdt.rdtAddMsg 145302, 10, '145302^Invalid User', 'us_english'
execute rdt.rdtAddMsg 145303, 10, '145303^Inactive User', 'us_english'
execute rdt.rdtAddMsg 145304, 10, '145304^Need Option', 'us_english'
execute rdt.rdtAddMsg 145305, 10, '145305^InvalidOption', 'us_english'
execute rdt.rdtAddMsg 145306, 10, '145306^NeedPickSlip', 'us_english'
execute rdt.rdtAddMsg 145307, 10, '145307^InvalidPickNo', 'us_english'
execute rdt.rdtAddMsg 145308, 10, '145308^Need Qty', 'us_english'
execute rdt.rdtAddMsg 145309, 10, '145309^Invalid Qty', 'us_english'

--INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text,StoredProcName, EventType, Func, URL)
--VALUES (1838, 'ENG','FNC', 'PICK JOB CAPTURE','rdtfnc_JobCapture_PickSlip',9 ,0,'')
