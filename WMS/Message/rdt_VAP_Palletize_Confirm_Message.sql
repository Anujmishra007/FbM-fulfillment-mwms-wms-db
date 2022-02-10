--rdt_VAP_Palletize_Confirm
exec rdt.rdtDropMsg 58901 , 58950

execute rdt.rdtAddMsg 58901 ,10, '58901^INS PALLET FAIL',   'us_english',1153
execute rdt.rdtAddMsg 58902 ,10, '58902^UPD PALLET FAIL',   'us_english',1153
execute rdt.rdtAddMsg 58904 ,10, '58904^UPD JOBDT FAIL',    'us_english',1153
execute rdt.rdtAddMsg 58905 ,10, '58905^UPD WOJOB FAIL',    'us_english',1153
execute rdt.rdtAddMsg 58906 ,10, '58906^UPD WJOPS FAIL',    'us_english',1153
execute rdt.rdtAddMsg 58907 ,10, '58907^UPD WJR FAIL',      'us_english',1153
execute rdt.rdtAddMsg 58908 ,10, '58908^INV BAL X ENUF',    'us_english',1153
execute rdt.rdtAddMsg 58909 ,10, '58909^WITHDRAW FAIL',     'us_english',1153
execute rdt.rdtAddMsg 58910 ,10, '58910^DEPOSIT FAIL',      'us_english',1153
execute rdt.rdtAddMsg 58911 ,10, '58911^END PALLET FAIL',   'us_english',1153
execute rdt.rdtAddMsg 58912 ,10, '58912^UPD WORI FAIL',     'us_english',1153
execute rdt.rdtAddMsg 58913 ,10, '58913^UPD WORO FAIL',     'us_english',1153
execute rdt.rdtAddMsg 58914 ,10, '58914^END PALLET FAIL',   'us_english',1153
execute rdt.rdtAddMsg 58915 ,10, '58915^UPD UNCASE FAIL',   'us_english',1153
execute rdt.rdtAddMsg 58916 ,10, '58916^GETCONFIG FAIL',    'us_english',1153
execute rdt.rdtAddMsg 58917 ,10, '58917^INS PLTLBL ERR',    'us_english',1153

-- Long Msg (Msg queue)
--58903 THE QTY UNCASED NOT ENOUGH TO DO PALLETIZING