-- rdt_1628ExtValid03
exec rdt.rdtDropMsg 138851 , 138850

execute rdt.rdtAddMsg 138851 ,10, '38851^Tote in Use',      'us_english',1628
execute rdt.rdtAddMsg 138852 ,10, '38852^MultiCOOSameSKU',  'us_english',1628

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 138851 AND 138850
