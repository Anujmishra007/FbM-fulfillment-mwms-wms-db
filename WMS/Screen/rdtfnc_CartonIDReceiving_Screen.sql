--rdtfnc_CartonIDReceiving
-- 3100 - 3109


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('597', 'ENG', 'FNC', 'CartonID Receive', 'rdtfnc_CartonIDReceiving', '1')


-- Screen 1
-- Scn = 3100 
DELETE rdt.RDTScn WHERE Scn = 3100 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3100, 'ENG', 
   @cLine01 = 'ASN: %10i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3101 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3101, 'ENG', 
   @cLine01 = 'ASN: %10d01',
   @cLine02 = 'EXTERN POKEY:',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine06 = 'TO LOC:',
   @cLine07 = '%10i04',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3102 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3102, 'ENG', 
   @cLine01 = 'ASN: %10d01',
   @cLine02 = 'EXTERN POKEY:',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = 'TO LOC: %10d04',
   @cLine07 = 'TO ID:',
   @cLine08 = '%18i05',
   @cLine14 = '%e'
   
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3103 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3103, 'ENG', 
   @cLine01 = 'ASN: %10d01',
   @cLine02 = 'EXTERN POKEY:',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = 'TO LOC: %10d04',
   @cLine06 = 'TO ID:',
   @cLine07 = '%18d05',
   @cLine09 = 'CARTON ID:',
   @cLine10 = '%20i06',
   @cLine14 = '%e'

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 3104 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3104, 'ENG',
    @cLine01 = 'CARTON ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20i02'
   ,@cLine05 = 'DESC:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = 'CONDITION CODE: %01i05'
   ,@cLine09 = '0 = NOT SALEABLE'
   ,@cLine10 = '1 = SALEABLE'
   ,@cLine11 = 'QTY TO RCV: %05i06'
   ,@cLine12 = 'SKU QTY: %05d07 / %05d08'
   ,@cLine13 = 'CTN QTY: %05d09 / %05d10'
   ,@cLine14 = '%e'
   
-- Screen 6
--DELETE rdt.RDTScn WHERE Scn = 3105 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 3105, 'ENG', 
--   @cLine01 = 'CARTON ID:',
--   @cLine02 = '%20d01',
--   @cLine03 = 'SKU:',
--   @cLine04 = '%20d02',
--   @cLine05 = 'QTY RECEIVED NOT',
--   @cLine06 = 'EQUAL QTY EXPECTED',
--   @cLine08 = 'CONFIRM EXIT ?',
--   @cLine09 = '1 = YES',
--   @cLine10 = '2 = NO',
--   @cLine11 = 'OPTIONS : %01i03',
--   @cLine14 = '%e'    

-- Screen 6
DELETE rdt.RDTScn WHERE Scn = 3105 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3105, 'ENG', 
   @cLine01 = 'SKU:',
   @cLine02 = '%20d01',
   @cLine04 = 'SUGGESTED LOC',
   @cLine05 = '%20d02',
   @cLine06 = '%20d03',
   @cLine07 = '%20d04',
   @cLine08 = '%20d05',
   @cLine09 = '%20d06',
   @cLine11 = 'TO LOC: %10i07',
   @cLine14 = '%e',     
   @nFunc   = 597

-- Screen 7
DELETE rdt.RDTScn WHERE Scn = 3106 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3106, 'ENG', 
   @cLine01 = 'SUGGESTED LOC NOT',
   @cLine02 = 'MATCH LOC KEY IN.',
   @cLine03 = 'PROCEED ?',
   @cLine05 = '1 = YES; 2 = NO',
   @cLine06 = 'OPTION: %01i01',
   @cLine14 = '%e',     
   @nFunc   = 597
   
UPDATE RDT.RDTScnDetail SET Func = 597 WHERE Scn Between 3100 AND 3109