-- rdt_1855ExtUpd05
-- FCR-10039 - NYE018 - 261401 - 261450

exec rdt.rdtDropMsg 261401 , 261450

execute rdt.rdtAddMsg 261401, 10, '261401^DropIdUPDFail',        'us_english', 1855, 0, '261401^Error updating DropID in PackDetail'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 261401 AND 261450