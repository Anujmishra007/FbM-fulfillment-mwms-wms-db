-- rdt_511ExtUpd05
exec rdt.rdtdropmsg 157901, 157950

execute rdt.rdtAddMsg 157901, 10, '157901^AGV API Error', 'us_english', 511

SELECT * FROM rdt.rdtmsg(NOLOCK) WHERE Message_ID BETWEEN 157901 and 157950
