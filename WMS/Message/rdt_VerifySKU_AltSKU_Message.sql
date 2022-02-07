-- rdt_VerifySKU_AltSKU
execute rdt.rdtDropMsg 122151, 122200

execute rdt.rdtAddMsg 122151, 10, '122151Need ALT SKU  ', 'us_english', 537
execute rdt.rdtAddMsg 122152, 10, '122152Invalid ALTSKU', 'us_english', 537
