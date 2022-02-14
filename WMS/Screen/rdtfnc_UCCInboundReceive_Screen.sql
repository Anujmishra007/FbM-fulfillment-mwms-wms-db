/*
   UCC outbound receive
*/

-- 690 = ASNNo, ExternPOKey
DELETE rdt.RDTScn WHERE Scn = 690 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 690, 'ENG', 
   @cLine01 = 'ASN: %10i01', 
   @cLine02 = '     %10i02', 
   @cLine03 = '     %10i03', 
   @cLine04 = '     %10i04', 
   @cLine05 = '     %10i05', 
   @cLine06 = 'EXTPO:', 
   @cLine07 = '%20d06', 
   @cLine08 = 'REF NO:',   -- SOS354977
   @cLine09 = '%20i07',    -- SOS354977
   @cLine14 = '%e'

-- 691 = LOC (input), ID
DELETE rdt.RDTScn WHERE Scn = 691 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 691, 'ENG', 
   @cLine01 = 'ASN: %10d01', 
   @cLine02 = '     %10d02', 
   @cLine03 = '     %10d03', 
   @cLine04 = '     %10d04', 
   @cLine05 = '     %10d05', 
   @cLine06 = 'EXTPO:', 
   @cLine07 = '%20d06', 
   @cLine08 = 'REF NO:',
   @cLine09 = '%20d08',
   @cLine11 = 'LOC: %10i07', 
   @cLine14 = '%e'

-- 692 = LOC, ID (input)
DELETE rdt.RDTScn WHERE Scn = 692 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 692, 'ENG', 
   @cLine01 = 'ASN: %10d01', 
   @cLine02 = '     %10d02', 
   @cLine03 = '     %10d03', 
   @cLine04 = '     %10d04', 
   @cLine05 = '     %10d05', 
   @cLine06 = 'EXTPO:', 
   @cLine07 = '%20d06', 
   @cLine08 = 'REF NO:',
   @cLine09 = '%20d09',
   @cLine11 = 'LOC: %10d07', 
   @cLine12 = 'ID:', 
   @cLine13 = '%20i08', 
   @cLine14 = '%e'
   
-- 693 = UCC, QTY
DELETE rdt.RDTScn WHERE Scn = 693 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 693, 'ENG', 
   @cLine01 = 'LOC: %10d01', 
   @cLine02 = 'ID:', 
   @cLine03 = '%18d02', 
   @cLine04 = '', 
   @cLine05 = 'UCC:', 
   @cLine06 = '%20i03', 
   @cLine07 = '%20d08', -- (ChewKP02)
   @cLine08 = '%20d06', -- (ChewKP02)
   @cLine09 = '%10d07', -- (ChewKP02)
   @cLine10 = 'QTY: %05d04', 
   @cLine11 = 'SCAN/TOTAL:', 
   @cLine12 = '%20d05', 
   @cLine13 = '%20d15',    -- WMS-12334
   @cLine14 = '%e'

-- 694 = Message, counter, option
DELETE rdt.RDTScn WHERE Scn = 694 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 694, 'ENG', 
   @cLine01 = '', 
   @cLine02 = 'NOT ALL UCC RECEIVED', 
   @cLine03 = '', 
   @cLine04 = 'TOTAL  : %05d01', 
   @cLine05 = 'SCAN   : %05d02', 
   @cLine06 = 'REMAIN : %05d03', 
   @cLine07 = '', 
   @cLine08 = 'EXIT?', 
   @cLine09 = '1 - YES', 
   @cLine10 = '2 - NO', 
   @cLine11 = '', 
   @cLine12 = 'OPTION: %01i04', 
   @cLine13 = '', 
   @cLine14 = '%e'

-- 695 = Carton type
DELETE rdt.RDTScn WHERE Scn = 695 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 695, 'ENG', 
   @cLine01 = '', 
   @cLine02 = 'CARTON TYPE:', 
   @cLine03 = '%30i01', 
   @cLine14 = '%e'

UPDATE RDT.RDTScn SET Func = 573 WHERE Scn Between 690 AND 695 

