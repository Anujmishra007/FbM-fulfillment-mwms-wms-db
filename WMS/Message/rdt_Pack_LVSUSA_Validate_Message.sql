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



