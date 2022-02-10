-- rdtfnc_PalletPack
rdt.rdtDropMsg 137101 , 137150

execute rdt.rdtAddMsg 137101, 10, '37101^Value req',        'us_english', 835
execute rdt.rdtAddMsg 137102, 10, '37102^PALLET ID REQ',    'us_english', 835
execute rdt.rdtAddMsg 137103, 10, '37103^INVALID PLT ID',   'us_english', 835
execute rdt.rdtAddMsg 137104, 10, '37104^NEED CTN COUNT',   'us_english', 835
execute rdt.rdtAddMsg 137105, 10, '37105^INV CTN COUNT',    'us_english', 835
execute rdt.rdtAddMsg 137106, 10, '37106^COUNT X MATCH',    'us_english', 835
execute rdt.rdtAddMsg 137107, 10, '37107^COUNT X MATCH',    'us_english', 835
execute rdt.rdtAddMsg 137108, 10, '37108^OptionRequired',   'us_english', 835
execute rdt.rdtAddMsg 137109, 10, '37109^Invalid Option',   'us_english', 835

-- WMS-17164
execute rdt.rdtAddMsg 137110, 10, '37110^COUNT X MATCH',    'us_english', 835

-- WMS-17874
execute rdt.rdtAddMsg 137111, 10, '37111^NeedCartonType',   'us_english', 835
execute rdt.rdtAddMsg 137112, 10, '37112^Bad CTN TYPE',     'us_english', 835
execute rdt.rdtAddMsg 137113, 10, '37113^Need Weight',      'us_english', 835
execute rdt.rdtAddMsg 137114, 10, '37114^Invalid Format',   'us_english', 835
execute rdt.rdtAddMsg 137115, 10, '37115^Invalid Weight',   'us_english', 835
execute rdt.rdtAddMsg 137116, 10, '37116^Need Cube',        'us_english', 835
execute rdt.rdtAddMsg 137117, 10, '37117^Invalid Cube',     'us_english', 835
execute rdt.rdtAddMsg 137118, 10, '37118^Need RefNo ',      'us_english', 835
execute rdt.rdtAddMsg 137119, 10, '37119^Need Length ',     'us_english', 835
execute rdt.rdtAddMsg 137120, 10, '37120^Invalid Length',   'us_english', 835
execute rdt.rdtAddMsg 137121, 10, '37121^Need Width',       'us_english', 835
execute rdt.rdtAddMsg 137122, 10, '37122^Invalid Width',    'us_english', 835
execute rdt.rdtAddMsg 137123, 10, '37123^Need Height',      'us_english', 835
execute rdt.rdtAddMsg 137124, 10, '37124^Invalid Height',   'us_english', 835

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 137101 AND 137150