-- rdt_Pack_Validate
execute rdt.rdtDropMsg 226501, 226550
execute rdt.rdtAddMsg 226501, 10, '226501CartNoExist   ', 'us_english', 993, 0, '226501 Carton Not Exists'
execute rdt.rdtAddMsg 226502, 10, '226502DiffStorer   ', 'us_english', 993, 0, '226502 Different Storer'
execute rdt.rdtAddMsg 226503, 10, '226503InvPKDStatus   ', 'us_english', 993, 0, '226503 Invalid PKD Status'
execute rdt.rdtAddMsg 226504, 10, '226504InvPKDStatus   ', 'us_english', 993, 0, '226504 Invalid Carton'


select * from rdt.rdtmsg (nolock) where message_id between 226501 AND 226550

/*
execute rdt.rdtAddMsg 100351, 10, '00351^Invalid PSNO  ', 'us_english', 838

execute rdt.rdtAddMsg 100353, 10, '00353^SKU NotIn PSNO', 'us_english', 838
execute rdt.rdtAddMsg 100354, 10, '00354^Over pack     ', 'us_english', 838
execute rdt.rdtAddMsg 100355, 10, '00355^Invalid PSNO  ', 'us_english', 838
execute rdt.rdtAddMsg 100356, 10, '00356^Order shipped ', 'us_english', 838

execute rdt.rdtAddMsg 100358, 10, '00358^SKU NotIn PSNO', 'us_english', 838
execute rdt.rdtAddMsg 100359, 10, '00359^Over pack     ', 'us_english', 838
execute rdt.rdtAddMsg 100360, 10, '00360^Invalid PSNO  ', 'us_english', 838
execute rdt.rdtAddMsg 100361, 10, '00361^Diff storer   ', 'us_english', 838
execute rdt.rdtAddMsg 100362, 10, '00362^SKU NotIn PSNO', 'us_english', 838
execute rdt.rdtAddMsg 100363, 10, '00363^Over pack     ', 'us_english', 838
execute rdt.rdtAddMsg 100364, 10, '00364^Invalid PSNO  ', 'us_english', 838
execute rdt.rdtAddMsg 100365, 10, '00365^Diff storer   ', 'us_english', 838
execute rdt.rdtAddMsg 100366, 10, '00366^SKU NotIn PSNO', 'us_english', 838
execute rdt.rdtAddMsg 100367, 10, '00367^Over pack     ', 'us_english', 838
execute rdt.rdtAddMsg 100368, 10, '00368^Order CANCEL  ', 'us_english', 838
execute rdt.rdtAddMsg 100369, 10, '00369^SKUNotInDropID', 'us_english', 838
execute rdt.rdtAddMsg 100370, 10, '00370^SKUNotInDropID', 'us_english', 838
execute rdt.rdtAddMsg 100371, 10, '00371^SKUNotInDropID', 'us_english', 838
execute rdt.rdtAddMsg 100372, 10, '00372^SKUNotInDropID', 'us_english', 838
*/


