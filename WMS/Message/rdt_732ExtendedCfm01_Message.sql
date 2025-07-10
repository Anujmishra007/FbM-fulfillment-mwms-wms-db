-- rdt_732ExtendedCfm01
exec rdt.rdtDropMsg 234951 , 235000	

execute rdt.rdtAddMsg 234951, 10, '234951 ID Counted   ', 'us_english', 732
execute rdt.rdtAddMsg 234952, 10, '234952 GetKey Fail  ', 'us_english', 732
execute rdt.rdtAddMsg 234953, 10, '234953 GetKey Fail  ', 'us_english', 732
execute rdt.rdtAddMsg 234954, 10, '234954 INS CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234955, 10, '234955 INS CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234956, 10, '234956 INS CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234957, 10, '234957 UPD CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234958, 10, '234958 UPD CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234959, 10, '234959 UPD CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234960, 10, '234960 UPD CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234961, 10, '234961 UPD CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234962, 10, '234962 UPD CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234963, 10, '234963 UPD CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234964, 10, '234964 UPD CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234965, 10, '234965 GetKey Fail  ', 'us_english', 732
execute rdt.rdtAddMsg 234966, 10, '234966 GetKey Fail  ', 'us_english', 732
execute rdt.rdtAddMsg 234967, 10, '234967 INS CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234968, 10, '234968 INS CCDtl Err', 'us_english', 732
execute rdt.rdtAddMsg 234969, 10, '234966 INS CCDtl Err', 'us_english', 732

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 234951 AND 235000


