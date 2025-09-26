
--rdt_898DecodeSP02
--246801 - 246850

 
EXECUTE rdt.rdtdropmsg 246801, 246850			

EXECUTE rdt.rdtAddMsg 246801, 10, '246801^InvalidForm',     'us_english',898, 0, '246801 Invalid format'
EXECUTE rdt.rdtAddMsg 246802, 10, '246802^DecodeFail',      'us_english',898, 0, '246802 Fail to decode'
EXECUTE rdt.rdtAddMsg 246803, 10, '246803^InvUCCNo',        'us_english',898, 0, '246803 Invalid UCC No'
EXECUTE rdt.rdtAddMsg 246804, 10, '246804^UCCNotFound',     'us_english',898, 0, '246804 UCC Not Found'
EXECUTE rdt.rdtAddMsg 246805, 10, '246805^SKUNotFound',     'us_english',898, 0, '246805 SKU Not Found'
EXECUTE rdt.rdtAddMsg 246806, 10, '246806^MuiltSKU',        'us_english',898, 0, '246806 Muliple SKUs Found'
EXECUTE rdt.rdtAddMsg 246807, 10, '246807^UCCValiFail',     'us_english',898, 0, '246807 UCC Validation Failed'


SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 246801 AND 246850