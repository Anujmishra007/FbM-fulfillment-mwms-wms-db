--rdt_533ExtMoveSP02
EXEC rdt.rdtDropMsg 157301 , 157350	

execute rdt.rdtAddMsg 157301, 10, '57301^InsPackDtlFail',   'us_english', 533
execute rdt.rdtAddMsg 157302, 10, '57302^UpdPackDtlFail',   'us_english', 533
execute rdt.rdtAddMsg 157303, 10, '57303^DelPackDtlFail',   'us_english', 533
execute rdt.rdtAddMsg 157304, 10, '57304^UpdPackDtlFail',   'us_english', 533
execute rdt.rdtAddMsg 157305, 10, '57305^OffsetError',      'us_english', 533
execute rdt.rdtAddMsg 157306, 10, '57306^UpdPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 157307, 10, '57307^DelPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 157308, 10, '57308^InsPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 157309, 10, '57309^UpdPKInfoFail',    'us_english', 533
execute rdt.rdtAddMsg 157310, 10, '57310^UpdPickDetFail',   'us_english', 533
execute rdt.rdtAddMsg 157310, 10, '57310^UpdPickDetFail',   'us_english', 533
execute rdt.rdtAddMsg 157311, 10, '57311^UpdPackDtlFail',   'us_english', 533

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 157301 AND 157350
