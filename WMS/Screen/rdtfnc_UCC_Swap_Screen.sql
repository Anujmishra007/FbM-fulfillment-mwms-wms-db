/*
   UCC Swap
*/

-- 3170 = ASN
DELETE rdt.RDTScn WHERE Scn = 3170 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3170, 'ENG', 
   @cLine01 = 'ASN: %10i01', 
   @cLine02 = '', 
   @cLine03 = 'OR', 
   @cLine04 = '', 
   @cLine05 = 'NEW UCC:', 
   @cLine06 = '%20i02', 
   @cLine14 = '%e', 
   @nFunc = 527

-- 3171 = OLD UCC
DELETE rdt.RDTScn WHERE Scn = 3171 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3171, 'ENG', 
   @cLine01 = 'OLD UCC:', 
   @cLine02 = '%20i01', 
   @cLine14 = '%e', 
   @nFunc = 527

-- 3172 = NEW UCC
DELETE rdt.RDTScn WHERE Scn = 3172 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3172, 'ENG', 
   @cLine01 = 'OLD UCC:', 
   @cLine02 = '%20d01', 
   @cLine03 = '', 
   @cLine04 = 'NEW UCC:', 
   @cLine05 = '%20i02', 
   @cLine14 = '%e', 
   @nFunc = 527

-- 3173 = NEW UCC
DELETE rdt.RDTScn WHERE Scn = 3173 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3173, 'ENG', 
   @cLine01 = 'OLD UCC:', 
   @cLine02 = '%20d01', 
   @cLine03 = '', 
   @cLine04 = 'NEW UCC:', 
   @cLine05 = '%20d02', 
   @cLine06 = '', 
   @cLine07 = 'LOC: %10d03', 
   @cLine08 = '', 
   @cLine09 = 'SWAP/TTL: %10d04', 
   @cLine14 = '%e', 
   @nFunc = 527
   
-- 3174 = SKU
DELETE rdt.RDTScn WHERE Scn = 3174 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3174, 'ENG', 
   @cLine01 = 'NEW SKU:', 
   @cLine02 = '%20d01', 
   @cLine03 = '%20d02', 
   @cLine04 = '%20d03', 
   @cLine05 = '', 
   @cLine06 = 'WEIGHT: %10i04', 
   @cLine07 = '', 
   @cLine08 = 'CUBE:   %10i05', 
   @cLine09 = '', 
   @cLine10 = 'ODD SIZE: %01i06 1=Y 2=N', 
   @cLine14 = '%e', 
   @nFunc = 527

