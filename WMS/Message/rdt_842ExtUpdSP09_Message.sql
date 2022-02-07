--rdt_842ExtUpdSP09
execute rdt.rdtdropmsg 161851 , 161900

execute rdt.rdtAddMsg 161851, 10, '61851^NoRecToProcess',   'us_english', 842
execute rdt.rdtAddMsg 161852, 10, '61852^SKuNotIntote',     'us_english', 842
execute rdt.rdtAddMsg 161853, 10, '61853^QtyExceeded',      'us_english', 842
execute rdt.rdtAddMsg 161854, 10, '61854^InsPickHdrFail',   'us_english', 842
execute rdt.rdtAddMsg 161855, 10, '61855^UpdPickDetFail',   'us_english', 842
execute rdt.rdtAddMsg 161856, 10, '61856^CreatePHdrFail',   'us_english', 842
execute rdt.rdtAddMsg 161857, 10, '61857^NoLabelNoGen',     'us_english', 842
execute rdt.rdtAddMsg 161858, 10, '61858^UpdOrderFail',     'us_english', 842
execute rdt.rdtAddMsg 161859, 10, '61859^InsPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 161860, 10, '61860^UpdPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 161861, 10, '61861^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 161862, 10, '61862^InsPInfoFail',     'us_english', 842
execute rdt.rdtAddMsg 161863, 10, '61863^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 161864, 10, '61864^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 161865, 10, '61865^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 161866, 10, '61866^InvDropID',        'us_english', 842
execute rdt.rdtAddMsg 161867, 10, '61867^InsPickInfoFail',  'us_english', 842
execute rdt.rdtAddMsg 161868, 10, '61868^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 161869, 10, '61869^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 161870, 10, '61870^InvalidOption',    'us_english', 842
execute rdt.rdtAddMsg 161871, 10, '61871^PickNotDone',      'us_english', 842
execute rdt.rdtAddMsg 161872, 10, '61872^UpdPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 161873, 10, '61873^NoLabelNoGen',     'us_english', 842
execute rdt.rdtAddMsg 161874, 10, '61874^PickNotComplete',  'us_english', 842
execute rdt.rdtAddMsg 161875, 10, '61875^PickNotComplete',  'us_english', 842
execute rdt.rdtAddMsg 161876, 10, '61876^UpdPickDetFail',   'us_english', 842
execute rdt.rdtAddMsg 161877, 10, '61877^GetKeyFail',       'us_english', 842
execute rdt.rdtAddMsg 161878, 10, '61878^InsPickDetFail',   'us_english', 842
execute rdt.rdtAddMsg 161879, 10, '61879^InsPickDetFail',   'us_english', 842
execute rdt.rdtAddMsg 161880, 10, '61880^InsEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 161881, 10, '61881^UpdDropIDFail',    'us_english', 842
execute rdt.rdtAddMsg 161882, 10, '61882^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 161883, 10, '61883^NoPrinter842Ext',  'us_english', 842
execute rdt.rdtAddMsg 161884, 10, '61884^TrackNoInUsed',    'us_english', 842
execute rdt.rdtAddMsg 161885, 10, '61885^InsCtTrackFail',   'us_english', 842
execute rdt.rdtAddMsg 161886, 10, '61886^UpdPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 161887, 10, '61887^LabelPrinterReq',  'us_english', 842
execute rdt.rdtAddMsg 161888, 10, '61888^PaperPrinterReq',  'us_english', 842
execute rdt.rdtAddMsg 161889, 10, '61889^GetKeyFail     ',  'us_english', 842
execute rdt.rdtAddMsg 161890, 10, '61890^InsTL2Fail     ',  'us_english', 842
execute rdt.rdtAddMsg 161891, 10, '61891^SubmitQTaskFail',  'us_english', 842
execute rdt.rdtAddMsg 161892, 10, '61892^GetNewTrackNoEr',  'us_english', 842
execute rdt.rdtAddMsg 161893, 10, '61893^INS RDSNo Fail',   'us_english', 842
execute rdt.rdtAddMsg 161894, 10, '61894^SNO ady scan',     'us_english', 842

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 161851 AND 161900