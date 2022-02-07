-- ispItrnSerialNoDeposit
execute rdt.rdtDropMsg 109251, 109300

execute rdt.rdtAddMsg 109251, 10, '109251ITrn not found', 'us_english'
execute rdt.rdtAddMsg 109252, 10, '109252INS ITrnSNFail', 'us_english'
