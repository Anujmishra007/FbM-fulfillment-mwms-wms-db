--rdt_841GetOrders03
rdt.rdtDropMsg 145751 , 145800

execute rdt.rdtAddMsg 145751, 10, '45751^Ins Ecomm Fail',   'us_english', 841
execute rdt.rdtAddMsg 145752, 10, '45752^NoRecToProcess',   'us_english', 841
execute rdt.rdtAddMsg 145753, 10, '45753^Upd OdDtl Fail',   'us_english', 841
execute rdt.rdtAddMsg 145754, 10, '45754^Upd OdHdr Fail',   'us_english', 841
execute rdt.rdtAddMsg 145755, 10, '45755^Canc Ecom Fail',   'us_english', 841
execute rdt.rdtAddMsg 145756, 10, 'ORDER CANCELLED',        'us_english', 841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 145751 AND 145800