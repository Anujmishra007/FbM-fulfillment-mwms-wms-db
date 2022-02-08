CREATE TABLE [dbo].[SerialNo]
(
[SerialNoKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NULL CONSTRAINT [DF_SerialNo_Qty] DEFAULT ((0)),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_SerialNo_AddDate] DEFAULT (getdate()),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SerialNo_Status] DEFAULT ('0'),
[LotNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_SerialNo_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SerialNo_EditWho] DEFAULT (suser_sname()),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERIALNO_ID] DEFAULT (''),
[ExternStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERIALNO_ExternStatus] DEFAULT ('0'),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERIALNO_PickSlipNo] DEFAULT (''),
[CartonNo] [int] NULL CONSTRAINT [DF_SERIALNO_CartonNo] DEFAULT ((0)),
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERIALNO_LabelLine] DEFAULT (''),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UserDefine05] DEFAULT (''),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UCCNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SerialNo_UCCNo] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[SerialNo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[SerialNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SerialNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SerialNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SerialNo] TO [NSQL]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/************************************************************************/        
/* Trigger: ntrSerialNoDelete                                           */        
/* Creation Date:                                                       */        
/* Copyright: IDS                                                       */        
/* Written by:                                                          */        
/*                                                                      */        
/* Purpose: SOS#293687                                                  */        
/*                                                                      */        
/* Usage:                                                               */        
/*                                                                      */        
/* Called By: When records delete from SerialNo                         */        
/*                                                                      */        
/* PVCS Version: 1.0                                                    */        
/*                                                                      */        
/* Version: 5.4                                                         */        
/*                                                                      */        
/* Modifications:                                                       */        
/* Date         Author     Ver.  Purposes                               */    
/* 21-Oct-2014  KHLim      1.1   Insert Delete log  (KH01)              */
/* 03-Aug-2018  TLTING     1.2   ArchiveCop                             */
/************************************************************************/        
CREATE TRIGGER [dbo].[ntrSerialNoDelete] ON [dbo].[SerialNo]      
FOR  DELETE      
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
          
 DECLARE @b_Success          INT -- Populated by calls to stored procedures - was the proc successful?      
        ,@n_err              INT -- Error number returned by stored procedure or this trigger      
        ,@n_err2             INT -- For Additional Error Detection      
        ,@c_errmsg           NVARCHAR(250) -- Error message returned by stored procedure or this trigger      
        ,@n_continue         INT      
        ,@n_starttcnt        INT -- Holds the current transaction count      
        ,@c_preprocess       NVARCHAR(250) -- preprocess      
        ,@c_pstprocess       NVARCHAR(250) -- post process      
        ,@n_cnt              INT      
        ,@c_authority        NVARCHAR(1)      
 
 DECLARE @c_Pickdetailkey     NVARCHAR(10)    --(Kc01)
         ,@n_ShortPackQty     INT            --(Kc01)
        
 SELECT @n_continue = 1      
       ,@n_starttcnt = @@TRANCOUNT      

 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
                         
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start
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
               ,@c_errmsg = 'ntrSerialNoDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'       
      BEGIN
         INSERT INTO dbo.SerialNo_DELLOG ( SerialNoKey ) -- KH01
         SELECT SerialNoKey FROM DELETED                 -- KH01

         INSERT INTO dbo.DEL_SerialNo ( SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, Status, LotNo )     
         SELECT SerialNoKey, OrderKey, OrderLineNumber, StorerKey, SKU, SerialNo, Qty, Status, LotNo FROM DELETED  

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table SerialNo Failed. (ntrSerialNoDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END                  
      END
   END

 IF @n_continue=3 -- Error Occured - Process And Return      
 BEGIN      
     IF @@TRANCOUNT = 1      
     AND @@TRANCOUNT >= @n_starttcnt      
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
     EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrSerialNoDelete'       
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
SET ANSI_NULLS ON
GO
/************************************************************************/
/* Trigger: ntrSerialNoUpdate                                           */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:  KHLIM                                                   */
/*                                                                      */
/* Purpose:  SerialNo Update                                            */
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
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver.  Purposes                                  */
/* 28-Oct-2013  TLTING        Review Editdate column update             */
/* 19-SEP-2-17  Wan01   1.1   WMS-2931 - CN_DYSON_EXCEED_Serialno_CR    */
/* 18-Nov-2017  Leong   1.2   Revise error message. (L01).              */
/* 20-Nov-2017  Wan02   1.2   Fixed to filter by sku                    */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrSerialNoUpdate]
ON  [dbo].[SerialNo] FOR UPDATE
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

    /* #INCLUDE <TRTHU1.SQL> */


   IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE SerialNo
      SET EditDate = GETDATE(),
         EditWho = SUSER_SNAME()
      FROM SerialNo (NOLOCK), INSERTED (NOLOCK)
      WHERE SerialNo.SerialNoKey = INSERTED.SerialNoKey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table SerialNo. (ntrSerialNoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

   --(Wan01) - START

   IF UPDATE(TrafficCop)
   BEGIN
      SET @n_Continue = 4
   END

   DECLARE @c_SerialNoKey  NVARCHAR(10)
         , @c_SerialNo     NVARCHAR(30)
         , @c_Status_INS   NVARCHAR(10)
         , @c_Status_DEL   NVARCHAR(10)
         , @c_Storerkey    NVARCHAR(15)
         , @c_Sku          NVARCHAR(20)
         , @c_SNStatus     NVARCHAR(10)
         , @c_ORDStatus    NVARCHAR(10)

         , @b_Reject       INT

    DECLARE @cur_SN        CURSOR
         ,  @cur_CL        CURSOR

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      SET @cur_SN = CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT I.SerialNoKey
            ,I.SerialNo
            ,I.Storerkey
            ,I.Sku
            ,I.Status
            ,D.Status
      FROM INSERTED I WITH (NOLOCK)
      JOIN DELETED D WITH (NOLOCK) ON (I.SerialNoKey = D.SerialNoKey )
      WHERE I.Status <> D.Status

      OPEN @cur_SN

      FETCH NEXT FROM @cur_SN INTO @c_SerialNoKey, @c_SerialNo, @c_Storerkey, @c_Sku, @c_Status_INS, @c_Status_DEL

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         IF @n_Continue = 1
         BEGIN
            SET @c_SNStatus = '9' -- Open/Shipped

            SET @n_Cnt = 0
            SELECT @n_Cnt = 1
            FROM PACKSERIALNO PSN WITH (NOLOCK)
            JOIN PACKHEADER   PH  WITH (NOLOCK) ON (PSN.PickSlipNo = PH.PickSlipNo)
            WHERE PSN.Storerkey = @c_Storerkey
            AND   PSN.SerialNo  = @c_SerialNo
            AND   PSN.Sku = @c_Sku                    --(Wan02)
            AND   PH.Status < '9'

            IF @n_Cnt = 1
            BEGIN
               SET @c_SNStatus = '1' -- Packing Progress
            END

            IF @n_Cnt = 0
            BEGIN
               SET @c_SNStatus = '9' -- Open/Shipped
               -- Check Orders Shipment By Orderkey   - Discrete Pack
               SELECT @n_Cnt       = COUNT(1)
                     ,@c_ORDStatus = ISNULL(MIN(OH.Status),0)
               FROM PACKSERIALNO PSN WITH (NOLOCK)
               JOIN PACKHEADER   PH  WITH (NOLOCK) ON (PSN.PickSlipNo = PH.PickSlipNo)
               JOIN ORDERS       OH  WITH (NOLOCK) ON (PH.Orderkey = OH.Orderkey)
               WHERE PSN.Storerkey = @c_Storerkey
               AND   PSN.SerialNo  = @c_SerialNo
               AND   PSN.Sku = @c_Sku                 --(Wan02)
               AND   PH.Orderkey <> ''
               GROUP BY PH.Orderkey                   --(Wan02)
               HAVING ISNULL(MIN(OH.Status),0) < '9'  --(Wan02)

               IF @n_Cnt >= 1 AND @c_ORDStatus < '9'  --(Wan02)
               BEGIN
                  SET @c_SNStatus = '6' -- Pending Shipment Progress
               END

               IF @n_Cnt = 0
               BEGIN
                  -- Check Orders Shipment By Loadkey - Consolidate Pack
                  SELECT @n_Cnt       = COUNT(1)
                        ,@c_ORDStatus = ISNULL(MIN(OH.Status),0)
                  FROM PACKSERIALNO PSN WITH (NOLOCK)
                  JOIN PACKHEADER   PH  WITH (NOLOCK) ON (PSN.PickSlipNo = PH.PickSlipNo)
                  JOIN ORDERS       OH  WITH (NOLOCK) ON (PH.Loadkey = OH.Loadkey)
                  WHERE PSN.Storerkey = @c_Storerkey
                  AND   PSN.SerialNo  = @c_SerialNo
                  AND   PSN.Sku       = @c_Sku           --(Wan02)
                  AND   PH.Orderkey   = ''
                  GROUP BY PH.Loadkey                    --(Wan02)     
                  HAVING ISNULL(MIN(OH.Status),0) < '9'  --(Wan02)
               END

               IF @n_Cnt >= 1 AND @c_ORDStatus < '9'     --(Wan02)    
               BEGIN
                  SET @c_SNStatus = '6' -- Pending Shipment Progress
               END
            END

            SET @b_Reject = 0
            IF @c_SNStatus = '1' AND @c_Status_INS NOT IN( '1' )
            BEGIN
               SET @b_Reject = 1
            END

            IF @c_SNStatus = '6' AND @c_Status_INS NOT IN( '6' )
            BEGIN
               SET @b_Reject = 1
            END

            IF @c_SNStatus = '9' AND @c_Status_INS NOT IN ( '0', '1', 'H', 'CANC', '9') --L01 (Temp)
            BEGIN
               SET @b_Reject = 1
            END
            
            IF @b_Reject = 1
            BEGIN
               SET @n_Continue = 3
               SET @n_err = 69710
               SET @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+ ': SN:' + ISNULL(RTRIM(@c_SerialNo),'') + '/' +
                              ISNULL(RTRIM(@c_SNStatus),'') + '/' + ISNULL(RTRIM(@c_Status_INS),'') + '/' +
                              ISNULL(RTRIM(@c_Storerkey),'')+ '/' + ISNULL(RTRIM(@c_Sku),'') +
                              '. Invalid Status Change. Change Abort.(ntrSerialNoUpdate)' -- L01
            END
         END
         FETCH NEXT FROM @cur_SN INTO @c_SerialNoKey, @c_SerialNo, @c_Storerkey, @c_Sku, @c_Status_INS, @c_Status_DEL
      END
   END
   --(Wan01) - END


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
      execute nsp_logerror @n_err, @c_errmsg, 'ntrSerialNoUpdate'
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
ALTER TABLE [dbo].[SerialNo] ADD CONSTRAINT [PK_SerialNo] PRIMARY KEY NONCLUSTERED ([SerialNoKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_SerialNo_Orders] ON [dbo].[SerialNo] ([OrderKey], [OrderLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SerialNo_Pack] ON [dbo].[SerialNo] ([PickSlipNo], [CartonNo], [LabelLine]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StorerKey_SerialNo] ON [dbo].[SerialNo] ([StorerKey], [SerialNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SerialNo_UCCNo] ON [dbo].[SerialNo] ([UCCNo], [SKU], [StorerKey]) INCLUDE ([SerialNo], [Status]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Packing - Carton #', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ExternStatus', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'ExternStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Packing - Label Line #', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'LabelLine'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Packing - Pick Slip #', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Serial Number.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'SerialNoKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UCC No', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UCCNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 01', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 02', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 03', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 04', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User define 05', 'SCHEMA', N'dbo', 'TABLE', N'SerialNo', 'COLUMN', N'UserDefine05'
GO
