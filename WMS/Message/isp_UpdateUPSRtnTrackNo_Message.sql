-- isp_UpdateUPSRtnTrackNo
exec rdt.rdtDropMsg 75801, 75850

execute rdt.rdtAddMsg 75801, 10, '75801^No Account No ', 'us_english'
execute rdt.rdtAddMsg 75802, 10, '75802^SPNotExistInDB', 'us_english'
execute rdt.rdtAddMsg 75803, 10, '75803^CustomSP error', 'us_english'
