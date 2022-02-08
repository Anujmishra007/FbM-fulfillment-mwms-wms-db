CREATE TABLE [dbo].[ALERT]
(
[AlertKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModuleName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AlertMessage] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Severity] [int] NOT NULL CONSTRAINT [DF_ALERT_Severity] DEFAULT ((5)),
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_ALERT_LogDate] DEFAULT (getdate()),
[UserId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ALERT_UserId] DEFAULT (suser_sname()),
[NotifyId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ALERT_NotifyId] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ALERT_Status] DEFAULT ('0'),
[Resolution] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ALERT_Resolution] DEFAULT (' '),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[Activity] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_Activity] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_Storerkey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_SKU] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_UOM] DEFAULT (''),
[UOMQty] [int] NULL CONSTRAINT [DF_ALERT_UOMQty] DEFAULT ((0)),
[Qty] [int] NULL CONSTRAINT [DF_ALERT_Qty] DEFAULT ((0)),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_Lot] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_Loc] DEFAULT (''),
[ID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_ID] DEFAULT (''),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_TaskDetailKey] DEFAULT (''),
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_UCCNo] DEFAULT (''),
[ResolveDate] [datetime] NULL,
[TaskDetailKey2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ALERT_TaskDetailKey2] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*********************************************************************************/  
/* Trigger:  ntrAlertDelete                                                      */
/* Creation Date:                                                                */
/* Copyright: IDS                                                                */
/* Written by:                                                                   */
/*                                                                               */
/* Purpose:  Trigger point upon any delete on the Alert (SOS#257259)             */
/*                                                                               */
/* Return Status:  None                                                          */
/*                                                                               */
/* Usage:                                                                        */
/*                                                                               */
/* Local Variables:                                                              */
/*                                                                               */
/* Called By: When records deleted                                               */
/*                                                                               */
/* PVCS Version: 1.0                                                             */
/*                                                                               */
/* Version: 5.4                                                                  */
/*                                                                               */
/* Data Modifications:                                                           */
/*                                                                               */
/* Updates:                                                                      */
/* Date         Author    Ver.  Purposes                                         */
/*********************************************************************************/  

CREATE TRIGGER [dbo].[ntrAlertDelete]
ON  [dbo].[ALERT]
FOR DELETE
AS
BEGIN -- main
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END     
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
         , @n_err                int       -- Error number returned by stored procedure or this trigger
         , @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
         , @n_continue           int                 
         , @n_starttcnt          int       -- Holds the current transaction count
         
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4 
   END

   IF (@n_continue = 1 or @n_continue = 2) 
   BEGIN
   	  DELETE TASKDETAIL 
   	  FROM TASKDETAIL 
   	  JOIN DELETED ON DELETED.Taskdetailkey2 = TASKDETAIL.Taskdetailkey
   	  WHERE TASKDETAIL.Listkey = 'ALERT' 
   	  AND TASKDETAIL.Sourcetype = 'TMCCRLSE'
   	  AND TASKDETAIL.Status NOT IN('9','X')
   	  AND NOT EXISTS (SELECT 1 FROM ALERT (NOLOCK) 
   	                  JOIN DELETED ON ALERT.Taskdetailkey2 = DELETED.Taskdetailkey2 
   	                                   AND ALERT.Alertkey <> DELETED.Alertkey
   	                  WHERE ALERT.Status <> '9' 
   	                  AND ISNULL(ALERT.Taskdetailkey2,'') <> '')
                      
   END

   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
    IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
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
    EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrAlertDelete'
    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
    RETURN
   END
   ELSE
   BEGIN
    WHILE @@TRANCOUNT > @n_starttcnt
    BEGIN
       COMMIT TRAN
    END
    RETURN
   END
END -- main
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/  
/* Trigger:  ntrAlertUpdate                                                      */
/* Creation Date:                                                                */
/* Copyright: IDS                                                                */
/* Written by:                                                                   */
/*                                                                               */
/* Purpose:  Trigger point upon any Update on the Alert (SOS#240877)             */
/*                                                                               */
/* Return Status:  None                                                          */
/*                                                                               */
/* Usage:                                                                        */
/*                                                                               */
/* Local Variables:                                                              */
/*                                                                               */
/* Called By: When records updated                                               */
/*                                                                               */
/* PVCS Version: 1.0                                                             */
/*                                                                               */
/* Version: 5.4                                                                  */
/*                                                                               */
/* Data Modifications:                                                           */
/*                                                                               */
/* Updates:                                                                      */
/* Date         Author    Ver.  Purposes                                         */
/* 07-Nov-2012  NJOW01    1.0   257259-Auto delete releted TM CC task when       */
/*                              manually close alert.                            */
/*********************************************************************************/  

CREATE TRIGGER [dbo].[ntrAlertUpdate]
ON  [dbo].[ALERT]
FOR UPDATE
AS
BEGIN -- main
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END     
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
         , @n_err                int       -- Error number returned by stored procedure or this trigger
         , @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
         , @n_continue           int                 
         , @n_starttcnt          int       -- Holds the current transaction count
         , @c_TrafficCop         NCHAR(1)
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT      

   SELECT @c_TrafficCop = TrafficCop
   FROM INSERTED
   
   IF UPDATE(TrafficCop) AND @c_TrafficCop <> 'T'
   BEGIN
      SELECT @n_continue = 4 
   END

   IF (@n_continue = 1 or @n_continue = 2) AND UPDATE(Status)
   BEGIN
   	  IF EXISTS(SELECT * FROM INSERTED JOIN DELETED ON INSERTED.Alertkey = DELETED.Alertkey 
   	            WHERE INSERTED.Status <> DELETED.Status
   	            AND INSERTED.Status = '9')
   	  BEGIN
   	  	 UPDATE ALERT WITH (ROWLOCK)
   	  	 SET ALERT.Notifyid = SUSER_SNAME(),
   	  	     ALERT.Resolvedate = GETDATE(),
   	  	     ALERT.TrafficCop = NULL
   	  	 FROM ALERT JOIN INSERTED ON ALERT.Alertkey = INSERTED.Alertkey

         --NJOW01
         IF @c_TrafficCop <> 'T'
         BEGIN         	          	
   	  	   DELETE TASKDETAIL
   	  	   FROM TASKDETAIL 
   	  	   JOIN INSERTED ON INSERTED.Taskdetailkey2 = TASKDETAIL.Taskdetailkey
   	  	   WHERE TASKDETAIL.Listkey = 'ALERT' 
   	  	   AND TASKDETAIL.Sourcetype = 'TMCCRLSE'
   	  	   AND TASKDETAIL.Status NOT IN('9','X')
   	  	   AND NOT EXISTS (SELECT 1 FROM ALERT (NOLOCK) 
   	  	                   JOIN INSERTED ON ALERT.Taskdetailkey2 = INSERTED.Taskdetailkey2 
   	  	                                    AND ALERT.Alertkey <> INSERTED.Alertkey
   	  	                   WHERE ALERT.Status <> '9' 
   	  	                   AND ISNULL(ALERT.Taskdetailkey2,'') <> '')
   	  	 END
   	  END
   END

   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
    IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
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
    EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrAlertUpdate'
    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
    RETURN
   END
   ELSE
   BEGIN
    WHILE @@TRANCOUNT > @n_starttcnt
    BEGIN
       COMMIT TRAN
    END
    RETURN
   END
END -- main
GO
ALTER TABLE [dbo].[ALERT] ADD CONSTRAINT [PKALert] PRIMARY KEY CLUSTERED ([AlertKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ALERT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ALERT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ALERT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ALERT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Alert.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'AlertKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Message displayed when alert ', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'AlertMessage'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of stored procedures.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'ModuleName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The level of severity.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'Severity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Username/login ID of staff who logged in during the alert.', 'SCHEMA', N'dbo', 'TABLE', N'ALERT', 'COLUMN', N'UserId'
GO
