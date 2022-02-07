
-- Station, position, carton
DELETE rdt.RDTScn WHERE Scn = 4604 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4604, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ASN:'   
   ,@cLine03 = '%20i01'
   ,@cLine04 = 'Position:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = 'LogicalPos:'
   ,@cLine07 = '%20d03'
   ,@cLine08 = 'Loc:'
   ,@cLine09 = '%20d05'
   ,@cLine10 = 'CartonID:'
   ,@cLine11 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 803
