-- rdt_1812SwapUCC02
exec rdt.rdtDropMsg 222501, 222550

execute rdt.rdtAddMsg 222501, 10, '222501UCC scanned   ', 'us_english', 1812
execute rdt.rdtAddMsg 222502, 10, '222502BadTaskDtlKey ', 'us_english', 1812
execute rdt.rdtAddMsg 222503, 10, '222503Not an UCC    ', 'us_english', 1812
execute rdt.rdtAddMsg 222504, 10, '222504Multi SKU UCC ', 'us_english', 1812
execute rdt.rdtAddMsg 222505, 10, '222505Bad UCC Status', 'us_english', 1812
execute rdt.rdtAddMsg 222506, 10, '222506UCCLOCNotMatch', 'us_english', 1812
execute rdt.rdtAddMsg 222507, 10, '222507UCCIDNotMatch ', 'us_english', 1812
execute rdt.rdtAddMsg 222508, 10, '222508UCCSKUNotMatch', 'us_english', 1812
execute rdt.rdtAddMsg 222509, 10, '222509UCCQTYNotMatch', 'us_english', 1812
execute rdt.rdtAddMsg 222510, 10, '222510UCCL02NotMatch', 'us_english', 1812
execute rdt.rdtAddMsg 222511, 10, '222511UCC Taken     ', 'us_english', 1812
execute rdt.rdtAddMsg 222512, 10, '222512UPD PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222513, 10, '222513UPD PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222514, 10, '222514nspg_GetKey   ', 'us_english', 1812
execute rdt.rdtAddMsg 222515, 10, '222515INS PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222516, 10, '222516INS RefKeyFail', 'us_english', 1812
execute rdt.rdtAddMsg 222517, 10, '222517UPD PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222518, 10, '222518UPD PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222519, 10, '222519QTY not avail ', 'us_english', 1812
execute rdt.rdtAddMsg 222520, 10, '222520UPD PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222521, 10, '222521UPD PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222522, 10, '222522nspg_GetKey   ', 'us_english', 1812
execute rdt.rdtAddMsg 222523, 10, '222523INS PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222524, 10, '222524INS RefKeyFail', 'us_english', 1812
execute rdt.rdtAddMsg 222525, 10, '222525UPD PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222526, 10, '222526UPD PKDtl Fail', 'us_english', 1812
execute rdt.rdtAddMsg 222527, 10, '222527Offset error  ', 'us_english', 1812

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 222501 AND 222550
