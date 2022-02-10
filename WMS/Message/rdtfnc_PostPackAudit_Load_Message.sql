/*
INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName)
VALUES (568 , 'ENG', 'FNC', 'Load', 'rdtfnc_PostPackAudit_Load')
*/

-- rdtfnc_PostPackAudit_Load (range 60751 - 60800)
execute rdt.rdtAddMsg 60751, 10, '60751 Vehicle needed', 'us_english'
execute rdt.rdtAddMsg 60752, 10, '60752 Stor needed',    'us_english'
execute rdt.rdtAddMsg 60753, 10, '60753 Seal needed',    'us_english'
execute rdt.rdtAddMsg 60754, 10, '60754 Invalid stor',   'us_english'
execute rdt.rdtAddMsg 60755, 10, '60755 CaseID needed',  'us_english'
execute rdt.rdtAddMsg 60756, 10, '60756 Invalid CaseID', 'us_english'
execute rdt.rdtAddMsg 60757, 10, '60757 Stor is Diff',   'us_english'
execute rdt.rdtAddMsg 60758, 10, '60758 Upd load fail',  'us_english'

--execute rdt.rdtDropMsg 60758
