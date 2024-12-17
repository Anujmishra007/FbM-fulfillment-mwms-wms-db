--rdtfnc_Multi_ID_Putaway
execute rdt.rdtDropMsg 224551, 224600

execute rdt.rdtAddMsg 224551, 10, '224551 LOC Req!    ',   'us_english', 747
execute rdt.rdtAddMsg 224552, 10, '224552 ID with no SHLV location SKU on trolley',   'us_english', 747,0,'224552ID With No SHLV Location SKU On Trolley'
execute rdt.rdtAddMsg 224553, 10, '224553 ID Without Putaway Location On Trolley',   'us_english', 747,0,'224553ID Without Putaway Location On Trolley'
execute rdt.rdtAddMsg 224554, 10, '224554IDWithHoldOnTrolley','us_english', 747
execute rdt.rdtAddMsg 224555, 10, '224555Location Not Determined','us_english',747,0,'224555No Available Location or SKU Does Not Fit'
execute rdt.rdtAddMsg 224556, 10, '224556Location Not Matched','us_english',747
execute rdt.rdtAddMsg 224557, 10, '224557ID Not Matched','us_english',747
execute rdt.rdtAddMsg 224558, 10, '224558Invalid ID','us_english',747
execute rdt.rdtAddMsg 224559, 10, '224559LPNAlreadyOnTrolley','us_english',747
execute rdt.rdtAddMsg 224560, 10, '224560LPWithoutSKUTypeSHLV','us_english',747,0,'224560LPN Without SKU Type SHLV'
execute rdt.rdtAddMsg 224561, 10, '224561Invalid Loc','us_english',747
execute rdt.rdtAddMsg 224562, 10, '224562Putaway Of ID Already Started','us_english',747,0,'224562Putaway Of ID Already Started'
execute rdt.rdtAddMsg 224563, 10, '224563NoOtherIDToPutaway','us_english',747
execute rdt.rdtAddMsg 224564, 10, '224564LPN Is On Hold','us_english',747
execute rdt.rdtAddMsg 224565, 10, '224565Cannot Hold QC Loc','us_english',747

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 224551 AND 224600