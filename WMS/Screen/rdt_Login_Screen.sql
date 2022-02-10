-- 0 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 0 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 0, 'ENG',
    @cLine01 = 'IP: %dbip'
   ,@cLine02 = 'SV: %dbsrv'
   ,@cLine03 = 'DB: %dbname'
   ,@cLine04 = ''
   ,@cLine05 = 'Username:%10i01'
   ,@cLine06 = 'Password:%10p02'
   ,@cLine07 = ' '
   ,@cLine08 = '%today'
   ,@cLine09 = ''
   ,@cLine10 = '%e'