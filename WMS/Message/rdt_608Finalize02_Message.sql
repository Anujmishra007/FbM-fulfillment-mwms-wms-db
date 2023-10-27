--rdt_608Finalize02
exec rdt.rdtDropMsg 207501 , 207550

execute rdt.rdtAddMsg 207501, 10, '207501 NotAllQtyRcv ', 'us_english', 608

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 207501 AND 207550



