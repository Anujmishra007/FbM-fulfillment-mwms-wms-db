--rdt_1641ExtValidSP18
exec rdt.rdtDropMsg 183001  , 183050
-- **********************************************

execute rdt.rdtAddMsg 183001 ,10, '183001MultiConsignee', 'us_english',1641
execute rdt.rdtAddMsg 183002 ,10, '183002DiffConsignee', 'us_english',1641
execute rdt.rdtAddMsg 183003 ,10, '183003InvalidCaseID', 'us_english',1641
execute rdt.rdtAddMsg 183004 ,10, '183004DiffConsignee', 'us_english',1641
execute rdt.rdtAddMsg 183005 ,10, '183005UCC#Exists', 'us_english',1641