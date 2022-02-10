
-- rdtfnc_PostPick_SKULottable_Message 71591 - 71640
-- **********************************************

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('904', 'ENG', 'FNC', 'PPA SKU Lottable', 'rdtfnc_PostPickAudit_SKULottable', '0')


INSERT INTO CODELKUP (LISTNAME , Code, Description)
VALUES ('PPAREASON', 'SP', 'Short Pick' ) 

INSERT INTO Codelist (Listname , Description)
VALUES ('PPAREASON','RDT PPA ReasonCode')

execute rdt.rdtAddMsg 71591, 10, '71591^Value Required', 'us_english'
execute rdt.rdtAddMsg 71592, 10, '71592^Key-in either 1', 'us_english'
execute rdt.rdtAddMsg 71593, 10, '71593^Invalid RefNo', 'us_english'
execute rdt.rdtAddMsg 71594, 10, '71594^Not Scan-in', 'us_english'
execute rdt.rdtAddMsg 71595, 10, '71595^Not Scan-out', 'us_english'
execute rdt.rdtAddMsg 71596, 10, '71596^Invalid PSNO', 'us_english'
execute rdt.rdtAddMsg 71597, 10, '71597^Not Scan-in', 'us_english'
execute rdt.rdtAddMsg 71598, 10, '71598^Not Scan-out', 'us_english'

execute rdt.rdtAddMsg 71599, 10, '71599^Invalid LoadKey', 'us_english'
execute rdt.rdtAddMsg 71600, 10, '71600^Not Scan-in', 'us_english'
execute rdt.rdtAddMsg 71601, 10, '71601^Not Scan-out', 'us_english'
execute rdt.rdtAddMsg 71602, 10, '71602^Invalid LoadKey', 'us_english'
execute rdt.rdtAddMsg 71603, 10, '71603^Not Scan-in', 'us_english'
execute rdt.rdtAddMsg 71604, 10, '71604^Not Scan-out', 'us_english'
execute rdt.rdtAddMsg 71605, 10, '71605^Inv DropID', 'us_english'
execute rdt.rdtAddMsg 71606, 10, '71606^Not Scan-in', 'us_english'
execute rdt.rdtAddMsg 71607, 10, '71607^Not Scan-out', 'us_english'
execute rdt.rdtAddMsg 71608, 10, '71608^Diff Storer', 'us_english'

execute rdt.rdtAddMsg 71609, 10, '71609^SKU Req', 'us_english'
execute rdt.rdtAddMsg 71610, 10, '71610^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 71611, 10, '71611^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 71612, 10, '71612^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 71613, 10, '71613^Invalid SKU', 'us_english'

execute rdt.rdtAddMsg 71614, 10, '71614^Invalid SKU', 'us_english'

execute rdt.rdtAddMsg 71615, 10, '71615^Lottable01 req', 'us_english'
execute rdt.rdtAddMsg 71616, 10, '71616^Lottable02 req', 'us_english'
execute rdt.rdtAddMsg 71617, 10, '71617^Lottable03 req', 'us_english'
execute rdt.rdtAddMsg 71618, 10, '71618^Lottable04 req', 'us_english'
execute rdt.rdtAddMsg 71619, 10, '71619^Invalid date', 'us_english'

execute rdt.rdtAddMsg 71620, 10, '71620^Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 71621, 10, '71621^Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 71622, 10, '71622^QTY > Suggest', 'us_english'

execute rdt.rdtAddMsg 71623, 10, '71623^UpdPPAFailed', 'us_english'
execute rdt.rdtAddMsg 71624, 10, '71624^Invalid Reason', 'us_english'
execute rdt.rdtAddMsg 71625, 10, '71625^Bad ReasonCode', 'us_english'
execute rdt.rdtAddMsg 71626, 10, '71626^QTY > Suggest', 'us_english'
execute rdt.rdtAddMsg 71627, 10, '71627^QTY > Suggest', 'us_english'

-- SOS374911
execute rdt.rdtAddMsg 71628, 10, '71628^Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 71629, 10, '71629^SameBarcodeSKU', 'us_english'



