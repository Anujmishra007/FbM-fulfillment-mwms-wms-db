--rdt_PalletPack_Confirm
rdt.rdtDropMsg 138051 , 138100

execute rdt.rdtAddMsg 138051, 10, '38051^Fully Packed',     'us_english', 835
execute rdt.rdtAddMsg 138052, 10, '38052^Ins Packh Fail',   'us_english', 835
execute rdt.rdtAddMsg 138053, 10, '38053^Gen Label Fail',   'us_english', 835
execute rdt.rdtAddMsg 138054, 10, '38054^InsPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138055, 10, '38055^UpdPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138056, 10, '38056^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138057, 10, '38057^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138058, 10, '38058^GetDetKeyFail',    'us_english', 835
execute rdt.rdtAddMsg 138059, 10, '38059^Ins PDtl Fail',    'us_english', 835
execute rdt.rdtAddMsg 138060, 10, '38060^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138061, 10, '38061^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138062, 10, '38062^Ins PInfo Fail',   'us_english', 835
execute rdt.rdtAddMsg 138063, 10, '38063^Upd PInfo Fail',   'us_english', 835
execute rdt.rdtAddMsg 138064, 10, '38062^InsPltInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 138065, 10, '38063^InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 138066, 10, '38062^InsPldInfoFail',   'us_english', 835

--WMS-17164
execute rdt.rdtAddMsg 138067, 10, '38067^InsPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 138068, 10, '38068^Ins PInfo Fail',   'us_english', 835
execute rdt.rdtAddMsg 138069, 10, '38069^InsPltInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 138070, 10, '38070^InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 138071, 10, '38071^InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 138072, 10, '38072^Upd PInfo Fail',   'us_english', 835


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 138051 AND 138100