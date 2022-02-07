-- 2980 = DropID screen
DELETE rdt.RDTScn WHERE Scn = 2980 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2980, 'ENG'
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'LAST SCANNED ID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'PRINT GS1 LABEL: %01i03'
   ,@cLine08 = 'PRINT PACK LIST: %01i04'
   ,@cLine09 = ''
   ,@cLine10 = '1=YES BLANK=NO'
   ,@cLine14 = '%e'
   ,@nFunc = 1790
   
-- 2981 = Weight screen
DELETE rdt.RDTScn WHERE Scn = 2981 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2981, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'WEIGHT: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1790

-- 2982 = Reprint packing list screen
DELETE rdt.RDTScn WHERE Scn = 2982 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2982, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PACKING LIST PRINTED'
   ,@cLine03 = 'REPRINT?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1790

-- 2983 = Reprint GS1 label screen
DELETE rdt.RDTScn WHERE Scn = 2983 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2983, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'GS1 LABEL PRINTED'
   ,@cLine03 = 'REPRINT?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1790