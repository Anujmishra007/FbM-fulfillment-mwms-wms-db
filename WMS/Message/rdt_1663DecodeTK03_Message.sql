-- rdt_1663DecodeTK03
execute rdt.rdtDropMsg 134201 , 134203

execute rdt.rdtAddMsg 134201, 10, '34201^No Order Found', 'us_english'
execute rdt.rdtAddMsg 134202, 10, '34202^Diff Carrier  ', 'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 134201 AND 134250
