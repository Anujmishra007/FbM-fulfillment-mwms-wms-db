/*
   UCC outbound inquiry
*/

-- 686 = LoadKey
DELETE rdt.RDTScn WHERE Scn = 686 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 686, 'ENG', 
   @cLine01 = 'LOADKEY: %10i01', 
   @cLine14 = '%e'

-- 687 = LoadKey, counter, UCC, QTY, LOC
DELETE rdt.RDTScn WHERE Scn = 687 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 687, 'ENG', 
   @cLine01 = 'LOADKEY: %10d01', 
   @cLine02 = '', 
   @cLine03 = 'TOTAL  : %05d02', 
   @cLine04 = 'SCAN   : %05d03', 
   @cLine05 = 'REMAIN : %05d04', 
   @cLine06 = '', 
   @cLine08 = 'REMAIN UCC: %08d05', 
   @cLine09 = '%20d06', 
   @cLine10 = 'QTY: %05d07', 
   @cLine11 = 'LOC: %10d08', 
   @cLine12 = '', 
   @cLine14 = '%e'

