
-- Drop ID, counter
DELETE rdt.RDTScn WHERE Scn = 4602 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4602, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'DROP ID: '
   ,@cLine03 = '%20i01'
   ,@cLine04 = ''
   ,@cLine05 = 'DROP ID SCANNED: '
   ,@cLine06 = '%05d02'
   ,@cLine07 = '%20d03'  --WMS-17331
   ,@cLine08 = '%20d04'  --WMS-17331
   ,@cLine09 = '%20d05'  --WMS-17331
   ,@cLine10 = '%20d06'  --WMS-17331
   ,@cLine11 = '%20d07'  --WMS-17331
   ,@cLine14 = '%e'
   ,@nFunc = 803

SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn = 4602