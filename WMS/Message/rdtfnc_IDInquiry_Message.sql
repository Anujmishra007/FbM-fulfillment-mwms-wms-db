--rdtfnc_IDInquiry
--execute rdt.rdtdropmsg 82601, 82650

execute rdt.rdtAddMsg 82601, 10, '82601^NEED LABELNO',   'us_english'
execute rdt.rdtAddMsg 82602, 10, '82602^INV LABELNO',    'us_english'
execute rdt.rdtAddMsg 82603, 10, '82603^INV LABELNO',    'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 82601 AND 82650