
-- 5260 = OrderKey screen
DELETE rdt.RDTScn WHERE Scn = 5260 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5260, 'ENG'
   ,@cLine01 = 'ORDER KEY:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine12 = 'RESET: %01i02 (1=YES)'
   ,@cLine14 = '%e'
   ,@nFunc = 631

-- 5261 = LOT screen
DELETE rdt.RDTScn WHERE Scn = 5261 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5261, 'ENG'
   ,@cLine01 = 'ORDER KEY:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'LOT:'
   ,@cLine05 = '%60i02'
   ,@cLine06 = 'SKU:'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d08'   --WMS-17552
   ,@cLine09 = '%20d04'
   ,@cLine10 = '%20d05'
   ,@cLine11 = '%20d06'
   ,@cLine12 = ''
   ,@cLine13 = 'SCAN/TOTAL: %08d07'
   ,@cLine14 = '%e'
   ,@nFunc = 631
   
-- 5262 = Close order screen
DELETE rdt.RDTScn WHERE Scn = 5262 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5262, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CLOSE ORDER?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 631
   
-- 5263 = reset screen
DELETE rdt.RDTScn WHERE Scn = 5263 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5263, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'RESET ORDER?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = DELETE ALL'
   ,@cLine05 = '3 = DELETE TEMP'
   ,@cLine06 = '9 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 631
   
-- 5264 = Multi SKU screen
DELETE rdt.RDTScn WHERE Scn = 5264 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5264, 'ENG'
   ,@cLine01 = 'SKU 1/2:      OPT:%02i13'
   ,@cLine02 = '%20d02'  -- %15d01 (hidden StorerKey field for SKU1)
   ,@cLine03 = '%20d11' --WMS-17552 
   ,@cLine04 = '%20d03' 	
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '' 	   
   ,@cLine08 = '%20d07' -- %15d06 (hidden StorerKey field for SKU2)
   ,@cLine09 = '%20d12' --WMS-17552 
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20d10'	   
   ,@cLine13 = '(1-2=SKU ENTER=NEXT)'
   ,@cLine14 = '%e'
   ,@nFunc = 631
   
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN 5260 AND 5264