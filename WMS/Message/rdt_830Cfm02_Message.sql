-- rdt_830Cfm02
-- FCR-11251
execute rdt.rdtDropMsg 260801, 260850

execute rdt.rdtAddMsg 260801, 10, '260801UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 260802, 10, '260802UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 260803, 10, '260803UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 260804, 10, '260804nspg_GetKey   ', 'us_english', 830
execute rdt.rdtAddMsg 260805, 10, '260805INS PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 260806, 10, '260806INS RefKeyFail', 'us_english', 830
execute rdt.rdtAddMsg 260807, 10, '260807UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 260808, 10, '260808UPD PKDtl Fail', 'us_english', 830
execute rdt.rdtAddMsg 260809, 10, '260809GetKey Fail   ', 'us_english', 830
execute rdt.rdtAddMsg 260810, 10, '260810INSPHdrFail   ', 'us_english', 830
execute rdt.rdtAddMsg 260811, 10, '260811INSPackDtlFail', 'us_english', 830
execute rdt.rdtAddMsg 260812, 10, '260812UPDPackDtlFail', 'us_english', 830
execute rdt.rdtAddMsg 260813, 10, '260813INSPackInfFail', 'us_english', 830
execute rdt.rdtAddMsg 260814, 10, '260814UPDPackInfFail', 'us_english', 830
execute rdt.rdtAddMsg 260815, 10, '260815UPD PKDtl Fail', 'us_english', 830

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 260801 AND 260850