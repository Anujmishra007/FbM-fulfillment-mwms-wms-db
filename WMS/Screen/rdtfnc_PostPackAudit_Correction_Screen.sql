/*
   Post pick audit load
*/

-- XDock/Indent case
-- 590 = Batch, Case ID
DELETE rdt.RDTScn WHERE Scn = 590 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 590, 'ENG', 
   @cLine01 = 'CASE CORRECTION', 
   @cLine02 = '',
   @cLine03 = 'BATCH:',
   @cLine04 = '%15i01*',
   @cLine05 = '',    
   @cLine06 = 'CASE ID:', 
   @cLine07 = '%18i02', 
   @cLine14 = '%e'

-- 591 = Batch, Case ID, QTY, Reason code
DELETE rdt.RDTScn WHERE Scn = 591 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 591, 'ENG', 
   @cLine01 = 'CASE CORRECTION',
   @cLine02 = 'BATCH:',
   @cLine03 = '%15d01',   
   @cLine04 = '', 
   @cLine05 = 'CASE ID:', 
   @cLine06 = '%18d02', 
   @cLine07 = '', 
   @cLine08 = 'QTY: %05i03', 
   @cLine09 = 'REASON: %10i04', 
   @cLine14 = '%e'

-- 592 = Message screen
DELETE rdt.RDTScn WHERE Scn = 592 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 592, 'ENG', 
   @cLine01 = '', 
   @cLine02 = 'MAKE THE ADJUSTMENT?', 
   @cLine03 = '', 
   @cLine04 = '1 - YES', 
   @cLine05 = '2 - NO', 
   @cLine06 = '', 
   @cLine07 = 'OPTION: %01i01', 
   @cLine08 = '', 
   @cLine14 = '%e'

-- 593 = Message screen
DELETE rdt.RDTScn WHERE Scn = 593 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 593, 'ENG', 
   @cLine02 = 'Case adjusted', 
   @cLine03 = 'successfully', 
   @cLine04 = '', 
   @cLine05 = 'Press ENTER or ESC', 
   @cLine06 = 'to continue', 
   @cLine14 = '%e'


-- Tote
-- 600 = Batch, Tote
DELETE rdt.RDTScn WHERE Scn = 600 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 600, 'ENG', 
   @cLine01 = 'TOTE CORRECTION', 
   @cLine02 = '',
   @cLine03 = 'BATCH:',
   @cLine04 = '%15i01',  
   @cLine05 = '',     
   @cLine06 = 'TOTE:', 
   @cLine07 = '%18i02', 
   @cLine14 = '%e'

-- 601 = Batch, Tote, RefNo
DELETE rdt.RDTScn WHERE Scn = 601 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 601, 'ENG', 
   @cLine01 = 'TOTE CORRECTION', 
   @cLine02 = 'BATCH:',
   @cLine03 = '%15d01',
   @cLine04 = '',  
   @cLine05 = 'TOTE:', 
   @cLine06 = '%18d02', 
   @cLine07 = 'REFNO:', 
   @cLine08 = '%20i03', 
   @cLine14 = '%e'

-- 602 = Batch, Tote, RefNo, SKU/UPC
DELETE rdt.RDTScn WHERE Scn = 602 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 602, 'ENG', 
   @cLine01 = 'TOTE CORRECTION', 
   @cLine02 = 'BATCH:',
   @cLine03 = '%15d01',
   @cLine04 = '', 
   @cLine05 = 'TOTE:', 
   @cLine06 = '%18d02',
   @cLine07 = 'REFNO:', 
   @cLine08 = '%20d03', 
   @cLine09 = 'SKU/UPC:', 
   @cLine10 = '%20i04', 
   @cLine14 = '%e'

-- 603 = Batch, Tote, RefNo, SKU/UPC, SKU Desc, QTY, Reason code
DELETE rdt.RDTScn WHERE Scn = 603 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 603, 'ENG', 
   @cLine01 = 'TOTE CORRECTION', 
   @cLine02 = 'BATCH:',
   @cLine03 = '%15d01',
   @cLine04 = 'TOTE:', 
   @cLine05 = '%18d02', 
   @cLine06 = 'REFNO:', 
   @cLine07 = '%20d03', 
   @cLine08 = 'SKU/UPC:', 
   @cLine09 = '%20d04', 
   @cLine10 = '%20d05', 
   @cLine11 = '%20d06',
   @cLine12 = 'QTY: %05i07', 
   @cLine13 = 'REASON: %10i08', 
   @cLine14 = '%e'

-- 604 = Message screen
DELETE rdt.RDTScn WHERE Scn = 604 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 604, 'ENG', 
   @cLine01 = '', 
   @cLine02 = 'MAKE THE ADJUSTMENT?', 
   @cLine03 = '', 
   @cLine04 = '1 - YES', 
   @cLine05 = '2 - NO', 
   @cLine06 = '', 
   @cLine07 = 'OPTION: %01i01', 
   @cLine08 = '', 
   @cLine14 = '%e'

-- 605 = Message screen
DELETE rdt.RDTScn WHERE Scn = 605 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 605, 'ENG', 
   @cLine02 = 'Tote adjusted', 
   @cLine03 = 'successfully', 
   @cLine04 = '', 
   @cLine05 = 'Press ENTER or ESC', 
   @cLine06 = 'to continue', 
   @cLine14 = '%e'