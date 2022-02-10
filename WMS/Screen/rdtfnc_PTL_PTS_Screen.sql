--rdtfnc_PTL_PTS
-- 3730 - 3739


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('816', 'ENG', 'FNC', 'PTL- Put To Store', 'rdtfnc_PTL_PTS', '0')

-- Screen 1
-- Scn = 3730 
DELETE rdt.RDTScn WHERE Scn = 3730 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3730, 'ENG', 
   @cLine01 = 'PTL - PUT TO STORE',
   @cLine03 = 'PTS ZONE:',
   @cLine04 = '%10i01',
   @cLine06 = 'PAPER PRINTER:',
   @cLine07 = '%10i02',
   @cLine09 = 'LABEL PRINTER',
   @cLine10 = '%10i03',

   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3731 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3731, 'ENG', 
   @cLine01 = 'PTL - PUT TO STORE',
   @cLine03 = 'PTS Zone:',
   @cLine04 = '%10d01',
   @cLine06 = 'TOTE ID / UCC NO:',
   @cLine07 = '%20i02',
   @cLine09 = 'OR',
   @cLine10 = 'CLOSE LAST CARTONID:',
   @cLine11 = '%20i03',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3732 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3732, 'ENG', 
   @cLine01 = 'PTL - PUT TO STORE',
   @cLine02 = 'PTS Zone:',
   @cLine03 = '%10d01',
   @cLine04 = 'TOTE ID / UCC NO:',
   @cLine05 = '%20d02',
   @cLine06 = 'SKU:',
   @cLine07 = '%20d03',
   @cLine08 = '%20d04',
   @cLine09 = '%20d05',
   @cLine10 = 'UCC LOC:%10d06',
   @cLine12 = 'CLOSE CARTON ID:',
   @cLine13 = '%20i07',
   @cLine14 = '%e'
 
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3733 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3733, 'ENG', 
   @cLine01 = 'PTL - PUT TO STORE',
   @cLine03 = 'CLOSE CARTON ID:',
   @cLine04 = '%20d01',
   @cLine06 = 'NEW CARTON ID:',
   @cLine07 = '%20i02',
   --@cLine09 = 'PTS LOC:',
   --@cLine10 = '%10i03',
   @cLine14 = '%e'

 
-- Screen 5
/*DELETE rdt.RDTScn WHERE Scn = 3734 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3734, 'ENG', 
   @cLine01 = 'PTL - PUT TO STORE',
   @cLine03 = 'CLOSE CARTON ID:',
   @cLine04 = '%20d01',
   @cLine06 = 'HAD SHORT PACKED',
   @cLine07 = 'CONFIRM CLOSE ?',
   @cLine08 = '1 = YES | 9 = NO',
   @cLine09 = 'OPTIONS: %01i02',
   @cLine14 = '%e'   
 */  
        
      
UPDATE RDT.RDTScn SET Func = 816 WHERE Scn Between 3730 AND 3739 
UPDATE RDT.RDTScnDetail SET Func = 816 WHERE Scn Between 3730 AND 3739 