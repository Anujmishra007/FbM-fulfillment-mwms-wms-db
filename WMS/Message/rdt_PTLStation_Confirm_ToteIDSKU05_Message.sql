--rdt_PTLStation_Confirm_ToteIDSKU05
rdt.rdtDropMsg 146801 , 146850

execute rdt.rdtAddMsg 146801, 10, '46801^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 146802, 10, '46802^PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 146803, 10, '46803^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 146804, 10, '46804^InsPHdrFail',      'us_english', 805
execute rdt.rdtAddMsg 146805, 10, '46805^GenLabelNoFail',   'us_english', 805
execute rdt.rdtAddMsg 146806, 10, '46806^GenLabelNoFail',   'us_english', 805
execute rdt.rdtAddMsg 146807, 10, '46807^UpdTrackNoFail',   'us_english', 805
execute rdt.rdtAddMsg 146808, 10, '46808^InsPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 146809, 10, '46809^UpdPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 146810, 10, '46810^PackCfm Fail',     'us_english', 805
execute rdt.rdtAddMsg 146811, 10, '46811^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 146812, 10, '46812^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 146813, 10, '46813^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 146814, 10, '46814^INS PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 146815, 10, '46815^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 146816, 10, '46816^PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 146817, 10, '46817^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 146818, 10, '46818^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 146819, 10, '46819^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 146820, 10, '46820^nspg_GetKey',      'us_english', 805
execute rdt.rdtAddMsg 146821, 10, '46821^INS PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 146822, 10, '46822^INS RefKeyFail',   'us_english', 805
execute rdt.rdtAddMsg 146823, 10, '46823^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 146824, 10, '46824^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 146825, 10, '46825^InsPHdrFail',      'us_english', 805
execute rdt.rdtAddMsg 146826, 10, '46826^GenLabelNoFail',   'us_english', 805
execute rdt.rdtAddMsg 146827, 10, '46827^GenLabelNoFail',   'us_english', 805
execute rdt.rdtAddMsg 146828, 10, '46828^UpdTrackNoFail',   'us_english', 805
execute rdt.rdtAddMsg 146829, 10, '46829^InsPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 146830, 10, '46830^UpdPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 146831, 10, '46831^PackCfm Fail',     'us_english', 805
execute rdt.rdtAddMsg 146832, 10, '46832^UPD Log Fail',     'us_english', 805
execute rdt.rdtAddMsg 146833, 10, '46833^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 146834, 10, '46834^PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 146835, 10, '46835^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 146836, 10, '46836^INS DropID Err',   'us_english', 805
execute rdt.rdtAddMsg 146837, 10, '46837^INS DropID Err',   'us_english', 805
execute rdt.rdtAddMsg 146838, 10, 'All Tasks Completed.',   'us_english', 805

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 146801 AND 146850