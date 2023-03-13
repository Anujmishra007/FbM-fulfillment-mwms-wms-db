--rdt_841ExtUpdSP33
execute rdt.rdtDropMsg 197601 , 197601		

execute rdt.rdtAddMsg 197601, 10, '197601SKuNotIntote  ',      'us_english',841
execute rdt.rdtAddMsg 197602, 10, '197602SKUNotInOrder ',      'us_english',841
execute rdt.rdtAddMsg 197603, 10, '19760 Qty Exceeded  ',      'us_english',841
execute rdt.rdtAddMsg 197604, 10, '193304GetPKSlip#Fail',      'us_english',841
execute rdt.rdtAddMsg 197605, 10, '197605InstPKHdrFail ',      'us_english',841
execute rdt.rdtAddMsg 197606, 10, '197606ScanIn Fail   ',      'us_english',841
execute rdt.rdtAddMsg 197607, 10, '197607InsPackHDRFail',      'us_english',841
execute rdt.rdtAddMsg 197608, 10, '197608Over Packed   ',      'us_english',841
execute rdt.rdtAddMsg 197609, 10, '197609UPDPKDETFailed',      'us_english',841
execute rdt.rdtAddMsg 197610, 10, '197610Get Label Fail',      'us_english',841
execute rdt.rdtAddMsg 197611, 10, '197611Ins PKDET Fail',      'us_english',841
execute rdt.rdtAddMsg 197612, 10, '197612Ins PKDET Fail',      'us_english',841
execute rdt.rdtAddMsg 197613, 10, '197613InsPInfoFail  ',      'us_english',841
execute rdt.rdtAddMsg 197614, 10, '197614Upd EcommFail ',      'us_english',841
execute rdt.rdtAddMsg 197615, 10, '197615Pack Cfm Fail ',      'us_english',841
execute rdt.rdtAddMsg 197616, 10, '197616UpdOrdFail    ',      'us_english',841
execute rdt.rdtAddMsg 197617, 10, '197617UpdEcommFail  ',      'us_english',841


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 197601 AND 197601	