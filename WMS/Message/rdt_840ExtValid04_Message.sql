--rdt_840ExtValid04
rdt.rdtDropMsg 145701 , 145750

execute rdt.rdtAddMsg 145701, 10, '45701^Upd OdDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 145702, 10, '45702^Upd OdHdr Fail',   'us_english', 840
execute rdt.rdtAddMsg 145703, 10, 'ORDER CANCELLED',        'us_english', 840
execute rdt.rdtAddMsg 145704, 10, 'ORDER CANCELLED',        'us_english', 840

--WMS16145
execute rdt.rdtAddMsg 145705, 10, '45705^INVALID LOT02',    'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 145701 AND 145750