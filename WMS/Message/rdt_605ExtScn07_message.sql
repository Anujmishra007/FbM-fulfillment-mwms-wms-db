-- rdt_605ExtScn07_message
execute rdt.rdtDropMsg 259801, 259850

execute rdt.rdtAddMsg 259801, 10, '259801^Invalid Option', 'us_english', 605
execute rdt.rdtAddMsg 259802, 10, '259802^No more record', 'us_english', 605

SELECT TOP 100 * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 259801 AND 259850