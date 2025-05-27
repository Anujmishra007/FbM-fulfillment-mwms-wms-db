/* RDT message for SLED */

-- Fn922
execute rdt.rdtDropMsg 218360 , 218364	

--select * from RDT.RDTMsg  where Message_ID  IN ('218361','218360','218362','218363','218364')AND Lang_Code = 'ENG'

execute rdt.rdtAddMsg 218360, 10, '218360INVALID MBOL',     'us_english', 922
execute rdt.rdtAddMsg 218361, 10, '218361ID NotInMBOL',     'us_english', 922
execute rdt.rdtAddMsg 218362, 10, '218362Diff Door',        'us_english', 922
execute rdt.rdtAddMsg 218363, 10, '218363Door Needed',      'us_english', 922
execute rdt.rdtAddMsg 218364, 10, '218364WrongDoor-Admin',  'us_english', 922, 0, '218364: Wrong Door-Admin'

select * from rdt.rdtmsg (nolock) where message_id between 218360 and 218364

