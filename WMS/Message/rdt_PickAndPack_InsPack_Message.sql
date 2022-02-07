-- rdt_PickAndPack_InsPack 
-- Note: This error # is from rdt_Cluster_Pick_ConfirmTask but reused in rdt_PickAndPack_InsPack

execute rdt.rdtAddMsg 66033, 10, '66033^UPDPKLockFail',    'us_english'
execute rdt.rdtAddMsg 66035, 10, '66035^InsPackDtlFail',   'us_english'
execute rdt.rdtAddMsg 66036, 10, '66036^InsPackDtlFail',   'us_english'
execute rdt.rdtAddMsg 66037, 10, '66037^UpdPackDtlFail',   'us_english'
execute rdt.rdtAddMsg 66038, 10, '66038^GenLabelFail',     'us_english'
execute rdt.rdtAddMsg 66039, 10, '66039^SKU Overpacked',   'us_english'
execute rdt.rdtAddMsg 66040, 10, '66040^InsPHdrFail',      'us_english'

-- WMS-16695
execute rdt.rdtAddMsg 66041, 10, '66041^GenLabelFail',     'us_english'