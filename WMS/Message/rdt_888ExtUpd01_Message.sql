-- rdt_888ExtUpd01
--249151 - 249200

execute rdt.rdtDropMsg 249151, 249200

execute rdt.rdtAddMsg 249151, 10, '249151^DelRcptSNFail', 'us_english', 888

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id BETWEEN 249151 AND 249200
