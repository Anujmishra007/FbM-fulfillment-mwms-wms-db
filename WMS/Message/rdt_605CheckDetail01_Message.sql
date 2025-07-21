-- rdt_605CheckDetail01_Message.sql
execute rdt.rdtDropMsg 239351, 239400

execute rdt.rdtAddMsg 239351, 10, '239351ID does not exist in ASN', 'us_english', 605
execute rdt.rdtAddMsg 239352, 10, '239352ID has UCC that are not in New (0) Status', 'us_english', 605
execute rdt.rdtAddMsg 239353, 10, '239353ID in another PO', 'us_english', 605
