--5810-5819,@nFunc = 1845
-- 5810 = ASN
DELETE rdt.RDTScn WHERE Scn = 5810 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5810, 'ENG'
   ,@cLine01 = 'PALLET ID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1845

-- 5811 = Loc
DELETE rdt.RDTScn WHERE Scn = 5811 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5811, 'ENG'
   ,@cLine01 = 'PALLET ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SUGGESTED LOC:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'TO LOC:'
   ,@cLine08 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1845
   
SELECT * FROM rdt.rdtscn (NOLOCK) WHERE scn BETWEEN 5810 AND 5819