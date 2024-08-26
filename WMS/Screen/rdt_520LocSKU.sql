-- 924 
DELETE rdt.RDTScn WHERE Scn = 924 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 924, 'ENG'
   ,@cLine01 = 'FROM LOC:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%32i02'
   ,@cLine14 = '%e'
   ,@nFunc = 520
   

