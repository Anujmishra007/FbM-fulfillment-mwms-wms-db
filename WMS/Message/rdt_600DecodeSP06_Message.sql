-- rdt_600DecodeSP06
execute rdt.rdtDropMsg 148751, 148800

execute rdt.rdtAddMsg 148751, 10, '148751^Require SKU', 'us_english', 600
execute rdt.rdtAddMsg 148752, 10, '148752^Require L02', 'us_english', 600
execute rdt.rdtAddMsg 148753, 10, '148753^Require L01', 'us_english', 600
execute rdt.rdtAddMsg 148754, 10, '148754^Require L03', 'us_english', 600
execute rdt.rdtAddMsg 148755, 10, '148755^Require QTY', 'us_english', 600
execute rdt.rdtAddMsg 148756, 10, '148756^ID Received', 'us_english', 600

--WMS-16436
execute rdt.rdtAddMsg 148757, 10, '148757^Dup Lot02  ', 'us_english', 600
execute rdt.rdtAddMsg 148758, 10, '148758^Wrong SKU  ', 'us_english', 600
execute rdt.rdtAddMsg 148759, 10, '148759^Over Rec   ', 'us_english', 600


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148751 AND 148800