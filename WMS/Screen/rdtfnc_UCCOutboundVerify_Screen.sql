/*
   UCC outbound verification
*/

-- 680 = LoadKey (input), ExternOrderKey
DELETE rdt.RDTScn WHERE Scn = 680 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 680, 'ENG', 
   @cLine01 = 'LOADKEY: %10i01', 
   @cLine14 = '%e'

-- 681 = LoadKey, ExternOrderKey
DELETE rdt.RDTScn WHERE Scn = 681 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 681, 'ENG', 
   @cLine01 = 'LOADKEY: %10d01', 
   @cLine02 = '', 
   @cLine03 = 'EXTERNORDERKEY:', 
   @cLine04 = '%20d03', 
   @cLine05 = '%20d04', 
   @cLine06 = '%20d05', 
   @cLine07 = '%20d06', 
   @cLine08 = '%20d07', 
   @cLine09 = '%20d08', 
   @cLine10 = '%20d09', 
   @cLine11 = '%20d10', 
   @cLine12 = '%20d11', 
   @cLine13 = '%20d12', 
   @cLine14 = '%e'

-- 682 = UCC, QTY
DELETE rdt.RDTScn WHERE Scn = 682 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 682, 'ENG', 
   @cLine01 = 'LOADKEY: %10d01', 
   @cLine02 = '', 
   @cLine03 = 'UCC:', 
   @cLine04 = '%20i02', 
   @cLine05 = '', 
   @cLine06 = 'QTY: %05d03', 
   @cLine07 = '', 
   @cLine08 = '', 
   @cLine09 = '', 
   @cLine10 = '', 
   @cLine11 = 'SCAN/TOTAL:', 
   @cLine12 = '%20d04', 
   @cLine13 = '', 
   @cLine14 = '%e'

-- 683 = Message
DELETE rdt.RDTScn WHERE Scn = 683 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 683, 'ENG', 
   @cLine01 = '', 
   @cLine02 = 'NOT ALL UCC SCANNED', 
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
