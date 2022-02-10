CREATE TABLE [RDT].[rdtCSAudit_Load]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[GroupID] [int] NOT NULL CONSTRAINT [DF_RDTCSAudit_Load_GroupID] DEFAULT ((0)),
[Vehicle] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Seal] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCSAudit_Load_Status] DEFAULT ('0'),
[RefNo1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo3] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo4] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefNo5] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCSAudit_Load_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDTCSAudit_Load_AddDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripID] [int] NOT NULL CONSTRAINT [DF_RDTCSAudit_Load_TripID] DEFAULT ((0)),
[CloseWho] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDTCSAudit_Load_CloseWho] DEFAULT (' '),
[CloseDate] [datetime] NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtCSAudit_Load_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtCSAudit_Load_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 28-Oct-2013  TLTING     Review Editdate column update                */

CREATE TRIGGER [RDT].[ntrRDTCSAudit_LoadUpdate]
ON [RDT].[rdtCSAudit_Load]
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   IF UPDATE(TrafficCop)  
   BEGIN  
      SELECT @n_continue = 4  
   END  
   IF UPDATE(ArchiveCop)  
   BEGIN  
      SELECT @n_continue = 4  
   END  

   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
	   UPDATE [RDT].[RDTCSAudit_Load] 
	   SET EditDate = GETDATE(),
	       EditWho  = SUSER_SNAME(),
	       TrafficCop = NULL
	   FROM [RDT].[RDTCSAudit_Load] (NOLOCK), INSERTED (NOLOCK)
	   WHERE [RDT].[RDTCSAudit_Load].RowRef = INSERTED.RowRef

	   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	   IF @n_err <> 0
	   BEGIN
		   SELECT @n_continue = 3
		   SELECT @n_err     = 62850   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		   SELECT @c_errmsg  = 'NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table RDTCSAudit_Load. (ntrRDTCSAudit_LoadUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRDTCSAudit_LoadUpdate'
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
ALTER TABLE [RDT].[rdtCSAudit_Load] ADD CONSTRAINT [PKRDTCSAudit_Load] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_Load_GroupID] ON [RDT].[rdtCSAudit_Load] ([GroupID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_Load_StorerKey_ConsigneeKey] ON [RDT].[rdtCSAudit_Load] ([StorerKey], [ConsigneeKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_RDTCSAudit_Load_Vehicle_CaseID] ON [RDT].[rdtCSAudit_Load] ([Vehicle], [CaseID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtCSAudit_Load] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtCSAudit_Load] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtCSAudit_Load] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtCSAudit_Load] TO [NSQL]
GO
