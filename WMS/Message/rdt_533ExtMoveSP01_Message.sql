--rdt_533ExtMoveSP01
exec rdt.rdtDropMsg 135401 , 135450

execute rdt.rdtAddMsg 135401, 10, '35401^UpdPackD Fail',    'us_english', 533
execute rdt.rdtAddMsg 135402, 10, '35402^UpdPickD Fail',    'us_english', 533
execute rdt.rdtAddMsg 135403, 10, '35403^UpdPackD Fail',    'us_english', 533
execute rdt.rdtAddMsg 135404, 10, '35404^InsPackD Fail',    'us_english', 533
execute rdt.rdtAddMsg 135405, 10, '35405^UpdPackD Fail',    'us_english', 533
execute rdt.rdtAddMsg 135406, 10, '35406^UpdPackD Fail',    'us_english', 533
execute rdt.rdtAddMsg 135407, 10, '35407^UpdPickD Fail',    'us_english', 533
execute rdt.rdtAddMsg 135408, 10, '35408^GetDetKey fail',   'us_english', 533
execute rdt.rdtAddMsg 135409, 10, '35409^InsPickD Fail',    'us_english', 533
execute rdt.rdtAddMsg 135410, 10, '35410^UpdPickD Fail',    'us_english', 533
execute rdt.rdtAddMsg 135411, 10, '35411^InsRefLK Fail',    'us_english', 533
execute rdt.rdtAddMsg 135412, 10, '35412^OffsetError',      'us_english', 533
execute rdt.rdtAddMsg 135413, 10, '35413^InsPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 135414, 10, '35414^UpdPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 135415, 10, '35415^DelPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 135416, 10, '35416^DelPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 135417, 10, '35417^UpdPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 135418, 10, '35418^DelPKInfoFail',    'us_english', 533

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 135401 AND 135450