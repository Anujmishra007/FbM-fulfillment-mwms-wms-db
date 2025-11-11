--rdt_869ConfirmSP01
--FCR-6730

EXECUTE rdt.rdtdropmsg 245601, 245650

execute rdt.rdtAddMsg 245601, 10, '245601^UpdPickDtlFail',  'us_english', 869
execute rdt.rdtAddMsg 245602, 10, '245602^UpdPickDtlFail',  'us_english', 869
execute rdt.rdtAddMsg 245603, 10, '245603^UpdPickInfFail',  'us_english', 869
execute rdt.rdtAddMsg 245604, 10, '245604^UpdPackHdrFail',  'us_english', 869
execute rdt.rdtAddMsg 245605, 10, '245605^InsTL2LogErr',    'us_english', 869
execute rdt.rdtAddMsg 245606, 10, '245606^InsTL2LogErr',    'us_english', 869

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 245601 AND 245650
