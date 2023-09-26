-- rdt_950ConfirmSP02
execute rdt.rdtDropMsg 205651, 205700

execute rdt.rdtAddMsg 205651, 10, '205651UpdPickDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205652, 10, '205652UpdPickDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205653, 10, '205653UpdPickDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205654, 10, '205654DelPickDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205655, 10, '205655GetDetKey Fail', 'us_english', 950
execute rdt.rdtAddMsg 205656, 10, '205656Ins PDtl Fail' , 'us_english', 950
execute rdt.rdtAddMsg 205657, 10, '205657Ins RefKeyFail', 'us_english', 950
execute rdt.rdtAddMsg 205658, 10, '205658UpdPickDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205659, 10, '205659UpdPickDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205660, 10, '205660NotFullyOffset', 'us_english', 950
execute rdt.rdtAddMsg 205661, 10, '205661UpdPackDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205662, 10, '205662UpdPackDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205663, 10, '205663UpdPackDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205664, 10, '205664UpdPackDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205665, 10, '205665InsPackDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205666, 10, '205666UpdPackDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 205667, 10, '205667Upd DPL Fail'  , 'us_english', 950
execute rdt.rdtAddMsg 205668, 10, '205668InvalidCtnType', 'us_english', 950
execute rdt.rdtAddMsg 205669, 10, '205669InsPckInfoFail', 'us_english', 950
execute rdt.rdtAddMsg 205670, 10, '205670GenTLogFail'   , 'us_english', 950
execute rdt.rdtAddMsg 205671, 10, '205671UpdPckInfoFail', 'us_english', 950
execute rdt.rdtAddMsg 205672, 10, '205672Bad UpdateWGT' , 'us_english', 950

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 205651 AND  205700
