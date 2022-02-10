--rdtfnc_Scan_Pallet_To_Mbol
rdt.rdtDropMsg 141301 , 141350

execute rdt.rdtAddMsg 141301, 10, '41301^MBOLKey req',      'us_english', 1666
execute rdt.rdtAddMsg 141302, 10, '41302^MBOL NotExists',   'us_english', 1666
execute rdt.rdtAddMsg 141303, 10, '41303^MBOL Shipped',     'us_english', 1666
execute rdt.rdtAddMsg 141304, 10, '41304^No StorerKey',     'us_english', 1666
execute rdt.rdtAddMsg 141305, 10, '41305^PalletID req',     'us_english', 1666
execute rdt.rdtAddMsg 141306, 10, '41306^Inv PalletID',     'us_english', 1666
execute rdt.rdtAddMsg 141307, 10, '41307^Plt Not Close',    'us_english', 1666

--wms-18206
execute rdt.rdtAddMsg 141308, 10, '41308^NeedBlankMBOL ',    'us_english', 1666
execute rdt.rdtAddMsg 141309, 10, '41309^GenMBOLKeyFail',    'us_english', 1666
execute rdt.rdtAddMsg 141310, 10, '41310^INS MBOL Fail ',    'us_english', 1666


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141301 AND 141350