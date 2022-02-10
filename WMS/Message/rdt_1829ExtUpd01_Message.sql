-- rdt_1829ExtUpd01
exec rdt.rdtDropMsg 114801 , 114850

execute rdt.rdtAddMsg 114801, 10, '14801^Rel Loc Fail',     'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 114801 AND 114850