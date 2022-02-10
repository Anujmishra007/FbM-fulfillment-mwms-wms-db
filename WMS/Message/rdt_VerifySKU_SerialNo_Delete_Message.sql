--rdt_VerifySKU_SerialNo_Delete
execute rdt.rdtDropMsg 56601, 56650

execute rdt.rdtAddMsg 56601, 10, '56601 DEL SNO Fail  ',   'us_english'
execute rdt.rdtAddMsg 56602, 10, '56602 DEL SNO Fail  ',   'us_english'
