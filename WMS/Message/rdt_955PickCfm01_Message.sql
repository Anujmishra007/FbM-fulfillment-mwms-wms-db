--rdt_955PickCfm01
execute rdt.rdtdropmsg 116401, 116450

execute rdt.rdtAddMsg 116401, 10, '16401^Bad TaskQTY',       'us_english', 955
execute rdt.rdtAddMsg 116402, 10, '16402^Bad ConfirmQTY',    'us_english', 955
execute rdt.rdtAddMsg 116403, 10, '16403^Over pick',         'us_english', 955
execute rdt.rdtAddMsg 116404, 10, '16404^Bad UCC param',     'us_english', 955
execute rdt.rdtAddMsg 116405, 10, '16405^Get PKDtl fail',    'us_english', 955
execute rdt.rdtAddMsg 116406, 10, '16406^Task changed',      'us_english', 955
execute rdt.rdtAddMsg 116407, 10, '16407^Task changed',      'us_english', 955
execute rdt.rdtAddMsg 116408, 10, '16408^Offset error',      'us_english', 955
execute rdt.rdtAddMsg 116409, 10, '16409^GetDetKeyFail',     'us_english', 955
execute rdt.rdtAddMsg 116410, 10, '16410^Ins PDtl Fail',     'us_english', 955
execute rdt.rdtAddMsg 116411, 10, '16411^OffSetPDtlFail',    'us_english', 955
execute rdt.rdtAddMsg 116412, 10, '16412^OffSetPDtlFail',    'us_english', 955
execute rdt.rdtAddMsg 116413, 10, '16413^OffSetPDtlFail',    'us_english', 955
execute rdt.rdtAddMsg 116414, 10, '16414^OffSetPDtlFail',    'us_english', 955
execute rdt.rdtAddMsg 116415, 10, '16415^Ins Alert Fail',    'us_english', 955
execute rdt.rdtAddMsg 116416, 10, '16416^Upd UCC fail',      'us_english', 955
execute rdt.rdtAddMsg 116417, 10, '16417^Task changed',      'us_english', 955
execute rdt.rdtAddMsg 116418, 10, '16418^Scan Out Fail',     'us_english', 955
execute rdt.rdtAddMsg 116419, 10, '16419^Scan Out Fail',     'us_english', 955
execute rdt.rdtAddMsg 116420, 10, '16420^Pls Scan CtnID',    'us_english', 955
execute rdt.rdtAddMsg 116421, 10, '16421^Not Last Ctn',      'us_english', 955
execute rdt.rdtAddMsg 116422, 10, '16422^Invalid DropID',    'us_english', 955

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 116401 AND 116450