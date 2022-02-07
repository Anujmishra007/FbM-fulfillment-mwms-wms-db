--rdtfnc_TPEX_PalletInquiry
-- 4300 - 4309

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1181', 'ENG', 'FNC', 'TPEX Pallet Inquiry', 'rdtfnc_TPEX_PalletInquiry', '0')

-- Screen 1
DELETE rdt.RDTScn WHERE Scn = 4300 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4300, 'ENG',
	@cLine01 = 'PALLET INQUIRY',
	@cLine03 = 'PALLET ID: ',
   @cLine04 = '%20i01',
	@cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4301 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4301, 'ENG',
	@cLine01 = 'PALLET INQUIRY',
	@cLine03 = 'PALLET ID: ',
   @cLine04 = '%20d01',
   @cLine05 = 'DROP LOC: %10d02',
   @cLine06 = 'TRUCK ID: ',
   @cLine07 = '%20d03',
   @cLine08 = 'SHIPMENT NO: ',
   @cLine09 = '%20d04',
   @cLine10 = 'DEST LOC: %10d05',
   @cLine11 = 'TTL CTN: %10d06',
	@cLine14 = '%e'
		
-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4302 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4302, 'ENG',
	@cLine01 = 'PALLET ID: %03d01 / %03d02',
	@cLine02 = '%20d03',
   @cLine06 = 'STORER:',
   @cLine07 = '%15d04',
   @cLine08 = 'ORDER NO: ',
   @cLine09 = '%20d05',
   @cLine10 = 'CTN COUNT: %10d06',
   @cLine14 = '%e'
	
-- Screen 2
--DELETE rdt.RDTScn WHERE Scn = 4301 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn2 4301, 'ENG',
--   @cline01 = 'PALLET INQUIRY %d`08`05`yellow',
--	@cLine02 = 'PALLET ID: %d`07`09',
--   @cLine03 = '%d`01`20',
--	@cLine04 = 'DROP LOC: ',
--   @cLine05 = '%d`02`10',
--	@cLine06 = 'TRUCK ID: ',
--   @cLine07 = '%d`03`20',
--
--	@cLine08 = 'STORER: ',
--	@cline09 = '%d`04`15',
--	@cLine10 = 'ORDER NO: ',
--	@cline11 = '%d`05`10',
--	@cLine12 = 'SHIPMENT NUM: ',
--	@cLine13 = '%d`06`20',
--
--	@cLine14 = '%e'


UPDATE RDT.RDTScn SET Func = 1181 WHERE Scn Between 4300 AND 4309