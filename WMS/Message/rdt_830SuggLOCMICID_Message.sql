--rdt_830SuggLOCMICID
--219986

EXEC rdt.rdtDropMsg 219986, 219986

EXECUTE rdt.rdtAddMsg 219986, 10, '219986^No more task',       'us_english', 830, 0, '219986 No more task'
EXECUTE rdt.rdtAddMsg 219986, 10, '219986^No más tarea',       'ES',         830, 0, '219986 No más tarea'
EXECUTE rdt.rdtAddMsg 219986, 10, '219986^Não há mais tarefa', 'PT',         830, 0, '219986 Não há mais tarefa'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id = 219986
