-- rdtVFUCCRcvExtCheck
execute rdt.rdtDropMsg 79451, 79500

execute rdt.rdtAddMsg 79451, 10, '79451^Invalid format', 'us_english', 898
execute rdt.rdtAddMsg 79452, 10, '79452^UCC not in ASN', 'us_english', 898
execute rdt.rdtAddMsg 79453, 10, '79453^L01 not in ASN', 'us_english', 898
execute rdt.rdtAddMsg 79454, 10, '79454^L02 not in ASN', 'us_english', 898
execute rdt.rdtAddMsg 79455, 10, '79455^L03 not in ASN', 'us_english', 898
execute rdt.rdtAddMsg 79456, 10, '79456^L04 not empty ', 'us_english', 898
execute rdt.rdtAddMsg 79457, 10, '79457^MixMultiSKUUCC', 'us_english', 898
execute rdt.rdtAddMsg 79458, 10, '79458^MixCheckingUCC', 'us_english', 898
execute rdt.rdtAddMsg 79459, 10, '79459^MixMinorityUCC', 'us_english', 898
execute rdt.rdtAddMsg 79460, 10, '79460^ID,UCC DiffSKU', 'us_english', 898
execute rdt.rdtAddMsg 79461, 10, '79461^ID,UCC DiffQTY', 'us_english', 898
execute rdt.rdtAddMsg 79462, 10, '79462^MixFullChkUCC ', 'us_english', 898
execute rdt.rdtAddMsg 79463, 10, '79463^MixPartialChk ', 'us_english', 898
execute rdt.rdtAddMsg 79464, 10, '79464^ID,UCC Diff PO', 'us_english', 898
