CREATE TABLE [dbo].[BillOfMaterial]
(
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_Storerkey] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_Sku] DEFAULT (' '),
[ComponentSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_ComponentSku] DEFAULT (' '),
[Sequence] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_Sequence] DEFAULT (' '),
[BomOnly] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_BomOnly] DEFAULT (' '),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_Notes] DEFAULT (' '),
[Qty] [int] NOT NULL CONSTRAINT [DF_BillOfMaterial_Qty] DEFAULT ((1)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BillOfMaterial_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BillOfMaterial_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BillOfMaterial_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentQty] [int] NOT NULL CONSTRAINT [DF_BillOfMaterial_ParentQty] DEFAULT ((1)),
[UDF01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BillOfMaterial_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************  
*  Author  : Ricky Yee                                        *  
*  Date    : Nov 24th, 2007                                   *  
*  Purpose : To Check against the Inventory upon              *  
*         the deletion of the BOM record.                     *  
*         If Inventory > 0, Delete Not Allow                  *  
*                                                             *  
* Date        Rev  Author   Purposes                          *   
* 24-Nov-2007 1.0  Ricky    Created                           *  
* 26-Nov-2007 1.1  Vicky    Add in StorerConfigkey to control *  
*                           deletion (Vicky01)                *  
* 19-Apr-2011 1.2  TLTING   Insert Delete log                 *
* 14-Jul-2011 1.3  KHLim02  GetRight for Delete log           *
***************************************************************/  
  
CREATE TRIGGER [dbo].[ntrBillOfMaterialDelete]  
ON  [dbo].[BillOfMaterial]   
FOR DELETE  
AS  
BEGIN  
 IF @@ROWCOUNT = 0  
 BEGIN  
  RETURN  
 END  
  
 SET CONCAT_NULL_YIELDS_NULL OFF  
   
 DECLARE  
 @b_Success                      int       -- Populated by calls to stored procedures - was the proc successful?  
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger  
 ,         @n_err2               int       -- For Additional Error Detection  
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
 ,         @n_continue           int                   
 ,         @n_starttcnt          int       -- Holds the current transaction count  
 ,         @c_preprocess         NVARCHAR(250) -- preprocess  
 ,         @c_pstprocess         NVARCHAR(250) -- post process  
 ,         @n_cnt                int        
 ,         @c_authority          NVARCHAR(1)  -- KHLim02
 
   DECLARE @cStorerkey   NVARCHAR(15) -- (Vicky01)  
   
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
 if (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END  
 IF @n_continue = 1 or @n_continue = 2  
 BEGIN   
     -- (Vicky01 - Start)  
     IF EXISTS (SELECT 1 FROM StorerConfig SCFG (NOLOCK)  
                JOIN DELETED ON (DELETED.Storerkey = SCFG.Storerkey)  
                WHERE SCFG.Configkey = 'PrepackByBOM'  
                AND   SCFG.sValue = '1')  
     BEGIN -- (Vicky01 - End)  
     IF (Select Count(1) from lotattribute la (nolock), lotxlocxid lli (nolock), DELETED    
          Where la.lot = lli.lot   
            And DELETED.storerkey = LA.storerkey   
            And DELETED.sku = LA.lottable03   
            And DELETED.componentsku = LA.sku  
            And lli.qty > 0) > 0   
         BEGIN  
           SELECT @n_continue = 3  
           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 60001   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
           SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Inventory Exists! Delete trigger On BillOfMaterial Failed. (ntrBillOfMaterialDelete)" 
           + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "  
         END  
      END -- Configkey  
 END  

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
               ,@c_errmsg = 'ntrBillOfMaterialDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.BillOfMaterial_DELLOG ( StorerKey, Sku, ComponentSku )
         SELECT StorerKey, Sku, ComponentSku FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table BillOfMaterial Failed. (ntrBillOfMaterialDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
    execute nsp_logerror @n_err, @c_errmsg, "ntrBillOfMaterialDelete"  
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


/************************************************************************/
/* Trigger: ntrBillofMaterialUpdate                                     */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  BillofMaterial Update Transaction                          */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When update records                                       */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* 23-May-2012  TLTING02         DM Data integrity - update editdate    */
/*                               B4 trafficCop                          */
/* 28-Oct-2013  TLTING           Review Editdate column update          */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrBillofMaterialUpdate]
ON  [dbo].[BillOfMaterial] FOR UPDATE
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
			, @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
			, @n_continue   int                 
			, @n_starttcnt  int       -- Holds the current transaction count
			, @c_preprocess NVARCHAR(250) -- preprocess
			, @c_pstprocess NVARCHAR(250) -- post process
			, @n_cnt        int                  

	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

	IF UPDATE(ArchiveCop)
	BEGIN
		SELECT @n_continue = 4 
	END
	
	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE BillOfMaterial
		SET EditDate = GETDATE(),
		    EditWho = SUSER_SNAME(),
          TrafficCop = NULL
		FROM BillOfMaterial (NOLOCK), INSERTED (NOLOCK)
    WHERE BillOfMaterial.Storerkey = INSERTED.Storerkey
	   AND BillOfMaterial.SKU = INSERTED.SKU
	   AND BillOfMaterial.ComponentSKU = INSERTED.ComponentSKU
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BillOfMaterial. (ntrBillofMaterialUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
		END
	END

	IF UPDATE(TrafficCop)
	BEGIN
		SELECT @n_continue = 4 
	END
	
	   /* #INCLUDE <TRTHU1.SQL> */     

      /* #INCLUDE <TRTHU2.SQL> */
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
		execute nsp_logerror @n_err, @c_errmsg, 'ntrBillofMaterialUpdate'
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
ALTER TABLE [dbo].[BillOfMaterial] ADD CONSTRAINT [PKBillOfMaterial] PRIMARY KEY CLUSTERED ([Storerkey], [Sku], [ComponentSku]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BillOfMaterial_01] ON [dbo].[BillOfMaterial] ([Storerkey], [ComponentSku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BillofMaterial_UDF01] ON [dbo].[BillOfMaterial] ([UDF01], [Storerkey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BillOfMaterial] WITH NOCHECK ADD CONSTRAINT [FK_BillOfMaterial_SKU_01] FOREIGN KEY ([Storerkey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
GRANT SELECT ON  [dbo].[BillOfMaterial] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[BillOfMaterial] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BillOfMaterial] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BillOfMaterial] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BillOfMaterial] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Bill of Material (BOM). The WMS allows user to kit a Commodity by creating a BOM that identifies the primary SKU and each of the component SKU(s)', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether this component must be kitted before shipping. Normally, standard will put ''Y'' use for commodity kitting.', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'BomOnly'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity code for the component being kitted', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'ComponentSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional comment on kitting or assembly', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of this component that is required in each kit', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Order in which component should be assembled into the kit. For example: if this component should be the third component placed in this package, enter 3 in the field', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Sequence'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code identifying the master commodity record under which all components are kitted', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The owner of the product', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BillOfMaterial', 'COLUMN', N'TrafficCop'
GO
