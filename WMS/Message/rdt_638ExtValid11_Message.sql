--rdt_638ExtValid11
rdt.rdtDropMsg 204201 , 204250


execute rdt.rdtAddMsg 204201, 10, '204201Invalidsku',   'us_english', 638
execute rdt.rdtAddMsg 204202, 10, '204202NonLFItem',   'us_english', 638
execute rdt.rdtAddMsg 204203, 10, '204203NonLFItem',   'us_english', 638
execute rdt.rdtAddMsg 204204, 10, '204204InvalidSKU',   'us_english', 638
execute rdt.rdtAddMsg 204205, 10, '204205FinalizeFail',   'us_english', 638
execute rdt.rdtAddMsg 204206, 10, '204206NeedReasonCode',   'us_english', 638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 204201 AND 204250