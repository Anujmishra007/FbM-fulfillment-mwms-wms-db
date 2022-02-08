CREATE TABLE [dbo].[CARTONIZATION]
(
[CartonizationKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonizationGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_CartonizationGroup] DEFAULT (' '),
[CartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_CartonType] DEFAULT (' '),
[CartonDescription] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_CartonDescription] DEFAULT (' '),
[UseSequence] [int] NOT NULL CONSTRAINT [DF_CARTONIZATION_UseSequence] DEFAULT ((1)),
[Cube] [float] NOT NULL CONSTRAINT [DF_CARTONIZATION_Cube] DEFAULT ((0)),
[MaxWeight] [float] NOT NULL CONSTRAINT [DF_CARTONIZATION_MaxWeight] DEFAULT ((0)),
[MaxCount] [int] NOT NULL CONSTRAINT [DF_CARTONIZATION_MaxCount] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_CARTONIZATION_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_CARTONIZATION_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CARTONIZATION_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[CartonWeight] [float] NULL CONSTRAINT [DF_CARTONIZATION_CartonWeight] DEFAULT ((0)),
[CartonLength] [float] NULL CONSTRAINT [DF_CARTONIZATION_CartonLength] DEFAULT ((0)),
[CartonWidth] [float] NULL CONSTRAINT [DF_CARTONIZATION_CartonWidth] DEFAULT ((0)),
[CartonHeight] [float] NULL CONSTRAINT [DF_CARTONIZATION_CartonHeight] DEFAULT ((0)),
[Barcode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Cartonization_Barcode] DEFAULT (''),
[FillTolerance] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 28-Jul-2020  kocy    1.0   GetRight for Delete log                */

CREATE TRIGGER [dbo].[ntrCartonizationHeaderDelete]
 ON [dbo].[CARTONIZATION]
 FOR DELETE
 AS
 BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
     RETURN
   END
  
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
   @n_err              int,       -- Error number returned by stored procedure or this trigger
   @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
   @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
   @n_starttcnt        int,       -- Holds the current transaction count
   @n_cnt              int,        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
   @c_authority        NVARCHAR(1)  -- KHLim02

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF (select count(*) from DELETED) = (select count(*) from DELETED where DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END
      /* #INCLUDE <TRTHD1.SQL> */      
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start (KHLim02)
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrCartonizationHeaderDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.Cartonization_DELLOG ( CartonizationKey )
         SELECT CartonizationKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table Cartonization Failed. (ntrCartonizationDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRTHD2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrCartonizationHeaderDelete"
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
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/  
/* Trigger:  ntrCARTONIZATIONUpdate                                              */
/* Creation Date:                                                                */
/* Copyright: IDS                                                                */
/* Written by:                                                                   */
/*                                                                               */
/* Purpose:  Trigger point upon any Update on the CARTONIZATION                  */
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
/*********************************************************************************/  

CREATE TRIGGER [dbo].[ntrCARTONIZATIONUpdate]
ON  [dbo].[CARTONIZATION]
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
   
   IF UPDATE(TrafficCop)  
   BEGIN
      SELECT @n_continue = 4 
   END

   IF (@n_continue = 1 or @n_continue = 2)  AND NOT UPDATE(EditDate)
   BEGIN
    	  	 UPDATE CARTONIZATION WITH (ROWLOCK)
   	  	 SET CARTONIZATION.EditWho = SUSER_SNAME(),
   	  	     CARTONIZATION.EditDate = GETDATE(),
   	  	     CARTONIZATION.TrafficCop = NULL
   	  	 FROM CARTONIZATION JOIN INSERTED ON CARTONIZATION.CartonizationKey = INSERTED.CartonizationKey
      SELECT @n_err = @@ERROR 
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=67404   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table CARTONIZATION. (ntrCARTONIZATIONUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
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
    EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrCARTONIZATIONUpdate'
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
ALTER TABLE [dbo].[CARTONIZATION] ADD CONSTRAINT [PKCartonization] PRIMARY KEY CLUSTERED ([CartonizationKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Cartonization_01] ON [dbo].[CARTONIZATION] ([CartonizationGroup], [CartonType], [UseSequence]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CARTONIZATION] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[CARTONIZATION] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[CARTONIZATION] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[CARTONIZATION] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[CARTONIZATION] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cartonization allows users to coordinate all inventories loaded into a carton, whether the carton is a box or an ocean going container.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Detail information regarding the carton', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Height of carton.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonHeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cartonization group name', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonizationGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A unique key assigned by WMS to identify the carton', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonizationKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Length of carton.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonLength'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A descriptive name of the type or size of carton used, such as small or medium', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Weight', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Width of carton.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'CartonWidth'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a commodity the carton can hold', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The maximum quantity of the Master Unit of Measure the carton can hold', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'MaxCount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The maximum gross weight the carton can hold', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'MaxWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A number that corresponds with the carton''s priority.   Use sequence is used to record the order in which a carton   should be selected within the cartonization group.', 'SCHEMA', N'dbo', 'TABLE', N'CARTONIZATION', 'COLUMN', N'UseSequence'
GO
