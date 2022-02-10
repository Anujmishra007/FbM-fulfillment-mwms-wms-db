
DELETE rdt.RDTScn WHERE Scn = 2240 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2240, 'ENG', 
   @cLine01 = 'EVENTLOG TRACKING', -- (ChewKP01) 
   @cLine03 = '%20d01',            -- (ChewKP01) 
   @cLine04 = '%20i02',            -- (ChewKP01) 
   @cLine05 = '%20d03',            -- (ChewKP01) 
   @cLine06 = '%20i04',            -- (ChewKP01) 
   @cLine07 = '%20d05',            -- (ChewKP01) 
   @cLine08 = '%20i06',            -- (ChewKP01) 
   @cLine12 = 'ENTER = Confirm',
   @cLine14 = '%e'

