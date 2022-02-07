--rdt_805MatrixSP04
rdt.rdtDropMsg 166551 , 166600	

execute rdt.rdtAddMsg 166551, 10, '166551SetupMatrixCol',   'us_english', 805
execute rdt.rdtAddMsg 166552, 10, '166552Invalid Col',      'us_english', 805
execute rdt.rdtAddMsg 166553, 10, '166553Upd PTLTRAN Er',   'us_english', 805

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 166551 AND 166600