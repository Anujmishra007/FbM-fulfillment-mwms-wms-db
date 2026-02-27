IF NOT EXISTS ( SELECT * FROM sys.objects where object_id = OBJECT_ID (N'[RDT].[RDTDynamicPickLog]') AND TYPE IN ('N','U'))
BEGIN
CREATE TABLE [RDT].[RDTDynamicPickLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Zone] [nvarchar] (10) NOT NULL,
[LOC] [nvarchar] (10) NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_LOC] DEFAULT (''),
[PickSlipNo] [nvarchar] (10) NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_PickSlipNo] DEFAULT (''),
[CartonNo] [int] NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_CartonNo] DEFAULT ((0)),
[LabelNo] [nvarchar] (20) NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_LabelNo] DEFAULT (''),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_AddWho] DEFAULT (user_name()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_AddDate] DEFAULT (getdate()),
[FromLOC] [nvarchar] (10) NOT NULL CONSTRAINT [DF_rdtDynamicPickLog_FromLOC] DEFAULT (''),
[ToLOC] [nvarchar] (10) NOT NULL CONSTRAINT [DF_rdtDynamicPickLog_ToLOC] DEFAULT (''),
[Facility] [nvarchar] (5) NOT NULL CONSTRAINT [DF_rdtDynamicPickLog_Facility] DEFAULT (''),
[SKU] [nvarchar] (20) NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_SKU] DEFAULT (''),
[ActQty] [int] NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_ActQty] DEFAULT ((0)),
[Status] [nvarchar] (10) NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_Status] DEFAULT ('0')
) ON [PRIMARY]

GRANT DELETE ON  [RDT].[RDTDynamicPickLog] TO [NSQL]

GRANT INSERT ON  [RDT].[RDTDynamicPickLog] TO [NSQL]

GRANT SELECT ON  [RDT].[RDTDynamicPickLog] TO [NSQL]

GRANT UPDATE ON  [RDT].[RDTDynamicPickLog] TO [NSQL]

EXEC sp_addextendedproperty N'MS_Description', 'ActQty', 'SCHEMA', N'RDT', 'TABLE', N'RDTDynamicPickLog', 'COLUMN', N'ActQty'

EXEC sp_addextendedproperty N'MS_Description', N'Capture Facility', 'SCHEMA', N'RDT', 'TABLE', N'RDTDynamicPickLog', 'COLUMN', N'Facility'

EXEC sp_addextendedproperty N'MS_Description', N'Capture From Location', 'SCHEMA', N'RDT', 'TABLE', N'RDTDynamicPickLog', 'COLUMN', N'FromLOC'

EXEC sp_addextendedproperty N'MS_Description', 'SKU', 'SCHEMA', N'RDT', 'TABLE', N'RDTDynamicPickLog', 'COLUMN', N'SKU'

EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'RDT', 'TABLE', N'RDTDynamicPickLog', 'COLUMN', N'Status'

EXEC sp_addextendedproperty N'MS_Description', N'Capture To Location', 'SCHEMA', N'RDT', 'TABLE', N'RDTDynamicPickLog', 'COLUMN', N'ToLOC'

END


ELSE 
BEGIN

		IF NOT EXISTS ( SELECT * FROM SYS.columns WHERE name = 'SKU' AND  object_id = OBJECT_ID (N'[RDT].[RDTDynamicPickLog]'))
		BEGIN 

			ALTER TABLE [RDT].[RDTDynamicPickLog]
			ADD SKU [nvarchar] (20) NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_SKU] DEFAULT ('');
			EXEC sp_addextendedproperty N'MS_Description', 'SKU', 'SCHEMA', N'RDT', 'TABLE', N'RDTDynamicPickLog', 'COLUMN', N'SKU'

		END


		IF NOT EXISTS ( SELECT * FROM SYS.columns WHERE name = 'ActQty' AND  object_id = OBJECT_ID (N'[RDT].[RDTDynamicPickLog]'))
		BEGIN 

			ALTER TABLE [RDT].[RDTDynamicPickLog]
			ADD [ActQty] [int] NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_ActQty] DEFAULT ((0));
			EXEC sp_addextendedproperty N'MS_Description', 'ActQty', 'SCHEMA', N'RDT', 'TABLE', N'RDTDynamicPickLog', 'COLUMN', N'ActQty'

		END

		IF NOT EXISTS ( SELECT * FROM SYS.columns WHERE name = 'Status' AND  object_id = OBJECT_ID (N'[RDT].[RDTDynamicPickLog]'))
		BEGIN 

			ALTER TABLE [RDT].[RDTDynamicPickLog]
			ADD [Status] [nvarchar] (10) NOT NULL CONSTRAINT [DF_RDTDynamicPickLog_Status] DEFAULT ('0');
			EXEC sp_addextendedproperty N'MS_Description', 'Status', 'SCHEMA', N'RDT', 'TABLE', N'RDTDynamicPickLog', 'COLUMN', N'Status'

		END



END



--SET QUOTED_IDENTIFIER OFF
--GO
--SET ANSI_NULLS OFF
--GO

--/******************************************************************************/
--/* Store Procedure: rdt.ntrRDTDynamicPickLogAdd                               */
--/* Copyright: LF Logistics                                                    */
--/*                                                                            */
--/* Modification log:                                                          */
--/* Date         Author     Ver   Purposes                                     */
--/* 16-Aug-2013  Ung        1.0   Created                                      */
--/* 13-Apr-2014  TLTING     1.2   SQL2012                                      */
--/* 15-Aug-2014  Ung        1.3   Add WITH (NOLOCK)                            */
--/******************************************************************************/
--CREATE TRIGGER [RDT].[ntrRDTDynamicPickLogAdd] ON [RDT].[RDTDynamicPickLog] FOR INSERT AS
--BEGIN
--   SET NOCOUNT ON
--   SET ANSI_NULLS OFF
--   SET QUOTED_IDENTIFIER OFF
--   SET CONCAT_NULL_YIELDS_NULL OFF

--   DECLARE
--      @n_continue    INT
--     ,@n_starttcnt   INT
--     ,@n_err         INT
--     ,@c_errmsg      NVARCHAR( 20)
--     ,@c_Zone        NVARCHAR( 10)
--     ,@c_LOC         NVARCHAR( 10)
--     ,@c_PickSlipNo  NVARCHAR( 10)

--   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

--   DECLARE CURSOR_INSERTED CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
--   SELECT INSERTED.Zone, INSERTED.LOC, INSERTED.PickSlipNo
--   FROM INSERTED WITH (NOLOCK)

--   OPEN CURSOR_INSERTED               
--   FETCH NEXT FROM CURSOR_INSERTED INTO @c_Zone, @c_LOC, @c_PickSlipNo

--   WHILE @@FETCH_STATUS = 0          
--   BEGIN 
--      -- Lock entire pickslip
--      IF @c_LOC = ''
--      BEGIN
--         -- PickSlip already locked by others
--         IF EXISTS( SELECT TOP 1 1 
--            FROM rdt.rdtDynamicPickLog WITH (NOLOCK)
--            WHERE PickSlipNo = @c_PickSlipNo
--               AND Zone = @c_Zone
--               AND AddWho <> SUSER_NAME())
--         BEGIN
--            SET @n_continue = 3
--            SET @n_err = 84101
--            SET @c_errmsg = '84101^LockPSNoFail'
--            BREAK
--         END
--      END
      
--      -- Lock pickslip by LOC range
--      IF @c_LOC <> ''
--      BEGIN
--         -- PickSlip already locked by others
--         IF EXISTS( SELECT TOP 1 1 
--            FROM rdt.rdtDynamicPickLog WITH (NOLOCK)
--            WHERE PickSlipNo = @c_PickSlipNo 
--               AND Zone = @c_Zone
--               AND AddWho <> SUSER_NAME() 
--               AND (LOC = '' OR LOC = @c_LOC))
--         BEGIN
--            SET @n_continue = 3
--            SET @n_err = 84102
--            SET @c_errmsg = '84102^LockPSNoFail'
--            BREAK
--         END
--      END
--      FETCH NEXT FROM CURSOR_INSERTED INTO @c_Zone, @c_LOC, @c_PickSlipNo
--   END

--   IF @n_continue=3  -- Error Occured - Process And Return
--   BEGIN
--      DECLARE @n_IsRDT INT
--      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

--      IF @n_IsRDT = 1
--      BEGIN
--         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
--         -- Instead we commit and raise an error back to parent, let the parent decide

--         -- Commit until the level we begin with
--         WHILE @@TRANCOUNT > @n_starttcnt
--            COMMIT TRAN

--         -- Raise error with severity = 10, instead of the default severity 16.
--         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
--         RAISERROR (@n_err, 10, 1) WITH SETERROR

--        -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
--      END
--      ELSE
--      BEGIN
--         IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
--         BEGIN
--            ROLLBACK TRAN
--         END
--         ELSE
--         BEGIN
--            WHILE @@TRANCOUNT > @n_starttcnt
--            BEGIN
--               COMMIT TRAN
--            END
--         END
--         execute nsp_logerror @n_err, @c_errmsg, "ntrRDTDynamicPickLogAdd"
--         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
--         --RAISERROR @n_err @c_errmsg
--         RETURN
--      END
--   END
--   ELSE
--   BEGIN
--      WHILE @@TRANCOUNT > @n_starttcnt
--      BEGIN
--         COMMIT TRAN
--      END
--      RETURN
--   END
--END
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--SET ANSI_NULLS ON
--GO

--/******************************************************************************/  
--/* Store Procedure:  ntrRDTDynamicPickLogDelete                               */  
--/* Copyright: LF Logistics                                                    */  
--/*                                                                            */  
--/* Purpose:  VFCDC Debugging Script                                           */  
--/*                                                                            */  
--/* Modification log:                                                          */  
--/* Date         Author     Ver   Purposes                                     */  
--/* 22-May-2014  Ung        1.0   Add DELLOG for troubleshoot                  */
--/* 16-JUN-2016  JayLim      1.1  SQL2012 compatibility modification (Jay01)   */
--/******************************************************************************/  
----DROP TRIGGER ntrRDTDynamicPickLogDelete  
--CREATE TRIGGER [RDT].[ntrRDTDynamicPickLogDelete]  
--ON  [RDT].[RDTDynamicPickLog]  
--FOR DELETE  
--AS  
--BEGIN  
--   SET NOCOUNT ON  
--   SET ANSI_NULLS OFF  
--   SET QUOTED_IDENTIFIER OFF  
--   SET CONCAT_NULL_YIELDS_NULL OFF  
  
--   DECLARE
--      @n_continue    INT
--     ,@n_starttcnt   INT
--     ,@n_err         INT
--     ,@c_errmsg      NVARCHAR( 20)

--   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
  
--   INSERT INTO rdt.RDTDynamicPickLog_DELLOG (Zone, LOC, PickSlipNo, CartonNo, LabelNo, AddWho, AddDate)
--   SELECT Zone, LOC, PickSlipNo, CartonNo, LabelNo, AddWho, AddDate
--   FROM DELETED
  
--QUIT:  
  
--   /* #INCLUDE <TRRDA2.SQL> */  
--   IF @n_continue=3  -- Error Occured - Process And Return  
--   BEGIN  
--      DECLARE @n_IsRDT INT  
--      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT  
  
--      IF @n_IsRDT = 1  
--      BEGIN  
--         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here  
--         -- Instead we commit and raise an error back to parent, let the parent decide  
  
--         -- Commit until the level we begin with  
--         WHILE @@TRANCOUNT > @n_starttcnt  
--            COMMIT TRAN  
  
--         -- Raise error with severity = 10, instead of the default severity 16.  
--         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger  
--         RAISERROR (@n_err, 10, 1) WITH SETERROR  
  
--        -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten  
--      END  
--      ELSE  
--      BEGIN  
--         IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt  
--         BEGIN  
--            ROLLBACK TRAN  
--         END  
--         ELSE  
--         BEGIN  
--            WHILE @@TRANCOUNT > @n_starttcnt  
--            BEGIN  
--               COMMIT TRAN  
--            END  
--         END  
--         execute nsp_logerror @n_err, @c_errmsg, "ntrRDTDynamicPickLogDelete"  
--         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR -- SQL 2012 (Jay01)  
--      END  
--   END  
--   ELSE  
--   BEGIN  
--      WHILE @@TRANCOUNT > @n_starttcnt  
--      BEGIN  
--         COMMIT TRAN  
--      END  
--      RETURN  
--   END  
--END
--GO
--SET QUOTED_IDENTIFIER OFF
--GO
--SET ANSI_NULLS OFF
--GO

--CREATE TRIGGER [RDT].[ntrRDTDynamicPickLogUpdate]
--ON  [RDT].[RDTDynamicPickLog] 
--FOR UPDATE AS
--   IF @@ROWCOUNT = 0
--   BEGIN
--      RETURN
--   END 

--   SET NOCOUNT ON
--   SET ANSI_NULLS OFF
--   SET QUOTED_IDENTIFIER OFF
--   SET CONCAT_NULL_YIELDS_NULL OFF
   
--   IF NOT UPDATE(AddDate)
--   BEGIN   
--      UPDATE [RDT].[RDTDynamicPickLog] WITH (ROWLOCK) SET
--         AddDate = GETDATE()
--      FROM [RDT].[RDTDynamicPickLog]
--         INNER JOIN [INSERTED] ON [RDT].[RDTDynamicPickLog].RowRef = [INSERTED].RowRef
--   END   
--GO
