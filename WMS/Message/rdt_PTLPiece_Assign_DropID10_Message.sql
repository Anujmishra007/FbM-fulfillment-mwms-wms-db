--rdt_PTLPiece_Assign_DropID10
--FCR-13139: PTW/PTL Assignment SP for AEOMX
execute rdt.rdtdropmsg 272751, 272760

execute rdt.rdtAddMsg 272751, 10, '272751 Station Busy ', 'us_english', 803, 0, '272751 Station is busy, please wait'
execute rdt.rdtAddMsg 272752, 10, '272752 Canal Invalid', 'us_english', 803, 0, '272752 Invalid channel/method selected'
execute rdt.rdtAddMsg 272753, 10, '272753 PTW No Space ', 'us_english', 803, 0, '272753 No available slot in PTW station'
execute rdt.rdtAddMsg 272754, 10, '272754 No Color Avai', 'us_english', 803, 0, '272754 No color available for assignment'
execute rdt.rdtAddMsg 272755, 10, '272755 Ins Log Fail ', 'us_english', 803, 0, '272755 Failed to insert PTLPieceLog record'