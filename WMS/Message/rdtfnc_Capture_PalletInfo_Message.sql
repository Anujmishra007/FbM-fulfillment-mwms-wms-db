-- rdtfnc_Capture_PalletInfo
exec rdt.rdtDropMsg 118801 , 118850

execute rdt.rdtAddMsg 118801, 10, '18801^Invalid Length',   'us_english', 825
execute rdt.rdtAddMsg 118802, 10, '18802^Invalid Width',    'us_english', 825
execute rdt.rdtAddMsg 118803, 10, '18803^Invalid Height',   'us_english', 825
execute rdt.rdtAddMsg 118804, 10, '18804^Invalid Weight',   'us_english', 825
execute rdt.rdtAddMsg 118805, 10, '18805^Value needed',     'us_english', 825
execute rdt.rdtAddMsg 118806, 10, '18806^Invalid Pallet',   'us_english', 825
execute rdt.rdtAddMsg 118807, 10, '18807^Ins Pallet Err',   'us_english', 825
execute rdt.rdtAddMsg 118808, 10, '18808^Invalid Length',   'us_english', 825
execute rdt.rdtAddMsg 118809, 10, '18809^Invalid Width',    'us_english', 825
execute rdt.rdtAddMsg 118810, 10, '18810^Invalid Height',   'us_english', 825
execute rdt.rdtAddMsg 118811, 10, '18811^Invalid Weight',   'us_english', 825
execute rdt.rdtAddMsg 118812, 10, '18812^Upd Info Err',     'us_english', 825
execute rdt.rdtAddMsg 118813, 10, '18812^Invalid Stack',    'us_english', 825

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 118801 AND 118850