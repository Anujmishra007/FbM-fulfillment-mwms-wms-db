-- rdt_841GetOrders13
execute rdt.rdtdropmsg 202451, 202500

execute rdt.rdtAddMsg 202451, 10, '202451NoRecToProcess', 'us_english', 841

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 202451 AND 202500




