-- 750 = User screen
DELETE rdt.RDTScn WHERE Scn = 750 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 750, 'ENG',
    @cLine01 = 'RESET USER'
   ,@cLine02 = ''
   ,@cLine03 = 'USER: %10i01'
   ,@cLine14 = '%e'
   
-- 751 = Message screen
DELETE rdt.RDTScn WHERE Scn = 751 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 751, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'Successful reset'
   ,@cLine03 = 'user'
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   