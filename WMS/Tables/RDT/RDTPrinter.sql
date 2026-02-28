IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RDT].[RDTPrinter]') AND type in (N'U'))
BEGIN
CREATE TABLE [RDT].[RDTPrinter]
(
[PrinterID] [nvarchar] (10) NOT NULL CONSTRAINT [DF_RDTPrinter_PrinterID] DEFAULT (''),
[Description] [nvarchar] (60) NOT NULL,
[WinPrinter] [nvarchar] (128) NOT NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_RDTPrinter_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_RDTPrinter_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_RDTPrinter_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NULL CONSTRAINT [DF_RDTPrinter_EditWho] DEFAULT (suser_sname()),
[PrinterGroup] [nvarchar] (20) NULL CONSTRAINT [DF_RDTPrinter_PrinterGroup] DEFAULT (''),
[VoicePrinterNo] [int] NULL CONSTRAINT [DF_RDTPrinter_VoicePrinterNo] DEFAULT ((0)),
[SpoolerGroup] [nvarchar] (20) NOT NULL CONSTRAINT [DF_rdtPrinter_SpoolerGroup] DEFAULT (''),
[ProcessType] [nvarchar](15) NOT NULL CONSTRAINT [DF_rdtPrinter_ProcessType] DEFAULT (''),
[SCEPrinterGroup] [nvarchar] (20) NOT NULL CONSTRAINT [DF_RDTPrinter_SCEPrinterGroup] DEFAULT (''),
[TPPrintergroup] [nvarchar] (20) NULL CONSTRAINT [DF_rdtPrinter_TPPrintergroup] DEFAULT ('')
) ON [PRIMARY]

ALTER TABLE [RDT].[RDTPrinter] ADD CONSTRAINT [PK_RDTPrinter] PRIMARY KEY CLUSTERED ([PrinterID]) WITH (FILLFACTOR=90) ON [PRIMARY]

EXEC sp_addextendedproperty N'MS_Description', 'Trade Partner Printer Device Group', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'TPPrintergroup'

EXEC sp_addextendedproperty N'MS_Description', 'A unique identifier for each printer in the system. This column serves as the primary key for the printer table, and is used to uniquely identify each printer in the system.', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'PrinterID'

EXEC sp_addextendedproperty N'MS_Description', 'Printer Description.', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'Description'

EXEC sp_addextendedproperty N'MS_Description', 'The name of the printer as it appears in the Windows Registry. This column is used to identify the printer on the Windows operating system.', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'WinPrinter'

EXEC sp_addextendedproperty N'MS_Description', 'The date and time when the printer was added to the system. ', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username or identifier of the user who added the printer to the system. ', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', 'The username or identifier of the user who last edited the printer settings.', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'EditWho'

EXEC sp_addextendedproperty N'MS_Description', 'The date and time when the printer was lasted edited the printer setting.', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'EditDate'

EXEC sp_addextendedproperty N'MS_Description', 'A grouping or categorization of RDT printers within the system.', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'PrinterGroup'

EXEC sp_addextendedproperty N'MS_Description', 'A Spooler Group ID which contain IP and Port for spooler server', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'SpoolerGroup'

EXEC sp_addextendedproperty N'MS_Description', 'A grouping or categorization of printers within the SCE system.', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'SCEPrinterGroup'

--GRANT SELECT ON  [RDT].[RDTPrinter] TO [JReportRole]

GRANT DELETE ON  [RDT].[RDTPrinter] TO [NSQL]

GRANT INSERT ON  [RDT].[RDTPrinter] TO [NSQL]

GRANT SELECT ON  [RDT].[RDTPrinter] TO [NSQL]

GRANT UPDATE ON  [RDT].[RDTPrinter] TO [NSQL]


END
ELSE
BEGIN

		IF NOT EXISTS (SELECT * FROM sys.columns WHERE NAME ='ProcessType' AND object_id = OBJECT_ID(N'[RDT].[DF_rdtPrinter_ProcessType]'))
BEGIN
	
	ALTER TABLE [RDT].[RDTPrinter] 
	ADD [ProcessType] [nvarchar](15) NOT NULL CONSTRAINT [DF_rdtPrinter_ProcessType] DEFAULT ('');
	EXEC sp_addextendedproperty N'MS_Description', 'ProcessType', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrinter', 'COLUMN', N'ProcessType'

END

END



--SET QUOTED_IDENTIFIER OFF
--GO
--SET ANSI_NULLS OFF
--GO
--/************************************************************************/
--/* Trigger: ntrRdtPrinterUpdate                                         */
--/* Creation Date: 07-Jun-2019                                           */
--/* Copyright: IDS                                                       */
--/* Written by:                                                          */
--/*                                                                      */
--/* Purpose:  RdtPrinter Update Transaction                              */
--/*                                                                      */
--/* Called By: When update records                                       */
--/*                                                                      */
--/* PVCS Version: 1.0                                                    */
--/* Data Modifications:                                                  */
--/*                                                                      */
--/* Updates:                                                             */
--/* Date         Author    Purposes                                      */
--/************************************************************************/

--CREATE TRIGGER [RDT].[ntrRdtPrinterUpdate]
--ON  [RDT].[RDTPrinter]
--FOR UPDATE
--AS
--BEGIN
--   IF @@ROWCOUNT = 0
--   BEGIN
--      RETURN
--   END

--   SET NOCOUNT ON
--   SET ANSI_NULLS OFF
--   SET QUOTED_IDENTIFIER OFF
--   SET CONCAT_NULL_YIELDS_NULL OFF

--   DECLARE @b_Success   INT          -- Populated by calls to stored procedures - was the proc successful?
--         , @n_err       INT          -- Error number returned by stored procedure or this trigger
--         , @n_err2      INT          -- For Additional Error Detection
--         , @c_errmsg    NVARCHAR(250)-- Error message returned by stored procedure or this trigger
--         , @n_continue  INT
--         , @n_starttcnt INT          -- Holds the current transaction count
--         , @n_cnt       INT

--   SELECT  @b_Success         = 0
--         , @n_err             = 0
--         , @n_err2            = 0
--         , @c_errmsg          = ''
--         , @n_continue        = 1
--         , @n_starttcnt       = @@TRANCOUNT

--   IF ( @n_continue=1 OR @n_continue=2 ) AND NOT UPDATE(EditDate)
--   BEGIN
--      UPDATE RDTPrinter
--          SET EditDate = GETDATE(),
--              EditWho = SUSER_SNAME()
--      FROM RDT.RDTPrinter RDTPrinter, INSERTED
--      WHERE RDTPrinter.[PrinterID] =INSERTED.[PrinterID]
      
--      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
--      IF @n_err <> 0
--      BEGIN
--         SELECT @n_continue = 3
--         SELECT @n_err = 62850 --66700   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
--         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table RDTPrinter. (ntrRdtPrinterUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
--      END
--   END

--   /* #INCLUDE <TRAHU2.SQL> */
--   IF @n_continue = 3  -- Error Occured - Process And Return
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

--         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
--      END
--      ELSE
--      BEGIN
--         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
--         BEGIN
--            ROLLBACK TRAN
--         END
--         ELSE
--         BEGIN
--            WHILE @@TRANCOUNT > @n_starttcnt
--            BEGIN
--               COMMIT TRAN
--       END
--         END
--         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRdtPrinterUpdate'
--         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
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