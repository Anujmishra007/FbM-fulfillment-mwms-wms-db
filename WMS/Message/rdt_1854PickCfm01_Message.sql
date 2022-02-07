--rdt_1854PickCfm01
exec rdt.rdtDropMsg 175101, 175150

execute rdt.rdtAddMsg 175101, 10, '175101 GetPKDtl fail', 'us_english', 1854
execute rdt.rdtAddMsg 175102, 10, '175102 Task Changed ', 'us_english', 1854
execute rdt.rdtAddMsg 175103, 10, '175103 Offset Error ', 'us_english', 1854
execute rdt.rdtAddMsg 175104, 10, '175104 UpdPKDtl Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175105, 10, '175105 Task Changed ', 'us_english', 1854
execute rdt.rdtAddMsg 175106, 10, '175106 Upd UCC Fail ', 'us_english', 1854
execute rdt.rdtAddMsg 175107, 10, '175107 Task Changed ', 'us_english', 1854
execute rdt.rdtAddMsg 175108, 10, '175108 InsPKDtl Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175109, 10, '175109 UpdPKDtl Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175110, 10, '175110 UpdPKDtl Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175111, 10, '175111 Scan Out Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175112, 10, '175112 Scan Out Fail', 'us_english', 1854

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 175101 AND 175150