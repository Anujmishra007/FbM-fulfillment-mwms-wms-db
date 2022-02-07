-- rdt_DynamicPick_PickAndPack_GetNextCartonLabel
execute rdt.rdtDropMsg 64601, 64650

execute rdt.rdtAddMsg 64601, 10, '64601^GenLabelFail  ', 'us_english', 950
execute rdt.rdtAddMsg 64602, 10, '64602^InsPackDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 64603, 10, '64603^GenLabelFail  ', 'us_english', 950
execute rdt.rdtAddMsg 64604, 10, '64604^UpdPackHdrFail', 'us_english', 950
execute rdt.rdtAddMsg 64605, 10, '64605^InsPackDtlFail', 'us_english', 950
execute rdt.rdtAddMsg 64606, 10, '64606^UpdPKInfoFail ', 'us_english', 950
