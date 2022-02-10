-- 2100  = Area screen
DELETE rdt.RDTScn WHERE Scn = 2100 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2100, 'ENG',
    @cLine01 = 'TASK MANAGER'
   ,@cLine03 = 'AREA: '
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   
-- 2101  = Area screen
DELETE rdt.RDTScn WHERE Scn = 2101 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2101, 'ENG',
    @cLine01 = 'TASK MANAGER'
   ,@cLine03 = 'TOTE NO / CASE ID: '
   ,@cLine04 = '%18i01'
   ,@cLine06 = 'Leave BLANK and'
   ,@cLine07 = 'press ENTER to'
   ,@cLine08 = 'retrieve task'
   ,@cLine14 = '%e'   

-- 2108  = Take pallet wood screen
DELETE rdt.RDTScn WHERE Scn = 2108 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2108, 'ENG',
    @cLine01 = 'TASK MANAGER'
   ,@cLine03 = 'Please take an empty'
   ,@cLine04 = 'Pallet'
   ,@cLine06 = 'Press ENTER to'
   ,@cLine07 = 'continue'
   ,@cLine14 = '%e'

-- 2109  = Reason Code screen
DELETE rdt.RDTScn WHERE Scn = 2109 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2109, 'ENG',
    @cLine01 = 'TASK MANAGER'
   ,@cLine03 = 'REASON CODE: '
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   
-- 2108  = Take pallet wood screen
DELETE rdt.RDTScn WHERE Scn = 2107 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2107, 'ENG',
    @cLine01 = 'TASK MANAGER'
   ,@cLine03 = 'Please take an empty'
   ,@cLine04 = 'Tote'
   ,@cLine06 = 'Press ENTER to'
   ,@cLine07 = 'continue'
   ,@cLine14 = '%e'   
   

   
   
   