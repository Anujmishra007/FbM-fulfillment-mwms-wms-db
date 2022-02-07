--rdt_834ExtPack02
rdt.rdtDropMsg 139451 , 139500

execute rdt.rdtAddMsg 139451, 10, '39451^PickSlip req',     'us_english', 834
execute rdt.rdtAddMsg 139452, 10, '39452^OffSetPDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139453, 10, '39453^OffSetPDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139454, 10, '39454^GetDetKeyFail',    'us_english', 834
execute rdt.rdtAddMsg 139455, 10, '39455^Ins PDtl Fail',    'us_english', 834
execute rdt.rdtAddMsg 139456, 10, '39456^INS RefKeyFail',   'us_english', 834
execute rdt.rdtAddMsg 139457, 10, '39457^OffSetPDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139458, 10, '39458^OffSetPDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139459, 10, '39459^InsPackHdrFail',   'us_english', 834
execute rdt.rdtAddMsg 139460, 10, '39460^GenLabelNoFail',   'us_english', 834
execute rdt.rdtAddMsg 139461, 10, '39461^InsPackDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139462, 10, '39462^UpdPackDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139463, 10, '39463^INSPackInfFail',   'us_english', 834
execute rdt.rdtAddMsg 139464, 10, '39464^UPDPackInfFail',   'us_english', 834
execute rdt.rdtAddMsg 139465, 10, '39465^UpdPackDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139466, 10, '39466^PackCfm Fail',     'us_english', 834
execute rdt.rdtAddMsg 139467, 10, '39467^Scan Out Fail',    'us_english', 834
execute rdt.rdtAddMsg 139468, 10, '39468^Assign Lbl Err',   'us_english', 834
execute rdt.rdtAddMsg 139469, 10, '39469^InsPackDtlFail',   'us_english', 834

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 139451 AND 139500