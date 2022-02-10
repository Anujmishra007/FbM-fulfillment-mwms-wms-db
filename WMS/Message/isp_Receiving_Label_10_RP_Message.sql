-- isp_Receiving_Label_10_RP
exec rdt.rdtDropMsg 83751, 83800

execute rdt.rdtAddMsg 83751, 10, '83751^INS LOT Fail  ', 'us_english'
execute rdt.rdtAddMsg 83752, 10, '83752^INS ID Fail   ', 'us_english'
execute rdt.rdtAddMsg 83753, 10, '83753^UPD LLI Fail  ', 'us_english'
execute rdt.rdtAddMsg 83754, 10, '83754^INS LLI Fail  ', 'us_english'
