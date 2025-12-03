
-- 6730 = SKU screen
-- UWP-45094
DELETE rdt.RDTScn WHERE Scn = 6730 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6730, 'ENG',
    @cLine01 = 'SKU STYLE INQUIRY'
   ,@cLine02 = ''
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%30i01'
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 724
 
-- 6731 = Result screen
DELETE rdt.RDTScn WHERE Scn = 6731 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6731, 'ENG',
    @cLine01 = 'SKU:        %20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = 'LOC: %10d05'
   ,@cLine06 = 'ID: %18d06'
   ,@cLine07 = '         %11d07'
   ,@cLine08 = 'QTY TTL: %11d08'
   ,@cLine09 = 'QTY HLD: %11d09'
   ,@cLine10 = 'QTY ALC: %11d10'
   ,@cLine11 = 'QTY PCK: %11d11'
   ,@cLine12 = 'QTY RPL: %11d12'
   ,@cLine13 = 'QTY AVL: %11d13'
   ,@cLine14 = '%e'
   ,@nFunc = 724
 
-- 6732 = Result screen
DELETE rdt.RDTScn WHERE Scn = 6732 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6732, 'ENG',
    @cLine01 = 'Lottable:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 724
 
