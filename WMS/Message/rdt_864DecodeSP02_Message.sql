-- rdt_864DecodeSP02
execute rdt.rdtDropMsg 123201 , 123250

execute rdt.rdtAddMsg 123201, 10, '23201^Invalid Format',     'us_english'
execute rdt.rdtAddMsg 123202, 10, '23202^Scanned Before',     'us_english'

SELECT * FROM RDT.RDTMSG WITH (NOLOCK) WHERE MESSAGE_ID BETWEEN 123201 AND 123250
