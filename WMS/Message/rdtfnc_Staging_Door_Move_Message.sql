--rdtfnc_Staging_Door_Move
--execute rdt.rdtdropmsg 68566, 68615

INSERT INTO rdt.storerconfig ( function_id , storerkey , configkey , configdesc , svalue ) 
values ('1751',	'',	'StageMoveDoorCheckDigit' , 'StageMoveDoorCheckDigit',	'1')


execute rdt.rdtAddMsg 68566, 10, '68566^PalletID Req', 'us_english'
execute rdt.rdtAddMsg 68567, 10, '68567^Invalid PalletID', 'us_english'
execute rdt.rdtAddMsg 68568, 10, '68568^Option Req', 'us_english'
execute rdt.rdtAddMsg 68569, 10, '68569^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 68570, 10, '68570^PalletNotClose', 'us_english'
execute rdt.rdtAddMsg 68571, 10, '68571^No Loadkey', 'us_english'
execute rdt.rdtAddMsg 68572, 10, '68572^No PSNO',  'us_english'
execute rdt.rdtAddMsg 68573, 10, '68573^NotDiscretePSNO',  'us_english'
execute rdt.rdtAddMsg 68574, 10, '68574^No PO',  'us_english'
execute rdt.rdtAddMsg 68575, 10, '68575^No ShipTo',  'us_english'
execute rdt.rdtAddMsg 68576, 10, '68576^NoLocCategory',  'us_english'
execute rdt.rdtAddMsg 68577, 10, '68577^NoLaneAssign',  'us_english'
execute rdt.rdtAddMsg 68578, 10, '68578^PltNotInStage',  'us_english'
execute rdt.rdtAddMsg 68579, 10, '68579^Lane Req',  'us_english'
execute rdt.rdtAddMsg 68580, 10, '68580^Invalid Lane',  'us_english'
execute rdt.rdtAddMsg 68581, 10, '68581^Door Req',  'us_english'
execute rdt.rdtAddMsg 68582, 10, '68582^No UCC',  'us_english'
execute rdt.rdtAddMsg 68583, 10, '68583^PLTMvToStage',  'us_english'

-- (Vicky04) - Start
execute rdt.rdtAddMsg 68584, 10, '68584^PLTNotInStage',  'us_english'
execute rdt.rdtAddMsg 68585, 10, '68585^Lane Req',  'us_english'
execute rdt.rdtAddMsg 68586, 10, '68586^LaneNotMatchID',  'us_english'
execute rdt.rdtAddMsg 68587, 10, '68587^Lane Req',  'us_english'
execute rdt.rdtAddMsg 68588, 10, '68588^Diff Facility',  'us_english'
execute rdt.rdtAddMsg 68589, 10, '68589^NotStagingLoc',  'us_english'
execute rdt.rdtAddMsg 68590, 10, '68590^Invalid ID',  'us_english'
-- (Vicky04) - End

-- (Vicky06)
execute rdt.rdtAddMsg 68591, 10, '68591^No Loadkey', 'us_english'

-- (Vicky07)
execute rdt.rdtAddMsg 68592, 10, '68592^LabelNotPrinted', 'us_english'
execute rdt.rdtAddMsg 68593, 10, '68593^Lane4OtherLoad', 'us_english'
execute rdt.rdtAddMsg 68594, 10, '68594^LoadPlanClosed', 'us_english'

-- (Vicky08)
execute rdt.rdtAddMsg 68595, 10, '68595^Upd DropID Fail', 'us_english'
execute rdt.rdtAddMsg 68596, 10, '68596^Upd DropID Fail', 'us_english'
execute rdt.rdtAddMsg 68597, 10, '68597^Upd DropID Fail', 'us_english'

-- (ChewKP01)
execute rdt.rdtAddMsg 68598, 10, '68598^Invalid Door', 'us_english'
execute rdt.rdtAddMsg 68599, 10, '68599^Invalid DropID', 'us_english'