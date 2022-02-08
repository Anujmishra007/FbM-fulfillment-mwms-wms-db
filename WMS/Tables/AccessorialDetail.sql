CREATE TABLE [dbo].[AccessorialDetail]
(
[Accessorialkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccessorialDetailkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_AccessorialDetailkey] DEFAULT (' '),
[Descrip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_Descrip] DEFAULT (' '),
[Rate] [decimal] (22, 6) NOT NULL,
[Base] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_Base] DEFAULT ('Q'),
[MasterUnits] [decimal] (12, 6) NOT NULL CONSTRAINT [DF_AccessorialDetail_MasterUnits] DEFAULT ((1.0)),
[UomShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AccessorialDetail_UomShow] DEFAULT (' '),
[TaxGroupKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_TaxGroupKey] DEFAULT ('XXXXXXXXXX'),
[GLDistributionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_GLDistributionKey] DEFAULT ('XXXXXXXXXX'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AccessorialDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AccessorialDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccessorialDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[CostRate] [decimal] (22, 6) NULL CONSTRAINT [DF_AccessorialDetail_CostRate] DEFAULT ((0.0)),
[CostBase] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AccessorialDetail_CostBase] DEFAULT ('Q'),
[CostMasterUnits] [decimal] (12, 6) NULL CONSTRAINT [DF_AccessorialDetail_CostMasterUnits] DEFAULT ((1.0)),
[CostUOMShow] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AccessorialDetail_CostUOMShow] DEFAULT (' ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/************************************************************************/  
/* Trigger: ntrAccessorialDetailUpdate                                  */  
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
  
CREATE TRIGGER [dbo].[ntrAccessorialDetailUpdate]  
ON  [dbo].[AccessorialDetail]   
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
      UPDATE AccessorialDetail  
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME()
        FROM AccessorialDetail, INSERTED  
       WHERE AccessorialDetail.AccessorialDetailkey = INSERTED.AccessorialDetailkey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table AccessorialDetail. (ntrAccessorialDetailUpdate)' + ' ( '   
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrAccessorialDetailUpdate'  
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
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [CK_AccDet_Base] CHECK (([Base]='R' OR [Base]='F' OR [Base]='C' OR [Base]='G' OR [Base]='Q'))
GO
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [CK_AccDet_CostBase] CHECK (([CostBase]='R' OR [CostBase]='F' OR [CostBase]='C' OR [CostBase]='G' OR [CostBase]='Q'))
GO
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [CK_AccDet_MU] CHECK (([MasterUnits]>(0.0)))
GO
ALTER TABLE [dbo].[AccessorialDetail] ADD CONSTRAINT [PKAccessorialDetail] PRIMARY KEY CLUSTERED ([AccessorialDetailkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [FK_AccDet_GLDist_01] FOREIGN KEY ([GLDistributionKey]) REFERENCES [dbo].[GLDistribution] ([GLDistributionKey])
GO
ALTER TABLE [dbo].[AccessorialDetail] WITH NOCHECK ADD CONSTRAINT [FKAccessorialDetail] FOREIGN KEY ([Accessorialkey]) REFERENCES [dbo].[Accessorial] ([Accessorialkey])
GO
GRANT DELETE ON  [dbo].[AccessorialDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[AccessorialDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[AccessorialDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[AccessorialDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accessorial Detail.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'AccessorialDetailkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Accessorial.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'Accessorialkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Accessorial Detail.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'Descrip'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying GL Distribution.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'GLDistributionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The cost per unit of a commodity or service.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'Rate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Tax Group.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'TaxGroupKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'AccessorialDetail', 'COLUMN', N'TrafficCop'
GO
