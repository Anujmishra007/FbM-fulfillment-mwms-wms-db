--rdt_841ExtUpdSP06
execute rdt.rdtdropmsg 132751 , 132800

execute rdt.rdtAddMsg 132751, 10, '32751^GetPKSlip#Fail',   'us_english',841
execute rdt.rdtAddMsg 132752, 10, '32752^InstPKHdrFail',    'us_english',841
execute rdt.rdtAddMsg 132753, 10, '32753^Scan In Fail',     'us_english',841
execute rdt.rdtAddMsg 132754, 10, '32754^InsPackHDRFail',   'us_english',841
execute rdt.rdtAddMsg 132755, 10, '32755^UPDPKDET Fail',    'us_english',841
execute rdt.rdtAddMsg 132756, 10, '32756^Get Label Fail',   'us_english',841
execute rdt.rdtAddMsg 132757, 10, '32757^Ins PKDET Fail',   'us_english',841
execute rdt.rdtAddMsg 132758, 10, '32758^Ins PKDET Fail',   'us_english',841
execute rdt.rdtAddMsg 132759, 10, '32759^Upd Ecomm Fail',   'us_english',841
execute rdt.rdtAddMsg 132760, 10, '32760^UpdCaseID Fail',   'us_english',841
execute rdt.rdtAddMsg 132761, 10, '32761^Pack Cfm Fail',    'us_english',841
execute rdt.rdtAddMsg 132762, 10, '32762^Upd Ecomm Fail',   'us_english',841

-- WMS-15010
execute rdt.rdtAddMsg 132763, 10, '32763^GetRightFail',     'us_english',841
execute rdt.rdtAddMsg 132764, 10, '32764^AutoMBOLPack',     'us_english',841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 132751 AND 132800

