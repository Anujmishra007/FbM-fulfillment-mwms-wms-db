CREATE TABLE [RDT].[RDTPrintJob]
(
[JobId] [int] NOT NULL IDENTITY(1, 1),
[JobName] [nvarchar] (50) NULL CONSTRAINT [DF_RDTPrintJob_JobName] DEFAULT (''),
[ReportID] [nvarchar] (10) NULL CONSTRAINT [DF_RDTPrintJob_ReportID] DEFAULT (''),
[JobStatus] [nvarchar] (1) NULL CONSTRAINT [DF_RDTPrintJob_JobStatus] DEFAULT ('0'),
[NextRun] [datetime] NULL,
[LastRun] [datetime] NULL,
[Datawindow] [nvarchar] (50) NULL CONSTRAINT [DF_RDTPrintJob_Datawindow] DEFAULT (''),
[NoOfParms] [int] NULL CONSTRAINT [DF_RDTPrintJob_NoOfParms] DEFAULT ((0)),
[Parm1] [nvarchar] (30) NULL,
[Parm2] [nvarchar] (30) NULL,
[Parm3] [nvarchar] (30) NULL,
[Parm4] [nvarchar] (30) NULL,
[Parm5] [nvarchar] (30) NULL,
[Parm6] [nvarchar] (30) NULL,
[Parm7] [nvarchar] (30) NULL,
[Parm8] [nvarchar] (30) NULL,
[Parm9] [nvarchar] (30) NULL,
[Parm10] [nvarchar] (30) NULL,
[Printer] [nvarchar] (50) NULL,
[NoOfCopy] [int] NULL,
[Mobile] [int] NULL,
[TargetDB] [nvarchar] (20) NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_RDTPrintJob_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NULL CONSTRAINT [DF_RDTPrintJob_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL,
[EditWho] [nvarchar] (128) NULL,
[PrintCount] [int] NULL CONSTRAINT [DF_RDTPrintJob_PrintCount] DEFAULT ((0)),
[PrintData] [nvarchar] (max) NULL CONSTRAINT [DF_RDTPrintJob_PrintData] DEFAULT (''),
[JobType] [nvarchar] (10) NULL CONSTRAINT [DF_RDTPrintJob_JobType] DEFAULT ('DATAWINDOW'),
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_rdtPrintJob_StorerKey] DEFAULT (''),
[ExportFileName] [nvarchar] (50) NULL CONSTRAINT [DF_RDTPrintJob_ExportFileName] DEFAULT (''),
[Function_ID] [int] NOT NULL CONSTRAINT [DF_RDTPrintJob_Function_ID] DEFAULT ((0)),
[Parm11] [nvarchar] (30) NULL,
[Parm12] [nvarchar] (30) NULL,
[Parm13] [nvarchar] (30) NULL,
[Parm14] [nvarchar] (30) NULL,
[Parm15] [nvarchar] (30) NULL,
[Parm16] [nvarchar] (30) NULL,
[Parm17] [nvarchar] (30) NULL,
[Parm18] [nvarchar] (30) NULL,
[Parm19] [nvarchar] (30) NULL,
[Parm20] [nvarchar] (30) NULL,
[ReportLineNo] [nvarchar] (5) NULL,
[PDFPreview] [char] (1) NOT NULL CONSTRAINT [DF_RDTPrintJob_PDFPreview] DEFAULT ('N')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrRdtPrintJobUpdate                                        */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  RDTPRINTJOB Header Update Transaction                      */
/*                                                                      */
/* Called By: When update records                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 28-Oct-2013  TLTING     Review Editdate column update                */
/************************************************************************/

CREATE TRIGGER [RDT].[ntrRdtPrintJobUpdate]
ON  [RDT].[RDTPrintJob]
FOR UPDATE
AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END
   SET NOCOUNT ON
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success int       -- Populated by calls to stored procedures - was the proc successful?
			, @n_err int           -- Error number returned by stored procedure or this trigger
			, @n_err2 int          -- For Additional Error Detection
			, @c_errmsg NVARCHAR(250)  -- Error message returned by stored procedure or this trigger
			, @n_continue  int
			, @n_starttcnt int     -- Holds the current transaction count
         , @n_cnt       int

   SELECT  @b_Success			= 0 
			, @n_err					= 0 
			, @n_err2				= 0 
			, @c_errmsg				= '' 
			, @n_continue			= 1 
			, @n_starttcnt			= @@TRANCOUNT 

   IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE RDTPRINTJOB 
          SET EditDate = GETDATE(), 
              EditWho=SUSER_SNAME() 
      FROM RDT.RDTPRINTJOB RDTPRINTJOB, INSERTED
      WHERE RDTPRINTJOB.JobID =INSERTED.JobID
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 62850 --66700   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table RDTPRINTJOB. (ntrRdtPrintJobUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
      END
   END


   /* #INCLUDE <TRAHU2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT
   
      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide
   
         -- Commit until the level we begin with
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN
   
         -- Raise error with severity = 10, instead of the default severity 16. 
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
         RAISERROR (@n_err, 10, 1) WITH SETERROR 
   
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
      END
      ELSE
      BEGIN
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
         BEGIN
            ROLLBACK TRAN
         END
         ELSE
         BEGIN
            WHILE @@TRANCOUNT > @n_starttcnt
            BEGIN
               COMMIT TRAN
            END
         END
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRdtPrintJobUpdate'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
   END
   ELSE
   BEGIN   
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END

GO
ALTER TABLE [RDT].[RDTPrintJob] ADD CONSTRAINT [PK_RDTPrintJob] PRIMARY KEY CLUSTERED ([JobId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 11', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm11'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 12', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm12'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 13', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm13'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 14', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm14'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 15', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm15'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 16', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm16'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 17', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm17'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 18', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm18'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 19', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm19'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retrieval Parameter 20', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'Parm20'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SCE Report Line #', 'SCHEMA', N'RDT', 'TABLE', N'RDTPrintJob', 'COLUMN', N'ReportLineNo'
GO
GRANT DELETE ON  [RDT].[RDTPrintJob] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[RDTPrintJob] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[RDTPrintJob] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[RDTPrintJob] TO [NSQL]
GO
