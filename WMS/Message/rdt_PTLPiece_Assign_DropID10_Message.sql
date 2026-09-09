--rdt_PTLPiece_Assign_DropID10
--FCR-13139: PTW/PTL Assignment SP for AEOMX
execute rdt.rdtdropmsg 272751, 272770

execute rdt.rdtAddMsg 272751, 10, '272751 Station Busy ', 'us_english', 803, 0, '272751 Station is busy, please wait'
execute rdt.rdtAddMsg 272752, 10, '272752 Canal Invalid', 'us_english', 803, 0, '272752 Invalid channel/method selected'
execute rdt.rdtAddMsg 272753, 10, '272753 PTW No Space ', 'us_english', 803, 0, '272753 No available slot in PTW station'
execute rdt.rdtAddMsg 272754, 10, '272754 No Color Avai', 'us_english', 803, 0, '272754 No color available for assignment'
execute rdt.rdtAddMsg 272755, 10, '272755 Ins Log Fail ', 'us_english', 803, 0, '272755 Failed to insert PTLPieceLog record'
execute rdt.rdtAddMsg 272756, 10, '272756 No User Color', 'us_english', 803, 0, '272756 No user color assigned'

--UWP-66161: Multi LOC/ID validation
execute rdt.rdtAddMsg 272757, 10, '272757 Multi LOC    ', 'us_english', 803, 0, '272757 DropID has inventory in multiple locations'
execute rdt.rdtAddMsg 272758, 10, '272758 Multi ID     ', 'us_english', 803, 0, '272758 DropID has inventory in multiple IDs'

--UWP-66161: Migrated from 187xxx to 272xxx
execute rdt.rdtAddMsg 272759, 10, '272759 Need DropID  ', 'us_english', 803, 0, '272759 Please scan DropID'
execute rdt.rdtAddMsg 272760, 10, '272760 Bad DropID   ', 'us_english', 803, 0, '272760 DropID not found in PickDetail'
execute rdt.rdtAddMsg 272761, 10, '272761 Ins Log Fail ', 'us_english', 803, 0, '272761 Failed to insert PTLPieceLog record'

--UWP-66208: PickDetail status validation
execute rdt.rdtAddMsg 272762, 10, '272762 Bad PD Status', 'us_english', 803, 0, '272762 DropID has PickDetail with invalid status'