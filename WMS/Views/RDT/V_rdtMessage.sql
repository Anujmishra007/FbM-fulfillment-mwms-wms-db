SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [RDT].[V_rdtMessage]
AS
SELECT ISNULL(RTRIM(M.StoredProcName),'') AS StoredProcName
     , H.*
FROM rdt.rdtMessage H WITH (NOLOCK)
LEFT JOIN rdt.rdtMsg M WITH (NOLOCK)
ON (H.InFunc = M.Message_Id AND M.Message_Type <> 'DSP')
GO
GRANT DELETE ON  [RDT].[V_rdtMessage] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[V_rdtMessage] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[V_rdtMessage] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[V_rdtMessage] TO [NSQL]
GO
