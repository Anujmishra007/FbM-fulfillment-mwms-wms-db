-- 5280 = Kit screen
DELETE rdt.RDTScn WHERE Scn = 5280 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5280, 'ENG'
   ,@cLine01 = 'KIT KEY:' 
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine12 = 'RESET: %01i02 (1=YES)'
   ,@cLine14 = '%e'      
   ,@nFunc = 632

-- 5281 = Parent screen
DELETE rdt.RDTScn WHERE Scn = 5281 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5281, 'ENG'
   ,@cLine01 = 'KIT KEY:' 
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'PARENT SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = ''
   ,@cLine10 = 'QTY:'
   ,@cLine11 = '%05i06'
   ,@cLine14 = '%e'      
   ,@nFunc = 632
   
-- 5282 = Child screen
DELETE rdt.RDTScn WHERE Scn = 5282 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5282, 'ENG'
   ,@cLine01 = 'KIT KEY:' 
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'CHILD SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = ''
   ,@cLine10 = 'CHILD LOT:'
   ,@cLine11 = '%60i06'
   ,@cLine12 = ''
   ,@cLine13 = 'SCAN: %10d07'
   ,@cLine14 = '%e'   
   ,@nFunc = 632
    
-- 5283 = Parent SNO screen
DELETE rdt.RDTScn WHERE Scn = 5283 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5283, 'ENG'
   ,@cLine01 = 'PARENT LOT:'
   ,@cLine02 = '%60i01'
   ,@cLine14 = '%e'
   ,@nFunc = 632
   
-- 5284 = Close kit screen
DELETE rdt.RDTScn WHERE Scn = 5284 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5284, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CLOSE KIT?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'   
   ,@nFunc = 632
   
-- 5285 = reset screen
DELETE rdt.RDTScn WHERE Scn = 5285 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5285, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'RESET KIT?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 632
   
-- 5286 = Multi SKU screen
DELETE rdt.RDTScn WHERE Scn = 5286 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5286, 'ENG'
   ,@cLine01 = 'SKU 1/2:      OPT:%02i13'
   ,@cLine02 = ''
   ,@cLine03 = '%20d02' -- %15d01 (hidden StorerKey field for SKU1)
   ,@cLine04 = '%20d03' 	
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '' 	   
   ,@cLine08 = '%20d07' -- %15d06 (hidden StorerKey field for SKU2)
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine12 = '' 	   
   ,@cLine13 = '(1-2=SKU ENTER=NEXT)'
   ,@cLine14 = '%e'
   ,@nFunc = 632