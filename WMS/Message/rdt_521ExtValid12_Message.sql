--rdt_521ExtValid12
--FCR-12181
exec rdt.rdtDropMsg 267201 , 267250

execute rdt.rdtAddMsg 267201, 10, '267201^WrongPutZone',       'us_english', 521, 0, '267201 Wrong Putaway Zone'
execute rdt.rdtAddMsg 267202, 10, '267202^WrongPutZone',       'us_english', 521, 0, '267202 Wrong Putaway Zone'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 267201 AND 267250
