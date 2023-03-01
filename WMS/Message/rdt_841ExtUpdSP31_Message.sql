--rdt_841ExtUpdSP31
execute rdt.rdtDropMsg 193301 , 193350		

execute rdt.rdtAddMsg 193301, 10, '193301 SKuNotIntote ',      'us_english',841
execute rdt.rdtAddMsg 193302, 10, '193302 SKUNotInOrder',      'us_english',841
execute rdt.rdtAddMsg 193303, 10, '193303 Qty Exceeded ',      'us_english',841
execute rdt.rdtAddMsg 193304, 10, '193304 UpdEcommFail ',      'us_english',841
execute rdt.rdtAddMsg 193305, 10, '193305 GetDetKeyFail',      'us_english',841
execute rdt.rdtAddMsg 193306, 10, '193306 InstPKHdrFail',      'us_english',841
execute rdt.rdtAddMsg 193307, 10, '193307 ScanIn Fail  ',      'us_english',841
execute rdt.rdtAddMsg 193308, 10, '193308InsPickHdrFail',      'us_english',841
execute rdt.rdtAddMsg 193309, 10, '193309UpdPickDetFail',      'us_english',841
execute rdt.rdtAddMsg 193310, 10, '193310CreatePHdrFail',      'us_english',841
execute rdt.rdtAddMsg 193311, 10, '193311 ToteCompleted',      'us_english',841
execute rdt.rdtAddMsg 193312, 10, '193312 GET LABEL Err',      'us_english',841
execute rdt.rdtAddMsg 193313, 10, '193313 No LabelNoGen',      'us_english',841
execute rdt.rdtAddMsg 193314, 10, '193314UpdPickDetFail',      'us_english',841
execute rdt.rdtAddMsg 193315, 10, '193315UpdPackDetFail',      'us_english',841
execute rdt.rdtAddMsg 193316, 10, '193316 OVER PACKED  ',      'us_english',841
execute rdt.rdtAddMsg 193317, 10, '193317InsPackDetFail',      'us_english',841
execute rdt.rdtAddMsg 193318, 10, '193318UpdPackDetFail',      'us_english',841
execute rdt.rdtAddMsg 193319, 10, '193319 InsPInfoFail ',      'us_english',841
execute rdt.rdtAddMsg 193320, 10, '193320 UpdEcommFail ',      'us_english',841
execute rdt.rdtAddMsg 193321, 10, '193321 UpdPackHdrErr',      'us_english',841
execute rdt.rdtAddMsg 193322, 10, '193322 UpdOrderFail ',      'us_english',841
execute rdt.rdtAddMsg 193323, 10, '193323UpdPickInfoErr',      'us_english',841
execute rdt.rdtAddMsg 193324, 10, '193324UpdPickDetFail',      'us_english',841
execute rdt.rdtAddMsg 193325, 10, '193325UpdPickDetFail',      'us_english',841
execute rdt.rdtAddMsg 193326, 10, '193326 UpdOrderFail ',      'us_english',841
execute rdt.rdtAddMsg 193327, 10, '193327 UpdEcommFail ',      'us_english',841


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 193301 AND 193350	