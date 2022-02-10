-- rdt_638RefNoLKUP05
execute rdt.rdtDropMsg 160351 , 160400

execute rdt.rdtAddMsg 160351, 10, '160351Max2RefField', 'us_english', 638
execute rdt.rdtAddMsg 160352, 10, '160352OrderNotFound', 'us_english', 638
execute rdt.rdtAddMsg 160353, 10, '160353GetKeyFail', 'us_english', 638
execute rdt.rdtAddMsg 160354, 10, '160354ASNNotFound', 'us_english', 638
execute rdt.rdtAddMsg 160355, 10, '160355InvRefNo', 'us_english', 638
execute rdt.rdtAddMsg 160356, 10, '160356MultiOrders', 'us_english', 638
execute rdt.rdtAddMsg 160357, 10, '160357InsReceiptFail', 'us_english', 638
execute rdt.rdtAddMsg 160358, 10, '160358InsRecDtFail', 'us_english', 638

SELECT TOP 10 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 160351 and 160400
