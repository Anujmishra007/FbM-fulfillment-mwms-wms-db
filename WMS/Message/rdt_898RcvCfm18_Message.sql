
--rdt_898RcvCfm18
--247601 - 247650

EXECUTE rdt.rdtdropmsg 247601, 247650			

EXECUTE rdt.rdtAddMsg 247601, 10, '247601^InvalidUCCQty',       'us_english',898, 0, '247601 Invalid UCC Qty'
EXECUTE rdt.rdtAddMsg 247602, 10, '247602^SNNotFound',          'us_english',898, 0, '247602 SerialNo Not Found'
EXECUTE rdt.rdtAddMsg 247603, 10, '247603^InvalidAttr',         'us_english',898, 0, '247603 Invalid Attribute'
EXECUTE rdt.rdtAddMsg 247604, 10, '247604^RcvCfmFailure',       'us_english',898, 0, '247604 Fails to confirm receiving'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 247601 AND 247650