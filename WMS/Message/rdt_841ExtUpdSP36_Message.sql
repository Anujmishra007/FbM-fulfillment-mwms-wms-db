--rdt_841ExtUpdSP36
execute rdt.rdtdropmsg 205101 , 205150	

execute rdt.rdtAddMsg 205101, 10, '205101 SKuNotIntote ',   'us_english',841
execute rdt.rdtAddMsg 205102, 10, '205102 SKUNotInOrder',   'us_english',841
execute rdt.rdtAddMsg 205103, 10, '205103 QtyExceeded  ',   'us_english',841
execute rdt.rdtAddMsg 205104, 10, '205104 UpdEcommFail ',   'us_english',841
execute rdt.rdtAddMsg 205105, 10, '205105 GetDetKeyFail',   'us_english',841
execute rdt.rdtAddMsg 205106, 10, '205106 InstPKHdrFail',   'us_english',841
execute rdt.rdtAddMsg 205107, 10, '205107 ScanInFail   ',   'us_english',841
execute rdt.rdtAddMsg 205108, 10, '205108InsPickHdrFail',   'us_english',841
execute rdt.rdtAddMsg 205109, 10, '205109UpdPickDetFail',   'us_english',841
execute rdt.rdtAddMsg 205110, 10, '205110CreatePHdrFail',   'us_english',841
execute rdt.rdtAddMsg 205111, 10, '205111 ToteCompleted',   'us_english',841
execute rdt.rdtAddMsg 205112, 10, '205112 NoLabelNoGen ',   'us_english',841
execute rdt.rdtAddMsg 205113, 10, '205113UpdPickDetFail',   'us_english',841
execute rdt.rdtAddMsg 205114, 10, '205114UpdPackDetFail',   'us_english',841
execute rdt.rdtAddMsg 205115, 10, '205115 Over Packed  ',   'us_english',841
execute rdt.rdtAddMsg 205116, 10, '205116InsPackDetFail',   'us_english',841
execute rdt.rdtAddMsg 205117, 10, '205117 InsPInfoFail ',   'us_english',841
execute rdt.rdtAddMsg 205118, 10, '205118 InsPInfoFail ',   'us_english',841
execute rdt.rdtAddMsg 205119, 10, '205119UpdPackDetFail',   'us_english',841
execute rdt.rdtAddMsg 205120, 10, '205120UpdPickDetFail',   'us_english',841
execute rdt.rdtAddMsg 205121, 10, '205121 UpdEcommFail ',   'us_english',841
execute rdt.rdtAddMsg 205122, 10, '205122 GetRightFail ',   'us_english',841
execute rdt.rdtAddMsg 205123, 10, '205123 AutoMBOLPack ',   'us_english',841
execute rdt.rdtAddMsg 205124, 10, '205124UpdPackHdrFail',   'us_english',841
execute rdt.rdtAddMsg 205125, 10, '205125 UpdOrdFail   ',   'us_english',841
execute rdt.rdtAddMsg 205126, 10, '205126 UpdPInfoFail ',   'us_english',841
execute rdt.rdtAddMsg 205127, 10, '205127UpdPackDetFail',   'us_english',841
execute rdt.rdtAddMsg 205128, 10, '205128UpdPickDetFail',   'us_english',841
execute rdt.rdtAddMsg 205129, 10, '205129 UpdOrdFail   ',   'us_english',841
execute rdt.rdtAddMsg 205130, 10, '205130 UpdEcommFail ',   'us_english',841

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 205101 AND 205150