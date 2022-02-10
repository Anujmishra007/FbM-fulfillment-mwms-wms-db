-- 3940 - 3949
-- 3940 = Tote screen

DELETE rdt.RDTScn WHERE Scn = 3940 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3940, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'ENTER ZONE:'
   ,@cLine04 = '%10i01'
   ,@cLine06 = 'Label Printer:'
   ,@cLine07 = '%10i02'
   ,@cLine09 = 'Paper Printer:'
   ,@cLine10 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1811

DELETE rdt.RDTScn WHERE Scn = 3941 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3941, 'ENG',
    @cLine01 = 'SCAN TOTE: '
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1811
 
