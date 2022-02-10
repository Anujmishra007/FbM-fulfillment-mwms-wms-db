CREATE TABLE [RDT].[rdtWATLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Module] [nvarchar] (10) NOT NULL,
[UserName] [nvarchar] (128) NOT NULL,
[Location] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtWATLog_Location] DEFAULT (''),
[StartDate] [datetime] NOT NULL CONSTRAINT [DF_rdtWATLog_StartDate] DEFAULT (getdate()),
[TaskCode] [nvarchar] (20) NULL,
[Description] [nvarchar] (40) NULL,
[Status] [nvarchar] (1) NOT NULL CONSTRAINT [DF_rdtWATLog_Status] DEFAULT ('0'),
[EndDate] [datetime] NOT NULL,
[Comments] [nvarchar] (250) NULL,
[TrafficCop] [nvarchar] (1) NULL,
[ArchiveCop] [nvarchar] (1) NULL,
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtWATLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtWATLog_EditWho] DEFAULT (suser_sname()),
[UDF01] [nvarchar] (60) NULL CONSTRAINT [DF_rdtWatLog_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (60) NULL CONSTRAINT [DF_rdtWatLog_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (60) NULL CONSTRAINT [DF_rdtWatLog_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (60) NULL CONSTRAINT [DF_rdtWatLog_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (60) NULL CONSTRAINT [DF_rdtWatLog_UDF05] DEFAULT (''),
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_rdtWATLog_StorerKey] DEFAULT (''),
[Facility] [nvarchar] (5) NOT NULL CONSTRAINT [DF_rdtWATLog_Facility] DEFAULT (''),
[QTY] [nvarchar] (5) NOT NULL CONSTRAINT [DF_rdtWATLog_QTY] DEFAULT (''),
[GroupKey] [int] NOT NULL CONSTRAINT [DF_rdtWATLog_GroupKey] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [RDT].[ntrRDTWatLogUpdate]
ON [RDT].[rdtWATLog]
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
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 
                                      -- 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by DELETE statement that fired this trigger

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   IF UPDATE(ArchiveCop)  
   BEGIN  
      SELECT @n_continue = 4  
   END  

   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
	   UPDATE [RDT].[RDTWatLog] 
	   SET EditDate = GETDATE(),
	       EditWho  = SUSER_SNAME()
	   FROM [RDT].[RDTWatLog] (NOLOCK), INSERTED (NOLOCK)
	   WHERE [RDT].[RDTWatLog].RowRef = INSERTED.RowRef

	   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	   IF @n_err <> 0
	   BEGIN
		   SELECT @n_continue = 3
		   SELECT @n_err     = 62850   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		   SELECT @c_errmsg  = 'NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table RDTWatLog. (ntrRDTWatLogUpdate)'
                            + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRDTWatLogUpdate'
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
GRANT DELETE ON  [RDT].[rdtWATLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtWATLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtWATLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtWATLog] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Grouping multiple records under a group. First record RowRef is the GroupKey', 'SCHEMA', N'RDT', 'TABLE', N'rdtWATLog', 'COLUMN', N'GroupKey'
GO
