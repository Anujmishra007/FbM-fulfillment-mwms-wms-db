-- rdt_955PickCfm02 (range 178051 - 178100)
execute rdt.rdtDropMsg 178051, 178100

execute rdt.rdtAddMsg 178051, 10, '178051 Bad TaskQTY  ', 'us_english', 955
execute rdt.rdtAddMsg 178052, 10, '178052 BadConfirmQTY', 'us_english', 955
execute rdt.rdtAddMsg 178053, 10, '178053 Over pick    ', 'us_english', 955
execute rdt.rdtAddMsg 178054, 10, '178054 Bad UCC param', 'us_english', 955
execute rdt.rdtAddMsg 178055, 10, '178055 GetPKDtl fail', 'us_english', 955
execute rdt.rdtAddMsg 178056, 10, '178056 Task changed ', 'us_english', 955
execute rdt.rdtAddMsg 178057, 10, '178057 Task changed ', 'us_english', 955
execute rdt.rdtAddMsg 178058, 10, '178058 offset error ', 'us_english', 955
execute rdt.rdtAddMsg 178059, 10, '178059 GetDetKeyFail', 'us_english', 955
execute rdt.rdtAddMsg 178060, 10, '178060 Ins PDtl Fail', 'us_english', 955
execute rdt.rdtAddMsg 178061, 10, '178061OffSetPDtlFail', 'us_english', 955
execute rdt.rdtAddMsg 178062, 10, '178062OffSetPDtlFail', 'us_english', 955
execute rdt.rdtAddMsg 178063, 10, '178063OffSetPDtlFail', 'us_english', 955
execute rdt.rdtAddMsg 178064, 10, '178064OffSetPDtlFail', 'us_english', 955
execute rdt.rdtAddMsg 178065, 10, '178065 Upd UCC fail ', 'us_english', 955
execute rdt.rdtAddMsg 178066, 10, '178066 Task changed ', 'us_english', 955
execute rdt.rdtAddMsg 178067, 10, '178067 Upd UCC fail ', 'us_english', 955
execute rdt.rdtAddMsg 178068, 10, '178068 Scan Out Fail', 'us_english', 955
execute rdt.rdtAddMsg 178069, 10, '178069 Scan Out Fail', 'us_english', 955


SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 178051 and 178100


