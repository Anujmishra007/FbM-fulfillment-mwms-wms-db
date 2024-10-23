-- rdt_Pack_Validate
execute rdt.rdtDropMsg 226501, 226550
execute rdt.rdtAddMsg 226501, 10, '226501CartNoExist', 'us_english', 993, 0, '226501 Carton Not Exists'
execute rdt.rdtAddMsg 226502, 10, '226502DiffStorer', 'us_english', 993, 0, '226502 Different Storer'
execute rdt.rdtAddMsg 226503, 10, '226503InvPKDStatus', 'us_english', 993, 0, '226503 Invalid PKD Status'
execute rdt.rdtAddMsg 226504, 10, '226504InvPKDStatus', 'us_english', 993, 0, '226504 Invalid Carton'
execute rdt.rdtAddMsg 226505, 10, '226505SKUNotInCart', 'us_english', 993, 0, '226505 SKU Not In Carton'
execute rdt.rdtAddMsg 226506, 10, '226506MissMLabelNo', 'us_english', 993, 0, '226506 Failed to Get Master Label No'
execute rdt.rdtAddMsg 226507, 10, '226507OverPack', 'us_english', 993, 0, '226507 Over Pack'
execute rdt.rdtAddMsg 226508, 10, '226508QtyTooGreat', 'us_english', 993, 0, '226508 Quantity Too Great'
execute rdt.rdtAddMsg 226509, 10, '226509UseMerge', 'us_english', 993, 0, '226509 Use Merge to Empty Carton'

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


