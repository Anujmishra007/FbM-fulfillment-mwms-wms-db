CREATE TABLE [dbo].[NonItrn]
(
[NonItrnKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NonInvSku] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TranType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonItrn_TranType] DEFAULT (' '),
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonItrn_ToLoc] DEFAULT (' '),
[Qty] [int] NULL CONSTRAINT [DF_NonItrn_Qty] DEFAULT ((0)),
[ReferenceNumber] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonItrn_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_NonItrn_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NonItrn_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_NonItrn_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Trigger: ntrNonItrnAdd                                                  */
/* Creation Date: 20-Sep-2012                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose:  Update other transactions while NonItrn line is to be inserted*/
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Inserted                                        */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrNonItrnAdd] ON [dbo].[NonItrn] 
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue  INT                     
         , @n_StartTCnt INT            -- Holds the current transaction count    
         , @b_Success   INT            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err       INT            -- Error number returned by stored procedure or this trigger    
         , @c_errmsg    NVARCHAR(255)   -- Error message returned by stored procedure or this trigger    

   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT     

   UPDATE NONINV WITH (ROWLOCK)
      SET NONINV.CurrentBalance = CurrentBalance + INSERTED.Qty
        , NONINV.LastLoc  = INSERTED.ToLoc
        , NONINV.EditDate = GETDATE() 
        , NONINV.EditWho  = SUSER_SNAME()
     FROM INSERTED 
    WHERE NONINV.Facility  = INSERTED.Facility
      AND NONINV.StorerKey = INSERTED.StorerKey
      AND NONINV.NonInvSku = INSERTED.NonInvSku

   SET @n_err = @@ERROR

   IF @n_err <> 0
   BEGIN
      SET @n_continue = 3
      SET @n_err=63701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg = 'NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+': Update Failed On Table NONINV. (ntrNonItrnAdd)' 
      GOTO QUIT
   END         


QUIT:
   /* #INCLUDE <TRRDA2.SQL> */    
   IF @n_Continue=3  -- Error Occured - Process And Return    
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrNonItrnAdd'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR  

 
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
ALTER TABLE [dbo].[NonItrn] ADD CONSTRAINT [PK_NonItrn] PRIMARY KEY CLUSTERED ([NonItrnKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[NonItrn] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[NonItrn] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[NonItrn] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[NonItrn] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[NonItrn] TO [NSQL]
GO
