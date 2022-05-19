-- rdt_840GetOrders06 
execute rdt.rdtDropMsg 171701, 171750

execute rdt.rdtAddMsg 171701, 10, '171701 No Orders    ', 'us_english', 840

-- WMS-18931
execute rdt.rdtAddMsg 171702, 10, '171702 Not Sorted   ', 'us_english', 840

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE message_id BETWEEN 171701 and 171750