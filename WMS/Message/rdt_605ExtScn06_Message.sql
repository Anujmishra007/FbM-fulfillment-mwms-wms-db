--rdt_605ExtScn04
--255151 - 255200


exec rdt.rdtDropMsg 255151, 255200

execute rdt.rdtAddMsg 255151, 10, '255151^ToIDRequired',    'us_english', 605
execute rdt.rdtAddMsg 255152, 10, '255152^DuplicateID',     'us_english', 605
execute rdt.rdtAddMsg 255153, 10, '255153^IDReceived',      'us_english', 605
execute rdt.rdtAddMsg 255154, 10, '255154^UpdRcptDtlFail',  'us_english', 605, 0, '255154 Replace ASN toID Fail'

select * from rdt.rdtmsg WITH (nolock) where message_id between 255151 and 255200