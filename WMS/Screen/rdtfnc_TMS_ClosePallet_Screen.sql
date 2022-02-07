--rdtfnc_TMS_ClosePallet
--4840 - 4849

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1188', 'ENG', 'FNC', 'TMS Close Pallet', 'rdtfnc_TMS_ClosePallet', '0')

-- Screen 1
DELETE rdt.RDTScn WHERE Scn = 4840 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4840, 'ENG',
	@cLine01 = 'TMS CLOSE PALLET',
	@cLine03 = 'PALLET ID:',
   @cLine04 = '%20i01',
   @cLine06 = 'HEIGHT: %10i02',
   @cLine08 = 'WEIGHT: %10i03',
   @cLine10 = 'DROP LOC:',
   @cLine11 = '%20i04',
	@cLine14 = '%e'



UPDATE RDT.RDTScn SET Func = 1188 WHERE Scn Between 4840 AND 4839