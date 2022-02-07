--rdt_PickPallet_ConfirmTask
exec rdt.rdtDropMsg 175051, 175100

execute rdt.rdtAddMsg 175051, 10, '175051 Bad TaskQTY  ', 'us_english', 1854
execute rdt.rdtAddMsg 175052, 10, '175052 BadConfirmQTY', 'us_english', 1854
execute rdt.rdtAddMsg 175053, 10, '175053 Over pick    ', 'us_english', 1854
execute rdt.rdtAddMsg 175054, 10, '175054 Bad UCC Param', 'us_english', 1854
execute rdt.rdtAddMsg 175055, 10, '175055 GetPKDtl Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175056, 10, '175056 Task Changed ', 'us_english', 1854
execute rdt.rdtAddMsg 175057, 10, '175057 Task Changed ', 'us_english', 1854
execute rdt.rdtAddMsg 175058, 10, '175058 UpdPKDtl Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175059, 10, '175059 Task Changed ', 'us_english', 1854
execute rdt.rdtAddMsg 175060, 10, '175060 Upd UCC Fail ', 'us_english', 1854
execute rdt.rdtAddMsg 175061, 10, '175061 Task Changed ', 'us_english', 1854
execute rdt.rdtAddMsg 175062, 10, '175062 InsPKDtl Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175063, 10, '175063 UpdPKDtl Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175064, 10, '175064 UpdPKDtl Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175065, 10, '175065 Scan Out Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175066, 10, '175066 Scan Out Fail', 'us_english', 1854
execute rdt.rdtAddMsg 175067, 10, '175067 offset error ', 'us_english', 1854

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 175051 AND 175100
