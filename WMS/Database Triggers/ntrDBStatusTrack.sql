SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 CREATE   TRIGGER [ntrDBStatusTrack] ON DATABASE FOR 
    CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE, 
    CREATE_FUNCTION,  ALTER_FUNCTION,  DROP_FUNCTION, 
    CREATE_TRIGGER,   ALTER_TRIGGER,   DROP_TRIGGER,
    CREATE_TABLE ,    ALTER_TABLE,     DROP_TABLE,
    CREATE_VIEW,      ALTER_VIEW,      DROP_VIEW
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   /* 
      Get event xml
      XML defination: http://schemas.microsoft.com/sqlserver/2006/11/eventdata/events.xsd
   */
   DECLARE @xmlEventData XML = EVENTDATA()
    
   DECLARE @cEventType NVARCHAR( 128)
   DECLARE @cLoginName NVARCHAR( 128)
   DECLARE @cSchemaName NVARCHAR( 128)
   DECLARE @cObjectName NVARCHAR( 128)
   DECLARE @cObjectType NVARCHAR( 128)
   DECLARE @cTSQL NVARCHAR( MAX)

   SET ANSI_NULLS ON
   SET ANSI_PADDING ON
   SET ANSI_WARNINGS ON
   -- SET ARITHABORT ON
   SET CONCAT_NULL_YIELDS_NULL ON
   -- SET NUMERIC_ROUNDABORT OFF
   SET QUOTED_IDENTIFIER ON

   -- Get data in XML
   SELECT
      @cEventType  = @xmlEventData.value('(/EVENT_INSTANCE/EventType)[1]',  'NVARCHAR(128)'), 
      @cLoginName  = @xmlEventData.value('(/EVENT_INSTANCE/LoginName)[1]',  'NVARCHAR(128)'),
      @cSchemaName = @xmlEventData.value('(/EVENT_INSTANCE/SchemaName)[1]', 'NVARCHAR(128)'), 
      @cObjectName = @xmlEventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(128)'), 
      @cObjectType = @xmlEventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(128)'),
      @cTSQL       = @xmlEventData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)')

   SET ANSI_NULLS OFF
   SET ANSI_PADDING OFF
   SET ANSI_WARNINGS OFF
   -- SET ARITHABORT ON
   SET CONCAT_NULL_YIELDS_NULL OFF
   -- SET NUMERIC_ROUNDABORT OFF
   SET QUOTED_IDENTIFIER OFF

   -- Insert log
   INSERT INTO dbo.DBStatusTrack (ObjName, Type, TSQL)
   VALUES ( @cObjectName, @cObjectType, @cTSQL)
END

GO
