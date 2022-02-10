-- isp_UpdateTrackNo
exec rdt.rdtDropMsg 75601, 75650

execute rdt.rdtAddMsg 75601, 10, '75601^No Account No ', 'us_english'
execute rdt.rdtAddMsg 75602, 10, '75602^SPNotExistInDB', 'us_english'
execute rdt.rdtAddMsg 75603, 10, '75603^CustomSP error', 'us_english'
