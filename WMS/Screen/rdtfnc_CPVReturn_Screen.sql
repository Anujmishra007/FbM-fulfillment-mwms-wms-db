
-- 5250 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 5250 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5250, 'ENG'
   ,@cLine01 = 'ASN:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine04 = 'EXTERN ASN:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 630

-- 5251 = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 5251 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5251, 'ENG'
   ,@cLine01 = 'ASN:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'EXTERN ASN:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'TO LOC:'
   ,@cLine08 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 630

-- 5252 = LOT screen
DELETE rdt.RDTScn WHERE Scn = 5252 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5252, 'ENG'
   ,@cLine01 = 'LOT:'
   ,@cLine02 = '%60i01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = ''
   ,@cLine10 = 'SKU QTY: %10d06'
   ,@cLine11 = ''
   ,@cLine12 = 'SCAN: %10d07'
   ,@cLine14 = '%e'
   ,@nFunc = 630
   
-- 5253 = Multi SKU screen
DELETE rdt.RDTScn WHERE Scn = 5253 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5253, 'ENG'
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
   ,@nFunc = 630

/*
-- 5253 = Multi SKU screen
DELETE rdt.RDTScn WHERE Scn = 5253 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5253, 'ENG'
   ,@cLine01 = 'SKU 1/2/3:    OPT:%02i13'
   ,@cLine02 = '%20d02' -- %15d01 (hidden StorerKey field for SKU1)
   ,@cLine03 = '%20d03' 	
   ,@cLine04 = '%20d04' 	
   ,@cLine05 = '' 	   
   ,@cLine06 = '%20d06' -- %15d05 (hidden StorerKey field for SKU2)
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = ''       
   ,@cLine10 = '%20d10' -- %15d09 (hidden StorerKey field for SKU3)
   ,@cLine11 = '%20d11'
   ,@cLine12 = '%20d12' 
   ,@cLine13 = '(1-3=SKU ENTER=NEXT)'
   ,@cLine14 = '%e'
   ,@nFunc = 630
*/