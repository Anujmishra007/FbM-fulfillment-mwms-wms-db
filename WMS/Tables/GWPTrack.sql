CREATE TABLE [dbo].[GWPTrack]
(
[GiftCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_GiftCode] DEFAULT (''),
[RefNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_RefNo] DEFAULT (''),
[GiftFlag] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_GiftFlag] DEFAULT (''),
[Status] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_Status] DEFAULT ('0'),
[Sku] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_Sku] DEFAULT (''),
[UPC] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_UPC] DEFAULT (''),
[GiftDetail] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_GiftDetail] DEFAULT (''),
[Qty] [int] NOT NULL CONSTRAINT [DF_GWPTrack_Qty] DEFAULT ('0'),
[ReceivedQty] [int] NOT NULL CONSTRAINT [DF_GWPTrack_ReceivedQty] DEFAULT ('0'),
[Price] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_Price] DEFAULT (''),
[Source] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_Source] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GWPTrack_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_GWPTrack_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GWPTrack_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/  
/* Trigger: ntrGWPTrackUpdate                                              */  
/* Creation Date:                                                          */  
/* Copyright: IDS                                                          */  
/* Written by:                                                             */  
/*                                                                         */  
/* Purpose:  trace modified log                                            */  
/* Called By: When update records                                          */  
/*                                                                         */   
/* Data Modifications:                                                     */  
/*                                                                         */  
/* Updates:                                                                */  
/* Date         Author  Ver.  Purposes                                     */  
/* 31-03-21     kocy  1.0    Updates EditDate & EditWho                    */
/*                            On GWPTrack Table                            */ 
/***************************************************************************/ 

CREATE TRIGGER [dbo].[ntrGWPTrackUpdate]
ON [dbo].[GWPTrack] FOR UPDATE
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
  
   DECLARE @b_Success    int       -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err        int       -- Error number returned by stored procedure or this trigger  
         , @n_err2       int       -- For Additional Error Detection  
         , @c_errmsg     char(250) -- Error message returned by stored procedure or this trigger  
         , @n_continue   int                   
         , @n_starttcnt  int       -- Holds the current transaction count  
         , @c_preprocess char(250) -- preprocess  
         , @c_pstprocess char(250) -- post process  
         , @n_cnt        int

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   --IF UPDATE(ArchiveCop)    
   --BEGIN    
   --   SELECT @n_continue = 4     
   --END    
  
   IF ( @n_continue = 1 or @n_continue=2 )
   BEGIN  
      UPDATE [dbo].[GWPTrack]  
      SET EditDate = GETDATE(),  
          EditWho = SUSER_SNAME()  
      FROM [dbo].[GWPTrack] WITH (NOLOCK), INSERTED (NOLOCK)  
      WHERE [dbo].[GWPTrack].RefNo = INSERTED.RefNo 
      AND [dbo].[GWPTrack].GiftCode = INSERTED.GiftCode
      AND [dbo].[GWPTrack].GiftFlag = INSERTED.GiftFlag

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

       IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table GWPTrack. (ntrGWPTrackUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
      END
   END

 --  IF UPDATE(TrafficCop)
	--BEGIN
	--	SELECT @n_continue = 4 
	--END

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
      execute nsp_logerror @n_err, @c_errmsg, 'ntrGWPTrackUpdate'  
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
ALTER TABLE [dbo].[GWPTrack] ADD CONSTRAINT [PK_GWPTrack] PRIMARY KEY CLUSTERED ([GiftCode], [RefNo], [GiftFlag]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GWPTrack_RefNo] ON [dbo].[GWPTrack] ([RefNo]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Load Date', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Gift Code', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'GiftCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Gift Detail', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'GiftDetail'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Gift Flag', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'GiftFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Retail price per master unit of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Received Quantity', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'ReceivedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reference Number', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'RefNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique code identifying the product', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Source'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status of good and gift', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A unique number or barcode that identifies an individual product by UOM', 'SCHEMA', N'dbo', 'TABLE', N'GWPTrack', 'COLUMN', N'UPC'
GO
