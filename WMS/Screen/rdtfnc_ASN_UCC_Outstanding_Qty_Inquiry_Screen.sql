-- 1900  = ASN screen
DELETE rdt.RDTScn WHERE Scn = 1900 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1900, 'ENG',
    @cLine01 = 'ASN:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
 
-- 1901 = ASN, TTL SCN Qty, TTL EXP Qty... screen
DELETE rdt.RDTScn WHERE Scn = 1901 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1901, 'ENG',
    @cLine01 = 'ASN:' 
   ,@cLine02 = '%10d01'
   ,@cLine03 = '             %05d02'
   ,@cLine04 = 'TTL SCN QTY: %05d03'
   ,@cLine05 = 'TTL EXP QTY: %05d04'
   ,@cLine06 = 'SKU:'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '         %05d07'
   ,@cLine10 = 'SCN QTY: %05d08'
   ,@cLine11 = 'EXP QTY: %05d09'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'