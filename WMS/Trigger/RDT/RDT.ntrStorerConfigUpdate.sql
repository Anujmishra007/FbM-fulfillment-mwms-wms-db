SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 28-Oct-2013  TLTING     Review Editdate column update                */


CREATE TRIGGER [RDT].[ntrStorerConfigUpdate] 
ON [RDT].[StorerConfig] 
FOR UPDATE 
AS
IF @@ROWCOUNT = 0
BEGIN
RETURN
END
   SET NOCOUNT ON
   SET ANSI_NULLS OFF   
   SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF
BEGIN
   IF NOT UPDATE(EditDate)
   BEGIN
      UPDATE rdt.StorerConfig WITH (ROWLOCK)
       SET EditDate = GETDATE(),
           EditWho = SUSER_SNAME()
      FROM rdt.StorerConfig, INSERTED
      WHERE rdt.StorerConfig.Function_ID = INSERTED.Function_ID
         AND rdt.StorerConfig.StorerKey = INSERTED.StorerKey
         AND rdt.StorerConfig.ConfigKey = INSERTED.ConfigKey
   END
END
GO