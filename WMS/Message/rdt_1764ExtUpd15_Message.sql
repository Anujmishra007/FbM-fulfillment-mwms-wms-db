-- rdt_1764ExtUpd15
exec rdt.rdtdropmsg 175501, 175550

execute rdt.rdtAddMsg 175501, 10, '175501^GenTLog2 Fail', 'us_english', 1764

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 175501 and 175550
