--isp_805PTL_Confirm09
execute rdt.rdtDropMsg 159451, 159500

execute rdt.rdtAddMsg 159451, 10, '159451UpdPTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159452, 10, '159452UpdPTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159453, 10, '159453UpdPTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159454, 10, '159454InsPTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159455, 10, '159455UpdPTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159456, 10, '159456InsPHdrFail', 'us_english', 805
execute rdt.rdtAddMsg 159457, 10, '159457InsPackDtlFail', 'us_english', 805
execute rdt.rdtAddMsg 159458, 10, '159458UpdPackDtlFail', 'us_english', 805
execute rdt.rdtAddMsg 159459, 10, '159459PKDtlChg', 'us_english', 805
execute rdt.rdtAddMsg 159460, 10, '159460UpdPTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159461, 10, '159461UpdPKDTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159462, 10, '159462UpdPKDTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159463, 10, '159463GetKeyFail', 'us_english', 805
execute rdt.rdtAddMsg 159464, 10, '159464InsPKDtlFail', 'us_english', 805
execute rdt.rdtAddMsg 159465, 10, '159465InsRefkeyFail', 'us_english', 805
execute rdt.rdtAddMsg 159466, 10, '159466UpdPKDTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159467, 10, '159467UpdPKDTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159468, 10, '159468UpdPTLFail', 'us_english', 805
execute rdt.rdtAddMsg 159469, 10, '159469PkDtlChanged', 'us_english', 805
execute rdt.rdtAddMsg 159470, 10, '159470UpdPKDTLFail', 'us_english', 805

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 159451 AND 159500
