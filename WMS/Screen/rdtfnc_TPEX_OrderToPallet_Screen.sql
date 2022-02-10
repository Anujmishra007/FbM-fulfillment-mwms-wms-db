--rdtfnc_TPEX_OrderToPallet
-- 4310 - 4319


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1182', 'ENG', 'FNC', 'TPEX OrderToPallet', 'rdtfnc_TPEX_OrderToPallet', '0')


-- Screen 1
-- Scn = 4310 
DELETE rdt.RDTScn WHERE Scn = 4310 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4310, 'ENG', 
   @cLine01 = 'TPEX ORDER TO PALLET',
   @cLine03 = 'STORERKEY:',
   @cLine04 = '%15i01',
   --@cLine06 = 'ORDERKEY:',
   --@cLine07 = '%10i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4311 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4311, 'ENG', 
   @cLine01 = 'TPEX ORDER TO PALLET',
   @cLine03 = 'STORERKEY:',
   @cLine04 = '%15d01',
   @cLine06 = 'ORDERNO:',
   @cLine07 = '%20i02',
   @cLine09 = 'CARTON COUNT: %05i03',
   @cLine14 = '%e'


-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4312 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4312, 'ENG', 
   @cLine01 = 'TPEX ORDER TO PALLET',
   @cLine03 = 'ORDERNO:',
   @cLine04 = '%20d01',
   @cLine05 = 'CARTON COUNT: %05d02',
   @cLine07 = 'PALLET ID:',
   @cLine08 = '%20i03',
   --@cLine10 = 'DROP LOC: %10i04',
   @cLine14 = '%e'   
    

      
UPDATE RDT.RDTScn SET Func = 1182 WHERE Scn Between 4310 AND 4319 