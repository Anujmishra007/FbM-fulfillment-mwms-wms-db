--rdt_1764ExtUpd24
--250201 - 250250


execute rdt.rdtdropmsg 250201, 250250


execute rdt.rdtAddMsg 250201, 10, '250201^UpdPKDFail', 'us_english', 1764

select * from rdt.rdtmsg WITH (NOLOCK) WHERE message_id between 250201 and 250250