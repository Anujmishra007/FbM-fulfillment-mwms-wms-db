--rdt_835ExtPack01
 rdt.rdtDropMsg 140551 , 140600

execute rdt.rdtAddMsg 140551, 10, '40551^Fully Packed',     'us_english', 835
execute rdt.rdtAddMsg 140552, 10, '40552^Ins Packh Fail',   'us_english', 835
execute rdt.rdtAddMsg 140553, 10, '40553^Gen Label Fail',   'us_english', 835
execute rdt.rdtAddMsg 140554, 10, '40554^InsPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 140555, 10, '40555^UpdPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 140556, 10, '40556^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 140557, 10, '40557^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 140558, 10, '40558^GetDetKeyFail',    'us_english', 835
execute rdt.rdtAddMsg 140559, 10, '40559^Ins PDtl Fail',    'us_english', 835
execute rdt.rdtAddMsg 140560, 10, '40560^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 140561, 10, '40561^OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 140562, 10, '40562^Ins PInfo Fail',   'us_english', 835
execute rdt.rdtAddMsg 140563, 10, '40563^Upd PInfo Fail',   'us_english', 835
execute rdt.rdtAddMsg 140564, 10, '40564^InsPltInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 140565, 10, '40565^InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 140566, 10, '40566^InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 140567, 10, '40567^InsCtnTrk Fail',   'us_english', 835
execute rdt.rdtAddMsg 140568, 10, '40568^PackCfm Fail',     'us_english', 835
execute rdt.rdtAddMsg 140569, 10, '40569^Scan Out Fail',    'us_english', 835
execute rdt.rdtAddMsg 140570, 10, '40570^UpdSOStat Fail',   'us_english', 835
execute rdt.rdtAddMsg 140571, 10, '40571^UpdSOStat Fail',   'us_english', 835
execute rdt.rdtAddMsg 140572, 10, '40572^InsPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 140573, 10, '40573^No Pickslip',      'us_english', 835
execute rdt.rdtAddMsg 140574, 10, '40574^Fail scan-in',     'us_english', 835


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 140551 AND 140600