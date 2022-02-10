-- rdt_1620ExtValid07
exec rdt.rdtDropMsg 138801 , 138850

execute rdt.rdtAddMsg 138801 ,10, '38801^Tote in Use',      'us_english', 1620
execute rdt.rdtAddMsg 138802 ,10, '38802^DropID<>PSlip#',   'us_english', 1620

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 138801 AND 138850