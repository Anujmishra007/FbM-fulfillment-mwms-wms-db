
--rdt_1666ExtValid02
exec rdt.rdtDropMsg 147851 , 147900

execute rdt.rdtAddMsg 147851, 10, '47851^Route Empty',   'us_english', 1666
execute rdt.rdtAddMsg 147852, 10, '47852^Pallet Scanned',   'us_english', 1666
execute rdt.rdtAddMsg 147853, 10, '47853^Wrong Route',   'us_english', 1666
execute rdt.rdtAddMsg 147854, 10, '47854^PalletNotClose',   'us_english', 1666

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 147851 AND 147900

