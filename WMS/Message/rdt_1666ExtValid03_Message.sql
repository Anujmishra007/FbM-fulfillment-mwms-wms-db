

--rdt_1666ExtValid03
exec rdt.rdtDropMsg 154851 , 154900

execute rdt.rdtAddMsg 154851, 10, '154851PalletNotClose',   'us_english', 1666
execute rdt.rdtAddMsg 154852, 10, '154851Pallet Scanned',   'us_english', 1666
execute rdt.rdtAddMsg 154853, 10, '154853WrongCountry',   'us_english', 1666
execute rdt.rdtAddMsg 154854, 10, '154854WrongCountry',   'us_english', 1666

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 147851 AND 147900