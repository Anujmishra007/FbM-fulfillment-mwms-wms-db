-- rdtfnc_PalletTrackNoInquiry_Confirm
exec rdt.rdtdropmsg 121501, 121550

execute rdt.rdtAddMsg 121501, 10, '121501UPD PLDtl Fail', 'us_english', 1665
execute rdt.rdtAddMsg 121502, 10, '121502UPD PLDtl Fail', 'us_english', 1665
execute rdt.rdtAddMsg 121503, 10, '121503DEL PLDtl Fail', 'us_english', 1665
execute rdt.rdtAddMsg 121504, 10, '121504UPD PLDtl Fail', 'us_english', 1665
execute rdt.rdtAddMsg 121505, 10, '121505DEL MBDtl Fail', 'us_english', 1665
execute rdt.rdtAddMsg 121506, 10, 'ADDRESS CHANGE      ', 'us_english', 1665
