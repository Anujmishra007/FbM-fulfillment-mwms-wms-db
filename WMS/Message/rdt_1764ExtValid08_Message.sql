--rdt_1764ExtValid08
--FCR-14963

EXECUTE rdt.rdtdropmsg 276301, 276350

execute rdt.rdtAddMsg 276301, 10, '276301^InvOption', 'us_english', 1764, 0, '276301 Only option 9 is valid'

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 276301 AND 276350