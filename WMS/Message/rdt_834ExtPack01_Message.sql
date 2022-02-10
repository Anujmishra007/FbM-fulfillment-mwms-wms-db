--rdt_834ExtPack01
rdt.rdtDropMsg 139301 , 139350

execute rdt.rdtAddMsg 139301, 10, '39301^PickSlip req',     'us_english', 834
execute rdt.rdtAddMsg 139302, 10, '39302^InsPackHdrFail',   'us_english', 834
execute rdt.rdtAddMsg 139303, 10, '39303^GenLabelNoFail',   'us_english', 834
execute rdt.rdtAddMsg 139304, 10, '39304^InsPackDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139305, 10, '39305^UpdPackDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139306, 10, '39306^INSPackInfFail',   'us_english', 834
execute rdt.rdtAddMsg 139307, 10, '39307^UPDPackInfFail',   'us_english', 834
execute rdt.rdtAddMsg 139308, 10, '39308^InsCtnTrk Fail',   'us_english', 834
execute rdt.rdtAddMsg 139309, 10, '39309^PackCfm Fail',     'us_english', 834
execute rdt.rdtAddMsg 139310, 10, '39310^Scan Out Fail',    'us_english', 834
execute rdt.rdtAddMsg 139311, 10, '39311^UpdSOStat Fail',   'us_english', 834
execute rdt.rdtAddMsg 139312, 10, '39312^UpdSOStat Fail',   'us_english', 834
execute rdt.rdtAddMsg 139313, 10, '39313^Fail scan-in',     'us_english', 834
execute rdt.rdtAddMsg 139314, 10, '39314^InsPackDtlFail',   'us_english', 834
execute rdt.rdtAddMsg 139315, 10, '39315^Over Pack',        'us_english', 834

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 139301 AND 139350