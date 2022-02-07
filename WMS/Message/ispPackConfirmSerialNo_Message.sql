-- ispPackConfirmSerialNo
execute rdt.rdtDropMsg 111101, 111150

execute rdt.rdtAddMsg 111101, 10, '111101SNOQTYNotTally', 'us_english'
execute rdt.rdtAddMsg 111102, 10, '111102SNO not RCV   ', 'us_english'
execute rdt.rdtAddMsg 111103, 10, '111103SNO ady picked', 'us_english'
execute rdt.rdtAddMsg 111104, 10, '111104SNO ady packed', 'us_english'
execute rdt.rdtAddMsg 111105, 10, '111105SNO shipped   ', 'us_english'
execute rdt.rdtAddMsg 111106, 10, '111106Bad SNO status', 'us_english'
execute rdt.rdtAddMsg 111107, 10, '111107UPD SNO Fail  ', 'us_english'
execute rdt.rdtAddMsg 111108, 10, '111108GetKey Fail   ', 'us_english'
execute rdt.rdtAddMsg 111109, 10, '111109INS SNO Fail  ', 'us_english'
