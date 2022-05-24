SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE TRIGGER [RDT].[ntrRDTTaskManagerConfigUpdate] 
ON [RDT].[rdtTaskManagerConfig] 
FOR UPDATE 
AS
BEGIN
   UPDATE rdt.rdtTaskManagerConfig WITH (ROWLOCK)
    SET EditDate = GETDATE(),
        EditWho = SUSER_SNAME()
   FROM rdt.rdtTaskManagerConfig, INSERTED
   WHERE rdt.rdtTaskManagerConfig.TaskType = INSERTED.TaskType
END
GO