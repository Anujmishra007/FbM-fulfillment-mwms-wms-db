--rdt_830ExtVal02
exec rdt.rdtDropMsg 147201 , 147250

execute rdt.rdtAddMsg 147201, 10, '47201^Piece NotAllow',   'us_english', 830

--WMS-11714
execute rdt.rdtAddMsg 147202, 10, '47202^DropID Needed',    'us_english', 830


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 147201 AND 147250

