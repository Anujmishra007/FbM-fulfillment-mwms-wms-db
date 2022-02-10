--rdtfnc_Barcode_Receiving
-- 2750 - 2759

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('577', 'ENG', 'FNC', 'Receive By SerialNo', 'rdtfnc_SerialCapture_Receiving', '1')

-- 2750 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2750 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2750, 'ENG',
    @cLine01 = 'ASN: %10i01'   -- ASN #
   ,@cLine14 = '%e'
   
 
-- 2751 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2751 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2751, 'ENG',
    @cLine01 = 'TOLOC: %10i01'   -- ToLOC
   ,@cLine14 = '%e'

-- 2752 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2752 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2752, 'ENG',
    @cLine01 = 'Receive Method By:'
   ,@cLine03 = '1 = PALLET'
   ,@cLine04 = '2 = CASE'
   ,@cLine05 = '3 = BOTTLE'
   ,@cLine12 = 'Option: %01i01'
   ,@cLine14 = '%e'
   
-- 2753 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2753 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2753, 'ENG',
    @cLine01 = 'Receive Method By:'
   ,@cLine03 = '%10d01'
   ,@cLine04 = '%20i02'
   ,@cLine06 = '%20d03'
   ,@cLine14 = '%e'

      
-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 577 WHERE SCN BETWEEN 2750 AND 2759
   
-- Note: This module no need set function no as it is shared across multi function