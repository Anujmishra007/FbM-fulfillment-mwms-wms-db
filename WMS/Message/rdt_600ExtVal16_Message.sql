--rdt_600ExtVal16
execute rdt.rdtDropMsg 204701 , 204750

execute rdt.rdtAddMsg 204701, 10, '204701 ID EXISTS    ',   'us_english', 600
execute rdt.rdtAddMsg 204702, 10, '204702Mix SKU Not Allowed On ID',   'us_english', 600,0,'204702Mix SKU Not Allowed On ID'
execute rdt.rdtAddMsg 204703, 10, '204703 Mixed ',   'us_english', 600,0, 'Mixed'
execute rdt.rdtAddMsg 204704, 10, '^204704MixedSKU','us_english',600
execute rdt.rdtAddMsg 204705, 10, '^204705CodelkupErr','us_english',600


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 204701 AND 204750
