-- scn no 6841
-- FCR-10102 - NYE018

DELETE rdt.RDTScn WHERE Scn = 6841 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6841, 'ENG'
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%30i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1868