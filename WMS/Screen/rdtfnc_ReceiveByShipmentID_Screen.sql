-- 3540 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 3540 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3540, 'ENG'
   ,@cLine01 = 'SHIPMENT ID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 589
   
-- 3541 = CARTON NO screen
DELETE rdt.RDTScn WHERE Scn = 3541 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3541, 'ENG'
   ,@cLine01 = 'SHIPMENT ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CARTON LABEL:'
   ,@cLine04 = '%20i02'
   ,@cLine05 = 'TO LOC:'
   ,@cLine06 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 589

-- 3542 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 3542 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3542, 'ENG'
   ,@cLine01 = 'SHIPMENT ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CARTON LABEL:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'ASN:'
   ,@cLine06 = '%10d03'
   ,@cLine07 = 'SKU:'
   ,@cLine08 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 589

-- 3543 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 3543 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3543, 'ENG'
   ,@cLine01 = 'SHIPMENT ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CARTON LABEL:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'ASN:'
   ,@cLine06 = '%10d03'
   ,@cLine07 = 'SKU:'
   ,@cLine08 = '%20d04'
   ,@cLine10 = 'QTY:    %10d05'
   ,@cLine11 = '%05i06'
   ,@cLine14 = '%e'
   ,@nFunc = 589
   
-- 3544 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 3544 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3544, 'ENG'
   ,@cLine01 = 'TO LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine04 = '1 = NEW SKU'
   ,@cLine05 = '2 = NEW CARTON'
   ,@cLine07 = 'OPT: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 589

-- 3545 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 3545 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3545, 'ENG'
   ,@cLine01 = 'CARTON LABEL:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine06 = 'SCA QTY: %05d03'
   ,@cLine07 = 'EXP QTY: %05d04'
   ,@cLine09 = '1 = OK   2 = ESC'
   ,@cLine10 = 'OPT: %01i05'
   ,@cLine14 = '%e'
   ,@nFunc = 589
   
-- 3546 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 3546 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3546, 'ENG'
   ,@cLine01 = 'CONFIRM RECEIVE'
   ,@cLine02 = 'THIS CARTON'
   ,@cLine03 = '%20d01'
   ,@cLine05 = '1 = OK   2 = ESC'
   ,@cLine06 = 'OPT: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 589