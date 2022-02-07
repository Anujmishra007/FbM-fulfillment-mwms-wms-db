-- rdt_SortAndPackConsignee_Confirm
exec rdt.rdtDropMsg 161051 , 161100

execute rdt.rdtAddMsg 161051, 10, '161051UPD PKDtl Fail', 'us_english', 1851
execute rdt.rdtAddMsg 161052, 10, '161052UPD PKDtl Fail', 'us_english', 1851
execute rdt.rdtAddMsg 161053, 10, '161053 GetKey Fail  ', 'us_english', 1851
execute rdt.rdtAddMsg 161054, 10, '161054INS PKDtl Fail', 'us_english', 1851
execute rdt.rdtAddMsg 161055, 10, '161055UPD PKDtl Fail', 'us_english', 1851
execute rdt.rdtAddMsg 161056, 10, '161056UPD PKDtl Fail', 'us_english', 1851
execute rdt.rdtAddMsg 161057, 10, '161057 Offset Fail  ', 'us_english', 1851
execute rdt.rdtAddMsg 161058, 10, '161058 GetKey Fail  ', 'us_english', 1851
execute rdt.rdtAddMsg 161059, 10, '161059INSPKHdrFail  ', 'us_english', 1851
execute rdt.rdtAddMsg 161060, 10, '161060UPD PKDtl Fail', 'us_english', 1851
execute rdt.rdtAddMsg 161061, 10, '161061INS PKDtl Fail', 'us_english', 1851
execute rdt.rdtAddMsg 161062, 10, '161062INS PKDtl Fail', 'us_english', 1851
execute rdt.rdtAddMsg 161063, 10, '161063 SCAN IN FAIL ', 'us_english', 1851
execute rdt.rdtAddMsg 161064, 10, '161064 Fail PackCfm ', 'us_english', 1851
execute rdt.rdtAddMsg 161065, 10, '161065 SCAN OUT FAIL', 'us_english', 1851
execute rdt.rdtAddMsg 161066, 10, '161066INS PINFO FAIL', 'us_english', 1851
execute rdt.rdtAddMsg 161067, 10, '161067UPD PINFO FAIL', 'us_english', 1851



SELECT TOP 100 * FROM rdt.rdtMsg (NOLOCK) WHERE message_id BETWEEN 161051 and 161100


