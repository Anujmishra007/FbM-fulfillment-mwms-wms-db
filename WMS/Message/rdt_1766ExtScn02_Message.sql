--rdt_1766ExtScn02
--UWP-46877
EXECUTE rdt.rdtDropMsg 256251 , 256300

EXECUTE rdt.rdtAddMsg 256251, 10, '256251^InsCCDetailFail',       'us_english', 1766, 0, '256251 Insert CCDetail Failed'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 256251 AND 256300
