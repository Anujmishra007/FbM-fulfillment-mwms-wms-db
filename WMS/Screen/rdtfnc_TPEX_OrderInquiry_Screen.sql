--rdtfnc_TPEX_OrderInquiry
--4330 - 4339

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1184', 'ENG', 'FNC', 'TPEX Order Inquiry', 'rdtfnc_TPEX_OrderInquiry', '0')

-- Screen 1
DELETE rdt.RDTScn WHERE Scn = 4330 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4330, 'ENG',
	@cLine01 = 'ORDER INQUIRY',
	@cLine03 = 'ORDER NUM:',
   @cLine04 = '%10i01',
	@cLine14 = '%e'

DELETE rdt.RDTScn WHERE Scn = 4331 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4331, 'ENG',
	@cLine01 = 'ORDER INQUIRY',
	@cLine03 = 'ORDER NO   %03d07 / %03d08:',
   @cLine04 = '%20d01',
   @cLine05 = 'PALLET ID:',
   @cLine06 = '%20d02',
   @cLine07 = 'STATUS: %20d03',
   @cLine08 = 'QTY: %10d04',
   @cLine09 = 'TRUCK ID:',
   @cLine10 = '%20d05',
   @cLine11 = 'DROP LOC:',
   @cLine12 = '%10d06',
	@cLine14 = '%e'
	
-- Screen 2
--DELETE rdt.RDTScn WHERE Scn = 4331 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn2 4331, 'ENG',
--   @cline01 = 'ORDER INQUIRY  %d`08`05`yellow',  
--	@cLine02 = 'STORER: %d`07`09',
--   @cLine03 = '%d`01`15',
--	@cLine04 = 'ORDER NUM:',
--   @cLine05 = '%d`02`10',
--	@cLine06 = 'SHIPMENT NUM:',
--   @cLine07 = '%d`03`10',
--
--	@cLine08 = 'PALLET ID:',
--	@cline09 = '%d`04`20',
--	@cLine10 = 'DROP LOC:',
--	@cline11 = '%d`05`10',
--	@cLine12 = 'TRUCK ID:',
--	@cLine13 = '%d`06`10',
--
--	@cLine14 = '%e'


UPDATE RDT.RDTScn SET Func = 1184 WHERE Scn Between 4330 AND 4339