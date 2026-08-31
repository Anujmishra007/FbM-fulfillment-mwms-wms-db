-- 6916 = REXLOG Check Prompt Screen for Michelin VN
-- FCR-13976: New screen to prompt user to enable/disable REXLOG check after TO ID input

DELETE rdt.RDTScn WHERE Scn = 6916 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6916, 'ENG'
   ,@cLine01 = N'ENABLE REXLOG CHECK?'
   ,@cLine02 = N''
   ,@cLine03 = N'1 = YES'
   ,@cLine04 = N'2 = NO'
   ,@cLine05 = N''
   ,@cLine06 = N'OPTION: %01i01'
   ,@cLine14 = N'%e'
   ,@nfunc   = 600
