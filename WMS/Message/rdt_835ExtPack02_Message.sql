--rdt_835ExtPack02
rdt.rdtDropMsg 164101 , 164150

execute rdt.rdtAddMsg 164101, 10, '64101^Fully Packed',     'us_english', 835
execute rdt.rdtAddMsg 164102, 10, '64102^Ins Packh Fail',   'us_english', 835
execute rdt.rdtAddMsg 164103, 10, '64103^Gen Label Fail',   'us_english', 835
execute rdt.rdtAddMsg 164104, 10, '64104^InsPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 164105, 10, '64105^UpdPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 164106, 10, '64106^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 164107, 10, '64107^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 164108, 10, '64108^GetDetKeyFail',    'us_english', 835
execute rdt.rdtAddMsg 164109, 10, '64109^Ins PDtl Fail',    'us_english', 835
execute rdt.rdtAddMsg 164110, 10, '64110^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 164111, 10, '64111^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 164112, 10, '64112^Ins PInfo Fail',   'us_english', 835
execute rdt.rdtAddMsg 164113, 10, '64113^Upd PInfo Fail',   'us_english', 835
execute rdt.rdtAddMsg 164114, 10, '64114^InsPltInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 164115, 10, '64115^InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 164116, 10, '64116^InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 164117, 10, '64117^InsCtnTrk Fail',   'us_english', 835
execute rdt.rdtAddMsg 164118, 10, '64118^PackCfm Fail',     'us_english', 835
execute rdt.rdtAddMsg 164119, 10, '64119^Scan Out Fail',    'us_english', 835
execute rdt.rdtAddMsg 164120, 10, '64120^UpdSOStat Fail',   'us_english', 835
execute rdt.rdtAddMsg 164121, 10, '64121^UpdSOStat Fail',   'us_english', 835
execute rdt.rdtAddMsg 164122, 10, '64122^InsPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 164123, 10, '64123^No Pickslip',      'us_english', 835
execute rdt.rdtAddMsg 164124, 10, '64124^Fail scan-in',     'us_english', 835


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 164101 AND 164150