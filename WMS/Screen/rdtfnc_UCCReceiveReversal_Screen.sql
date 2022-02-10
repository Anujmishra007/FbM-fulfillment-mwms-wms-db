-- Scn = 1050. ASN
DELETE rdt.RDTScn WHERE Scn = 1050 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1050, 'ENG', 
   @cLine01 = 'ASN: %10i01',
   @cLine14 = '%e'

-- Scn = 1051. LOC
DELETE rdt.RDTScn WHERE Scn = 1051 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1051, 'ENG', 
   @cLine01 = 'ASN: %10d01',
   @cLine02 = 'LOC: %10i02',
   @cLine14 = '%e'
   
-- Scn = 1052. ID
DELETE rdt.RDTScn WHERE Scn = 1052 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1052, 'ENG', 
   @cLine01 = 'ASN: %10d01',
   @cLine02 = 'LOC: %10d02',
   @cLine03 = 'ID: ',
   @cLine04 = '%18i03',
   @cLine14 = '%e'
   
-- Scn = 1053. UCC
DELETE rdt.RDTScn WHERE Scn = 1053 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1053, 'ENG', 
   @cLine01 = 'ASN: %10d01',
   @cLine02 = 'LOC: %10d02',
   @cLine03 = 'ID: ',
   @cLine04 = '%18d03',
   @cLine05 = 'UCC: ',
   @cLine06 = '%20i04',
   @cLine14 = '%e'
   
-- Scn = 1054. Display Record
DELETE rdt.RDTScn WHERE Scn = 1054 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1054, 'ENG', 
   @cLine01 = 'UCC: %09d01 OPT:%01i02',
   @cLine02 = '%20d03',
   @cLine03 = 'SKU:        PPK: %03d04',
   @cLine04 = '%20d05',
   @cLine05 = '%20d06',
   @cLine06 = '%20d07',
   @cLine07 = 'QTY:%05d08  UOM:%05d09',
   @cLine08 = '1 %18d10',   
   @cLine09 = '2 %18d11',   
   @cLine10 = '3 %18d12',
   @cLine11 = '4 %18d13',  
   @cLine12 = '5 %18d14',  
   @cLine13 = '1=EDT 2=DEL ENTR=NXT',
   @cLine14 = '%e'

-- 1055. New Qty
DELETE rdt.RDTScn WHERE Scn = 1055 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1055, 'ENG', 
   @cLine01 = 'UCC: %09d01',
   @cLine02 = '%20d02',
   @cLine03 = 'SKU:        PPK: %03d03',
   @cLine04 = '%20d04',
   @cLine05 = '%20d05',
   @cLine06 = '%20d06',
   @cLine07 = 'QTY:%05d07  UOM:%05d08',
   @cLine08 = 'New: %05i09',   
   @cLine09 = '1 %18d10',   
   @cLine10 = '2 %18d11',   
   @cLine11 = '3 %18d12',
   @cLine12 = '4 %18d13',  
   @cLine13 = '5 %18d14',  
   @cLine14 = '%e'

-- 1056. Dialogue Option
DELETE rdt.RDTScn WHERE Scn = 1056 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1056, 'ENG', 
   @cLine01 = '%20d01',
   @cLine02 = '1=YES',
   @cLine03 = '2=NO',
   @cLine05 = 'OPTION: %01i02',      
   @cLine14 = '%e'         

-- 1057. Message
DELETE rdt.RDTScn WHERE Scn = 1057 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1057, 'ENG', 
   @cLine01 = '%20d01',
   @cLine02 = '%20d02',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine14 = '%e'
