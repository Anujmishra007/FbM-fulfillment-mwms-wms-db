-- rdtfnc_Trolley_Build_UCC
exec rdt.rdtDropMsg 155351, 155400

execute rdt.rdtAddMsg 155351, 10, '155351^UCC or Trolley', 'us_english', 1843
execute rdt.rdtAddMsg 155352, 10, '155352^NoUccToAssign', 'us_english', 1843
execute rdt.rdtAddMsg 155353, 10, '155353^Key-in either ', 'us_english', 1843
execute rdt.rdtAddMsg 155354, 10, '155354^UCC not exist ', 'us_english', 1843
execute rdt.rdtAddMsg 155355, 10, '155355^Bad UCC status', 'us_english', 1843
execute rdt.rdtAddMsg 155356, 10, '155356^UCC scanned', 'us_english', 1843
execute rdt.rdtAddMsg 155357, 10, '155357^UCC NotOnPKDtl', 'us_english', 1843
execute rdt.rdtAddMsg 155358, 10, '155358^NoUCCAssignLOC', 'us_english', 1843
execute rdt.rdtAddMsg 155359, 10, '155359^INS Log Fail', 'us_english', 1843
execute rdt.rdtAddMsg 155360, 10, '155360^Bad Trolley No', 'us_english', 1843
execute rdt.rdtAddMsg 155361, 10, '155361^Trolley closed', 'us_english', 1843
execute rdt.rdtAddMsg 155362, 10, '155362^Need TrolleyNo', 'us_english', 1843
execute rdt.rdtAddMsg 155363, 10, '155363^Trolley closed', 'us_english', 1843
execute rdt.rdtAddMsg 155364, 10, '155264^UPD Log FaiL', 'us_english', 1843
execute rdt.rdtAddMsg 155365, 10, '155365^OptionRequired', 'us_english', 1843
execute rdt.rdtAddMsg 155366, 10, '155366^Invalid Option', 'us_english', 1843
execute rdt.rdtAddMsg 155367, 10, '155367^UPD Log Fail', 'us_english', 1843    

--INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text,StoredProcName, EventType, Func, URL)
--VALUES (1843, 'ENG','FNC', 'BUILD UCC TROLLEY','rdtfnc_Trolley_Build_UCC',2 ,0,'')
