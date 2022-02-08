CREATE TABLE [dbo].[GUIDetail]
(
[InvoiceNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LineNumber] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_GUIDetail_Qty] DEFAULT ((0)),
[UnitPrice] [money] NOT NULL CONSTRAINT [DF_GUIDetail_UnitPrice] DEFAULT ((0)),
[Amount] [money] NOT NULL CONSTRAINT [DF_GUIDetail_Amount] DEFAULT ((0)),
[DiscAmount] [money] NOT NULL CONSTRAINT [DF_GUIDetail_DiscAmount] DEFAULT ((0)),
[SKUDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUIDetail_SKUDesc] DEFAULT (' '),
[UOM] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GUIDetail_UOM] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_GUIDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_GUIDetail_AddWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remarks] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUIDetail_Remarks] DEFAULT (' '),
[IndicatorFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL CONSTRAINT [DF_GUIDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GUIDetail_EditWho] DEFAULT (suser_sname()),
[UserDefine01] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine06] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine07] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine08] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine09] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine10] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrGUIDetailUpdate                                          */
/* Creation Date: 19-Aug-2011                                           */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Handle trigger point of GUIDetail table updates.            */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  Any related Updates of table GUIDetail.                  */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Date         Author     Purposes                                     */
/* 28-Oct-2013  TLTING     Review Editdate column update                */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrGUIDetailUpdate]
ON  [dbo].[GUIDetail]
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

   DECLARE   
    @b_Success    int       -- Populated by calls to stored procedures - was the proc successful?
   ,@n_err        int       -- Error number returned by stored procedure or this trigger
   ,@n_err2       int       -- For Additional Error Detection
   ,@c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,@n_continue   int
   ,@n_starttcnt  int       -- Holds the current transaction count
   ,@c_preprocess NVARCHAR(250) -- preprocess
   ,@c_pstprocess NVARCHAR(250) -- post process
   ,@n_cnt int

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
	BEGIN 	
	 	UPDATE GUIDetail WITH (ROWLOCK) 
    	   SET EditDate   = GETDATE(), 
             EditWho    = SUser_SName() 
        FROM GUIDetail
        JOIN INSERTED ON (GUIDetail.InvoiceNo      = INSERTED.InvoiceNo
                      AND GUIDetail.StorerKey      = INSERTED.StorerKey
                      AND GUIDetail.ExternOrderKey = INSERTED.ExternOrderKey
                      AND GUIDetail.LineNumber     = INSERTED.LineNumber) 

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	 	IF @n_err <> 0
    	BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68001   
    	   SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) + 
                            ': Update Failed On Table GUIDetail. (ntrGUIDetailUpdate)' + ' ( ' + 
                            ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
    	END
	END

	/* #INCLUDE <TRRDA2.SQL> */    
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

      EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'ntrGUIDetailUpdate'    
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
ALTER TABLE [dbo].[GUIDetail] ADD CONSTRAINT [PK_GUIDetail] PRIMARY KEY CLUSTERED ([InvoiceNo], [ExternOrderkey], [Storerkey], [LineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GUIDetail_ExternOrderkey] ON [dbo].[GUIDetail] ([ExternOrderkey], [Storerkey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GUIDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[GUIDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[GUIDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[GUIDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by Storer.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Invoice.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'Remarks'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'SKUDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 4', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 5', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 6', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 7', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 8', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 9', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User defined field 10', 'SCHEMA', N'dbo', 'TABLE', N'GUIDetail', 'COLUMN', N'UserDefine10'
GO
