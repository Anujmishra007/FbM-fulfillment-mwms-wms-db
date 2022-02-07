-- 2170 = TRLR ID screen
DELETE rdt.RDTScn WHERE Scn = 2170 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2170, 'ENG',
    @cLine01 = 'TRLR ID'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
 
-- 2171 = TRLR ID, Option
DELETE rdt.RDTScn WHERE Scn = 2171 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2171, 'ENG',
    @cLine01 = 'TRLRID: %10d01'
   ,@cLine03 = 'SEAL VEHICLE'
   ,@cLine04 = '1 = YES  5 = NO %01i02'
   ,@cLine14 = '%e'
 
-- 2172 = TRLR ID,# TOTES, PRINT M'FEST
DELETE rdt.RDTScn WHERE Scn = 2172 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2172, 'ENG',
    @cLine01 = 'TRLRID: %10d01'
   ,@cLine02 = '# TOTE: %10d02'
   ,@cLine03 = 'PRINT MANIFEST'
   ,@cLine04 = '1 = YES  5 = NO %01i03'
   ,@cLine05 = '%20d05'
   ,@cLine14 = '%e'

-- 2173 = RE-PRINT M'FEST
DELETE rdt.RDTScn WHERE Scn = 2173 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2173, 'ENG',
    @cLine01 = 'MANIFEST PRINTED'
   ,@cLine02 = 'REPRINT?'
   ,@cLine04 = '1 = YES  5 = NO %01i01'
   ,@cLine14 = '%e'