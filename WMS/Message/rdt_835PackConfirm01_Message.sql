--rdt_835PackConfirm01
rdt.rdtDropMsg 138651 , 138700	

execute rdt.rdtAddMsg 138651, 10, '38651^Fully Packed',     'us_english', 835
execute rdt.rdtAddMsg 138652, 10, '38652^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138653, 10, '38653^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138654, 10, '38654^GetDetKeyFail',    'us_english', 835
execute rdt.rdtAddMsg 138655, 10, '38655^Ins PDtl Fail',    'us_english', 835
execute rdt.rdtAddMsg 138656, 10, '38656^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138657, 10, '38657^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138658, 10, '38658^Ins Packh Fail',   'us_english', 835
execute rdt.rdtAddMsg 138659, 10, '38659^Gen Label Fail',   'us_english', 835
execute rdt.rdtAddMsg 138660, 10, '38660^InsPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138661, 10, '38661^UpdPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138662, 10, 'Order Complete',         'us_english', 835
execute rdt.rdtAddMsg 138663, 10, 'Packing.',               'us_english', 835


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 138651 AND 138700	