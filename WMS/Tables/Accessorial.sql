CREATE TABLE [dbo].[Accessorial]
(
[Accessorialkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_Descrip] DEFAULT (' '),
[SupportFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_SupportFlag] DEFAULT ('A'),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_StorerKey] DEFAULT (' '),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_SKU] DEFAULT (' '),
[ServiceKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_ServiceKey] DEFAULT ('XXXXXXXXXX'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Accessorial_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Accessorial_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Accessorial_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/************************************************************************/  
/* Trigger: ntrAccessorialUpdate                                        */  
/* Creation Date: 06-Jun-2016                                           */  
/* Copyright: IDS                                                       */  
/* Written by:  JayLim                                                  */  
/*                                                                      */  
/* Purpose:  Update EditWho & EditDate                                  */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When records Updated                                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Modifications:                                                       */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrAccessorialUpdate]  
ON  [dbo].[Accessorial]   
FOR UPDATE  
AS  
BEGIN  
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET ANSI_WARNINGS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF   
   DECLARE @b_Success int          -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err int              -- Error number returned by stored procedure or this trigger  
         , @n_err2 int             -- For Additional Error Detection  
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess NVARCHAR(250) -- preprocess  
         , @c_pstprocess NVARCHAR(250) -- post process  
         , @n_cnt int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF ( @n_continue = 1 OR @n_continue = 2  ) AND NOT UPDATE(EditDate) 
   BEGIN  
      UPDATE Accessorial  
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME()
        FROM Accessorial, INSERTED  
       WHERE Accessorial.Accessorialkey = INSERTED.Accessorialkey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table Accessorial. (ntrAccessorialUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(LTrim(RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
  
   /* #INCLUDE <TRPU_2.SQL> */  
   IF @n_continue=3  -- Error Occured - Process And Return  
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrAccessorialUpdate'  
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
ALTER TABLE [dbo].[Accessorial] WITH NOCHECK ADD CONSTRAINT [CK_ACCS_SupportFlag] CHECK (([SupportFLag]='D' OR [SupportFLag]='I' OR [SupportFLag]='A'))
GO
ALTER TABLE [dbo].[Accessorial] ADD CONSTRAINT [PKAccessorial] PRIMARY KEY CLUSTERED ([Accessorialkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Accessorial] WITH NOCHECK ADD CONSTRAINT [FKAccessorial] FOREIGN KEY ([ServiceKey]) REFERENCES [dbo].[Services] ([Servicekey])
GO
GRANT DELETE ON  [dbo].[Accessorial] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Accessorial] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Accessorial] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Accessorial] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accessorial.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'Accessorialkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Accessorial.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Service.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'ServiceKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Stock Keeping Unit. Refers to the identification number assigned to each SKU.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record. Owner of the commodity.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'Accessorial', 'COLUMN', N'TrafficCop'
GO
