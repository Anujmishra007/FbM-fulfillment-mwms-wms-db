-- 3570 = Multi SKU screen
DELETE rdt.RDTScn WHERE Scn = 3570 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3570, 'ENG'
   ,@cLine01 = 'SKU 1/2/3:     OPT:%01i13'
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
