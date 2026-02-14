-- rdt_825ExtScn03 - Confirmation Screen (Screen 4)
-- FCR-9672 - Schneider Electric

-- 6829 = Confirmation Screen (Display only)
DELETE rdt.RDTScn WHERE Scn = 6829 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6829, 'ENG'
   ,@cLine01 = N'Confirmation of entered values'
   ,@cLine02 = ''
   ,@cLine03 = N'LENGTH: %12d02'
   ,@cLine04 = N'WIDTH:  %12d03'
   ,@cLine05 = N'HEIGHT: %12d04'
   ,@cLine06 = N'WEIGHT: %12d05'
   ,@cLine14 = N'%e'
   ,@nFunc = 825

