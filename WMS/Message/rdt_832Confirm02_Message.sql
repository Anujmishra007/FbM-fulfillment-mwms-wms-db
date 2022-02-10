--rdt_832Confirm02
rdt.rdtDropMsg 174051 , 174100

execute rdt.rdtAddMsg 174051, 10, '174051Invaild carton', 'us_english', 832
execute rdt.rdtAddMsg 174052, 10, '174052No LoadKey    ', 'us_english', 832
execute rdt.rdtAddMsg 174053, 10, '174053No PickSlipNo ', 'us_english', 832
execute rdt.rdtAddMsg 174054, 10, '174054Carton packed ', 'us_english', 832
execute rdt.rdtAddMsg 174055, 10, '174055InsPHdrFail   ', 'us_english', 832
execute rdt.rdtAddMsg 174056, 10, '174056InsPHdrFail   ', 'us_english', 832
execute rdt.rdtAddMsg 174057, 10, '174057InsPHdrFail   ', 'us_english', 832
execute rdt.rdtAddMsg 174058, 10, '174058InsPHdrFail   ', 'us_english', 832
execute rdt.rdtAddMsg 174059, 10, '174059Fail scan-in  ', 'us_english', 832
execute rdt.rdtAddMsg 174060, 10, '174060Invalid carton', 'us_english', 832
execute rdt.rdtAddMsg 174061, 10, '174061MultiSKUCarton', 'us_english', 832
execute rdt.rdtAddMsg 174062, 10, '174062GenLabelNoFail', 'us_english', 832
execute rdt.rdtAddMsg 174063, 10, '174063GenLabelNoFail', 'us_english', 832
execute rdt.rdtAddMsg 174064, 10, '174064InsPackDtlFail', 'us_english', 832
execute rdt.rdtAddMsg 174065, 10, '174065InsPackDtlFail', 'us_english', 832
execute rdt.rdtAddMsg 174066, 10, '174066UPD UCC Fail  ', 'us_english', 832
execute rdt.rdtAddMsg 174067, 10, '174067INSPackInfFail', 'us_english', 832
execute rdt.rdtAddMsg 174068, 10, '174068OffSetPDtlFail', 'us_english', 832
execute rdt.rdtAddMsg 174069, 10, '174069UpdateCaseIDEr', 'us_english', 832

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 174051 AND 174100