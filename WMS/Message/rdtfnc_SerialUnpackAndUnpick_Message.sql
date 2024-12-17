--Add Menu
IF NOT EXISTS( SELECT 1 FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID = 1868)
BEGIN
   INSERT INTO RDT.RDTMsg(Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, [URL], Message_Text_Long)
   VALUES(1868, 'ENG', 'FNC', 'UnPack And UnPick by SN', 'rdtfnc_SerialUnpackAndUnpick', 0, 0, '', '')
END

--rdtfnc_SerialUnpackAndUnpick
execute rdt.rdtDropMsg 228251, 228300

execute rdt.rdtAddMsg 228251, 10, '228251^PSNO InValid ',  'us_english', 1868, 0, '228251^PSNO is not valid'
execute rdt.rdtAddMsg 228252, 10, '228252^Order Shipped',  'us_english', 1868, 0
execute rdt.rdtAddMsg 228253, 10, '228253^InvalidOption',  'us_english', 1868, 0, '228253^Please enter valid value'
execute rdt.rdtAddMsg 228254, 10, '228254^Loc Invalid  ',  'us_english', 1868, 0, '228254^Location is not valid'
execute rdt.rdtAddMsg 228255, 10, '228255^Loc Not Stage',  'us_english', 1868, 0, '228255^Location is not Staging'
execute rdt.rdtAddMsg 228256, 10, '228256^Sn Invalid   ',  'us_english', 1868, 0, '228256^SerialNo is not valid'
execute rdt.rdtAddMsg 228257, 10, '228257^SnNotExsists ',  'us_english', 1868, 0, '228257^SerialNo is not valid'
execute rdt.rdtAddMsg 228258, 10, '228258^Diff PSNO    ',  'us_english', 1868, 0, '228258^Serial number belongs to a different PS NO'
execute rdt.rdtAddMsg 228259, 10, '228259^Not packed   ',  'us_english', 1868, 0, '228259^Serial number not yet packed'
execute rdt.rdtAddMsg 228260, 10, '228260^Qty reduce   ',  'us_english', 1868, 0, '228260^Qty reduce error'
execute rdt.rdtAddMsg 228262, 10, '228262^SerialInValid',  'us_english', 1868, 0, '228262^SerialNo Not Exists'
execute rdt.rdtAddMsg 228263, 10, '228263^PSNONotPacked',  'us_english', 1868, 0
execute rdt.rdtAddMsg 228264, 10, '228264^OrderKey     ',  'us_english', 1868, 0, '228264^OrderKey Not Exists'
execute rdt.rdtAddMsg 228265, 10, '228265^Data Invalid ',  'us_english', 1868, 0, '228265^SKU Or PickDetailKey Not Exists'
execute rdt.rdtAddMsg 228266, 10, '228266^FromLOC      ',  'us_english', 1868, 0, '228266^From LOC Not Exists'
execute rdt.rdtAddMsg 228267, 10, '228267^Invalid      ',  'us_english', 1868, 0, '228267^Invalid Option'
