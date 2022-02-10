--rdtfnc_TrackNoMBOL_Creation
-- 2730 - 2739

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1664', 'ENG', 'FNC', 'TrackNo MBOLCreation', 'rdtfnc_TrackNoMBOL_Creation', '0')

-- 2730 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2730 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2730, 'ENG',
    @cLine01 = 'MBOL Creation'
   ,@cLine03 = 'MBOLKEY:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   
 
-- 2731 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2731 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2731, 'ENG',
    @cLine01 = 'MBOL Creation'
   ,@cLine03 = 'MBOLKEY:'
   ,@cLine04 = '%10d01'
   ,@cLine06 = 'TOTAL ORDER IN MBOL:'
   ,@cLine07 = '%05d02'
   ,@cLine09 = 'TRACK NO:'
   ,@cLine10 = '%20i03' -- (ChewKP05)
   ,@cLine14 = '%e'

-- 2732 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2732 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2732, 'ENG',
    @cLine01 = 'MBOL Creation'
   ,@cLine03 = 'MBOLKEY:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'TRACK NO:'
   ,@cLine06 = '%20d02' -- (ChewKP05)
   ,@cLine08 = 'ORDERKEY: %10d03'
   ,@cLine09 = 'EXTERN ORDERKEY:'
   ,@cLine10 = '%20d04'
   ,@cLine11 = 'CONSIGNEE:'
   ,@cLine12 = '%15d05'
   ,@cLine14 = '%e'

-- 2733 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2733 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2733, 'ENG',
    @cLine01 = 'MBOL Creation'
   ,@cLine03 = 'Order Weight:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'

-- (ChewKP03)   
-- 2733 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2734 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2734, 'ENG',
    @cLine01 = 'MBOL Creation'
   ,@cLine03 = 'Carton Label No:'
   ,@cLine04 = '%20i01'
   ,@cLine06 = 'Carton Qty: %05i02' -- (ChewKP04)
   ,@cLine07 = 'Label Scanned: %05d03' -- (james02)
   ,@cLine14 = '%e'   
   
   
-- (ChewKP03)   
-- 2734 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2735 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2735, 'ENG',
    @cLine01 = 'MBOL Creation'
   ,@cLine03 = 'MBOLKey:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'PALLET ID:' 
   ,@cLine06 = '%10i02'
   ,@cLine14 = '%e'      

      
-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 1664 WHERE SCN BETWEEN 2730 AND 2739
   
-- Note: This module no need set function no as it is shared across multi function