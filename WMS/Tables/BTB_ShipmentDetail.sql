CREATE TABLE [dbo].[BTB_ShipmentDetail]
(
[BTB_ShipmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BTB_ShipmentListNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BTB_ShipmentLineNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormNo] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_FormNo] DEFAULT (''),
[HSCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_HSCode] DEFAULT (''),
[PermitNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_PermitNo] DEFAULT (''),
[IssuedDate] [datetime] NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Sku] DEFAULT (''),
[SkuDescr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_SkuDescr] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UOM] DEFAULT (''),
[Price] [float] NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Price] DEFAULT ((0.00)),
[Currency] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Currency] DEFAULT (''),
[QtyExported] [int] NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_QtyExported] DEFAULT ((0)),
[Wavekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_Wavekey] DEFAULT (''),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine08] DEFAULT (''),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_UserDefine10] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueCountry] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BTB_ShipmentDetail_IssueCountry] DEFAULT (''),
[IssueAuthority] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_BTB_ShipmentDetail_IssueAuthority] DEFAULT (''),
[BTBShipItem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentDetail_BTBShipItem] DEFAULT (''),
[ExternOrderkey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_SHIPMENTDETAIL_ExternOrderkey] DEFAULT (''),
[CustomLotNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_SHIPMENTDETAIL_CustomLotNo] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrBTB_ShipmentDetailAdd                                    */
/* Creation Date: 20-MAR-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2021-FEB-09 WAN01    1.1   WMS-15957-SG-CBF - BTB Form E Declaration */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrBTB_ShipmentDetailAdd]
ON  [dbo].[BTB_ShipmentDetail]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT
         , @n_err             INT
         , @c_errmsg          NVARCHAR(250)

   DECLARE @c_FormType        NVARCHAR(10)
         , @c_ShipmentKey     NVARCHAR(10)
         , @c_ShipmentListNo  NVARCHAR(10)
         , @c_ShipmentLineNo  NVARCHAR(5)
         , @c_FormNo          NVARCHAR(40)
         , @c_HSCode          NVARCHAR(20)
         , @c_Storerkey       NVARCHAR(15)     
         , @c_Sku             NVARCHAR(20)
         , @n_QtyExported     INT

         , @c_BTBShipItem     NVARCHAR(50) = ''       --(Wan01)
         , @c_CustomLotNo     NVARCHAR(20) = ''       --(Wan01)
         , @c_BTB_FTAKey      NVARCHAR(10) = ''       --(Wan01)
         
   SET @n_StartTCnt= @@TRANCOUNT
   SET @n_Continue = 1
   
   IF EXISTS(SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT_TR
   END 

   SET @c_ShipmentKey = ''
   SELECT TOP 1 @c_ShipmentKey    = INS.BTB_ShipmentKey
               ,@c_ShipmentListNo = RTRIM(INS.BTB_ShipmentListNo)
               ,@c_Sku            = RTRIM(INS.Sku)
   FROM BTB_FTA WITH (NOLOCK)
   JOIN (SELECT FormType   = ISNULL(RTRIM(BTB_SHIPMENT.FormType),'')
               ,BTB_ShipmentKey    = INSERTED.BTB_ShipmentKey
               ,BTB_ShipmentListNo = INSERTED.BTB_ShipmentListNo
               ,FormNo     = ISNULL(RTRIM(INSERTED.FormNo),'')
               ,HSCode     = ISNULL(RTRIM(INSERTED.HSCode),'')
               ,Storerkey  = ISNULL(RTRIM(INSERTED.Storerkey),'')
               ,Sku        = ISNULL(RTRIM(INSERTED.Sku),'')
               ,QtyExported = ISNULL(SUM(INSERTED.QtyExported),0)
               ,INSERTED.BTBShipItem                                 --(Wan01)
               ,INSERTED.CustomLotNo                                 --(Wan01)
         FROM  INSERTED
         JOIN  BTB_SHIPMENT WITH (NOLOCK) ON (INSERTED.BTB_ShipmentKey = BTB_SHIPMENT.BTB_ShipmentKey)
         WHERE INSERTED.FormNo <> ''
         GROUP BY BTB_SHIPMENT.FormType
               ,  INSERTED.BTB_ShipmentKey
               ,  INSERTED.BTB_ShipmentListNo
               ,  INSERTED.FormNo
               ,  INSERTED.HSCode
               ,  INSERTED.Storerkey
               ,  INSERTED.Sku
               ,  INSERTED.BTBShipItem                               --(Wan01)
               ,  INSERTED.CustomLotNo                               --(Wan01)           
         ) INS    ON (BTB_FTA.FormNo   = INS.FormNo)
                  AND(BTB_FTA.FormType = INS.FormType)
                  AND(BTB_FTA.HSCode   = INS.HSCode)
                  AND(BTB_FTA.Storerkey= INS.Storerkey)
                  AND(BTB_FTA.Sku      = INS.Sku) 
                  AND(BTB_FTA.BTBShipItem = INS.BTBShipItem)         --(Wan01)
                  AND(BTB_FTA.CustomLotNo = INS.CustomLotNo)         --(Wan01)        
   WHERE BTB_FTA.QtyImported - BTB_FTA.QtyExported - INS.QtyExported < 0
 
   IF @c_ShipmentKey <> ''
   BEGIN 
      SET @n_Continue = 3
      SET @n_err=80010
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Shipmentdetail Total Exported Qty > BTBFTA Balance Qty. '
                   +'ShipmentKey: ' + @c_ShipmentKey+ ', '
                   +'ShipmentListNo: ' + @c_ShipmentListNo + ', '
                   +'Sku: ' + @c_Sku + ' (ntrBTB_ShipmentDetailAdd)'
      GOTO QUIT_TR
   END

   DECLARE CUR_SHPDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT BTB_SHIPMENT.FormType
         ,ISNULL(RTRIM(INSERTED.FormNo),'')
         ,ISNULL(RTRIM(INSERTED.HSCode),'')
         ,ISNULL(RTRIM(INSERTED.Storerkey),'')
         ,ISNULL(RTRIM(INSERTED.Sku),'')
         ,ISNULL(INSERTED.QtyExported,0) 
         ,INSERTED.BTBShipItem                                    --(Wan01)
         ,INSERTED.CustomLotNo                                    --(Wan01)
   FROM INSERTED                                               
   JOIN BTB_SHIPMENT WITH (NOLOCK) ON (INSERTED.BTB_ShipmentKey = BTB_SHIPMENT.BTB_ShipmentKey)
   WHERE INSERTED.FormNo <> ''
   
   OPEN CUR_SHPDET
   
   FETCH NEXT FROM CUR_SHPDET INTO @c_FormType
                                 , @c_FormNo
                                 , @c_HSCode
                                 , @c_Storerkey
                                 , @c_Sku
                                 , @n_QtyExported
                                 , @c_BTBShipItem                 --(Wan01)
                                 , @c_CustomLotNo                 --(Wan01)
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      IF @n_QtyExported > 0 
      BEGIN
      	--(Wan02) - START
      	SET @c_BTB_FTAKey = ''
      	SELECT TOP 1 @c_BTB_FTAKey = BTB_FTAKey
      	FROM BTB_FTA WITH (NOLOCK) 
         WHERE BTB_FTA.FormNo   = @c_FormNo 
         AND   BTB_FTA.FormType = @c_FormType 
         AND   BTB_FTA.HSCode   = @c_HSCode 
         AND   BTB_FTA.Storerkey= @c_Storerkey 
         AND   BTB_FTA.Sku      = @c_Sku 
         AND   BTB_FTA.BTBShipItem = @c_BTBShipItem               --(Wan01)
         AND   BTB_FTA.CustomLotNo = @c_CustomLotNo               --(Wan01) 
      	
      	IF @c_BTB_FTAKey <> ''
      	BEGIN
            UPDATE BTB_FTA 
            SET QtyExported = QtyExported + @n_QtyExported
               ,EditWho = SUSER_NAME()
               ,EditDate= GETDATE()
            WHERE BTB_FTA.BTB_FTAKey   = @c_BTB_FTAKey            --(Wan01)

            SET @n_err = @@ERROR 
            IF @n_err <> 0
            BEGIN
               SET @n_Continue = 3
               SET @c_errmsg = CONVERT(CHAR(5),@n_err)
               SET @n_err=80020
               SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BTB_FTA. (ntrBTB_ShipmentDetailAdd)' 
                            + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               GOTO QUIT_TR
            END
      	END
      	--(Wan02) - END
      END
      FETCH NEXT FROM CUR_SHPDET INTO @c_FormType
                                    , @c_FormNo
                                    , @c_HSCode
                                    , @c_Storerkey
                                    , @c_Sku
                                    , @n_QtyExported
                                    , @c_BTBShipItem              --(Wan01)
                                    , @c_CustomLotNo              --(Wan01)                
   END
   CLOSE CUR_SHPDET
   DEALLOCATE CUR_SHPDET 

QUIT_TR:

   IF CURSOR_STATUS( 'LOCAL', 'CUR_SHPDET') in (0 , 1)  
   BEGIN
      CLOSE CUR_SHPDET
      DEALLOCATE CUR_SHPDET
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ntrBTB_ShipmentDetailAdd'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrBTB_ShipmentDetailDelete                                 */
/* Creation Date: 20-MAR-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2021-FEB-09 WAN01    1.1   WMS-15957-SG-CBF - BTB Form E Declaration */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrBTB_ShipmentDetailDelete]
ON  [dbo].[BTB_ShipmentDetail]
FOR DELETE
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

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT
         , @n_err             INT
         , @c_errmsg          NVARCHAR(250)

   DECLARE @c_FormType        NVARCHAR(10)
         , @c_FormNo          NVARCHAR(40)
         , @c_HSCode          NVARCHAR(20)
         , @c_Storerkey       NVARCHAR(15)     
         , @c_Sku             NVARCHAR(20)
         , @n_QtyExported     INT
         
         , @c_BTBShipItem     NVARCHAR(50) = ''       --(Wan01)
         , @c_CustomLotNo     NVARCHAR(20) = ''       --(Wan01)
         , @c_BTB_FTAKey      NVARCHAR(10) = ''       --(Wan01)

   SET @n_StartTCnt= @@TRANCOUNT
   SET @n_Continue = 1

   IF (SELECT COUNT(1) FROM DELETED) = (SELECT COUNT(1) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT_TR
   END

   DECLARE CUR_SHPDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT BTB_SHIPMENT.FormType
         ,ISNULL(RTRIM(DELETED.FormNo),'')
         ,ISNULL(RTRIM(DELETED.HSCode),'')
         ,ISNULL(RTRIM(DELETED.Storerkey),'')
         ,ISNULL(RTRIM(DELETED.Sku),'')
         ,ISNULL(DELETED.QtyExported,0) 
         ,DELETED.BTBShipItem                                     --(Wan01)
         ,DELETED.CustomLotNo                                     --(Wan01)       
   FROM DELETED WITH (NOLOCK)
   JOIN BTB_SHIPMENT WITH (NOLOCK) ON (DELETED.BTB_ShipmentKey = BTB_SHIPMENT.BTB_ShipmentKey)
   WHERE DELETED.FormNo <> ''
   
   OPEN CUR_SHPDET
   
   FETCH NEXT FROM CUR_SHPDET INTO @c_FormType
                                 , @c_FormNo
                                 , @c_HSCode
                                 , @c_Storerkey
                                 , @c_Sku
                                 , @n_QtyExported
                                 , @c_BTBShipItem                 --(Wan01)
                                 , @c_CustomLotNo                 --(Wan01)       
   WHILE @@FETCH_STATUS <> -1
   BEGIN
   	--(Wan01) - START
   	SET @c_BTB_FTAKey = ''
      SELECT TOP 1 @c_BTB_FTAKey = BTB_FTAKey
      FROM BTB_FTA WITH (NOLOCK) 
      WHERE BTB_FTA.FormNo   = @c_FormNo 
      AND   BTB_FTA.FormType = @c_FormType 
      AND   BTB_FTA.HSCode   = @c_HSCode 
      AND   BTB_FTA.Storerkey= @c_Storerkey 
      AND   BTB_FTA.Sku      = @c_Sku 
      AND   BTB_FTA.BTBShipItem = @c_BTBShipItem               --(Wan01)
      AND   BTB_FTA.CustomLotNo = @c_CustomLotNo               --(Wan01) 
         
      IF @c_BTB_FTAKey <> ''
      BEGIN   
         UPDATE BTB_FTA 
         SET QtyExported = QtyExported - @n_QtyExported
            ,EditWho = SUSER_NAME()
            ,EditDate= GETDATE()
         WHERE BTB_FTA.BTB_FTAKey   = @c_BTB_FTAKey            --(Wan01)

         SET @n_err = @@ERROR 
         IF @n_err <> 0
         BEGIN
            SET @n_Continue = 3
            SET @c_errmsg = CONVERT(CHAR(5),@n_err)
            SET @n_err=80010
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BTB_FTA. (ntrBTB_ShipmentDetailDelete)' 
                         + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
            GOTO QUIT_TR
         END
      END
      --(Wan01) - END
      FETCH NEXT FROM CUR_SHPDET INTO @c_FormType
                                    , @c_FormNo
                                    , @c_HSCode
                                    , @c_Storerkey
                                    , @c_Sku
                                    , @n_QtyExported
                                    , @c_BTBShipItem              --(Wan01)
                                    , @c_CustomLotNo              --(Wan01)                                      
   END
   CLOSE CUR_SHPDET
   DEALLOCATE CUR_SHPDET 
QUIT_TR:

   IF CURSOR_STATUS( 'LOCAL', 'CUR_SHPDET') in (0 , 1)  
   BEGIN
      CLOSE CUR_SHPDET
      DEALLOCATE CUR_SHPDET
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ntrBTB_ShipmentDetailDelete'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrBTB_ShipmentDetailUpdate                                 */
/* Creation Date: 20-MAR-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 08-NOV-2017 Wan01    1.1   WMS-3321 - Triple - Back to Back FTA Entry*/
/* 2021-FEB-09 WAN02    1.2   WMS-15957-SG-CBF - BTB Form E Declaration */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrBTB_ShipmentDetailUpdate]
ON  [dbo].[BTB_ShipmentDetail]
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

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT
         , @n_err             INT
         , @c_errmsg          NVARCHAR(250)

   DECLARE @c_FormType        NVARCHAR(10)
         , @c_ShipmentKey     NVARCHAR(10)
         , @c_ShipmentListNo  NVARCHAR(10)
         , @c_ShipmentLineNo  NVARCHAR(5)
         , @c_FormNo          NVARCHAR(40)
         , @c_HSCode          NVARCHAR(20)
         , @c_Storerkey       NVARCHAR(15)     
         , @c_Sku             NVARCHAR(20)
         , @n_QtyExported     INT
         , @c_BTBSHIPItem     NVARCHAR(50)                                                         --(Wan01)

         , @c_FormNo_DEL      NVARCHAR(40)
         , @c_HSCode_DEL      NVARCHAR(20)
         , @c_Sku_DEL         NVARCHAR(20)
         , @n_QtyExported_DEL INT         
         , @c_BTBSHIPItem_DEL NVARCHAR(50)                                                         --(Wan01)  

         , @c_CustomLotNo     NVARCHAR(20) = ''                                                    --(Wan02)
         , @c_CustomLotNo_DEL NVARCHAR(20) = ''                                                    --(Wan02)
         , @c_BTB_FTAKey      NVARCHAR(10) = ''                                                    --(Wan02)  

   SET @n_StartTCnt= @@TRANCOUNT
   SET @n_Continue = 1

   IF UPDATE(ArchiveCop)
   BEGIN
      SET @n_continue = 4 
      GOTO QUIT_TR
   END

   IF NOT UPDATE(EditDate) 
   BEGIN
      UPDATE BTB_SHIPMENTDETAIL WITH (ROWLOCK)
      SET EditWho = SUSER_SNAME()
         ,EditDate= GETDATE()
         ,TrafficCop = NULL
      FROM BTB_SHIPMENTDETAIL
      JOIN INSERTED ON (BTB_SHIPMENTDETAIL.BTB_ShipmentKey = INSERTED.BTB_ShipmentKey)
                    AND(BTB_SHIPMENTDETAIL.BTB_ShipmentListNo = INSERTED.BTB_ShipmentListNo)
                    AND(BTB_SHIPMENTDETAIL.BTB_ShipmentLineNo = INSERTED.BTB_ShipmentLineNo)

      SET @n_err = @@ERROR 
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @c_errmsg = CONVERT(CHAR(250),@n_err)
         SET @n_err=80010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BTB_SHIPMENTDETAIL. (ntrBTB_ShipmentDetailUpdate)' 
                      + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         GOTO QUIT_TR
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SET @n_continue = 4 
      GOTO QUIT_TR
   END
 
   SET @c_ShipmentKey = ''  
   SELECT TOP 1 @c_ShipmentKey    = UPD.BTB_ShipmentKey
               ,@c_ShipmentListNo = RTRIM(UPD.BTB_ShipmentListNo)
               ,@c_Sku            = RTRIM(UPD.Sku)
               ,@c_BTBSHIPItem    = RTRIM(UPD.BTBSHIPItem)                                         --(Wan01)
   FROM BTB_FTA WITH (NOLOCK)
   JOIN (SELECT FormType = ISNULL(RTRIM(BTB_SHIPMENT.FormType),'')
               ,BTB_ShipmentKey    = INSERTED.BTB_ShipmentKey
               ,BTB_ShipmentListNo = INSERTED.BTB_ShipmentListNo
               ,FormNo   = ISNULL(RTRIM(INSERTED.FormNo),'')
               ,HSCode   = ISNULL(RTRIM(INSERTED.HSCode),'')
               ,Storerkey= ISNULL(RTRIM(INSERTED.Storerkey),'')
               ,Sku      = ISNULL(RTRIM(INSERTED.Sku),'')
               ,QtyExported = ISNULL(SUM(INSERTED.QtyExported),0) -- - CASE WHEN DELETED.FormNo = '' THEN 0 ELSE DELETED.QtyExported END),0)
               ,BTBSHIPItem = INSERTED.BTBSHIPItem                                                 --(Wan01)
               ,CustomLotNo = INSERTED.CustomLotNo                                                 --(Wan02)                 
         FROM INSERTED 
         JOIN DELETED  ON (INSERTED.BTB_ShipmentKey = DELETED.BTB_ShipmentKey)
                        AND(INSERTED.BTB_ShipmentListNo = DELETED.BTB_ShipmentListNo)
                        AND(INSERTED.BTB_ShipmentLineNo = DELETED.BTB_ShipmentLineNo)
         JOIN BTB_SHIPMENT WITH (NOLOCK) ON (INSERTED.BTB_ShipmentKey = BTB_SHIPMENT.BTB_ShipmentKey)
         WHERE INSERTED.FormNo <> DELETED.FormNo 
         GROUP BY BTB_SHIPMENT.FormType
               ,  INSERTED.BTB_ShipmentKey
               ,  INSERTED.BTB_ShipmentListNo
               ,  INSERTED.FormNo
               ,  INSERTED.HSCode
               ,  INSERTED.Storerkey
               ,  INSERTED.Sku
               ,  INSERTED.BTBSHIPItem                                                             --(Wan01)
               ,  INSERTED.CustomLotNo                                                             --(Wan02)               
         ) UPD ON (BTB_FTA.FormNo   = UPD.FormNo)
               AND(BTB_FTA.FormType = UPD.FormType)
               AND(BTB_FTA.HSCode   = UPD.HSCode)
               AND(BTB_FTA.Storerkey= UPD.Storerkey)
               AND(BTB_FTA.Sku      = UPD.Sku)
               AND(BTB_FTA.BTBSHIPItem= UPD.BTBSHIPItem)                                           --(Wan01)
               AND(BTB_FTA.CustomLotNo= UPD.CustomLotNo)                                           --(Wan02)
   WHERE BTB_FTA.QtyImported - BTB_FTA.QtyExported - UPD.QtyExported < 0

   IF @c_ShipmentKey <> ''  
   BEGIN 
      SET @n_Continue = 3
      SET @n_err=80020
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Shipmentdetail Total Exported Qty > BTBFTA Balance Qty. '
                   +'ShipmentKey: ' + @c_ShipmentKey+ ', '
                   +'ShipmentListNo: ' + @c_ShipmentListNo + ', '
                   +'Sku: ' + @c_Sku + ' (ntrBTB_ShipmentDetailUpdate)'
      GOTO QUIT_TR
   END

   DECLARE CUR_SHPDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT BTB_SHIPMENT.FormType
         ,ISNULL(RTRIM(INSERTED.FormNo),'')
         ,ISNULL(RTRIM(INSERTED.HSCode),'')
         ,ISNULL(RTRIM(INSERTED.Storerkey),'')
         ,ISNULL(RTRIM(INSERTED.Sku),'')
         ,ISNULL(INSERTED.QtyExported,0) 
         ,ISNULL(RTRIM(DELETED.FormNo),'')
         ,ISNULL(RTRIM(DELETED.HSCode),'')
         ,ISNULL(RTRIM(DELETED.Sku),'')
         ,ISNULL(DELETED.QtyExported,0) 
         ,INSERTED.BTBSHIPItem                                                                     --(Wan01)
         ,DELETED.BTBSHIPItem                                                                      --(Wan01)
         ,INSERTED.CustomLotNo                                                                     --(Wan02)
         ,DELETED.CustomLotNo                                                                      --(Wan02)         
   FROM INSERTED  
   JOIN DELETED  ON (INSERTED.BTB_ShipmentKey = DELETED.BTB_ShipmentKey)
                 AND(INSERTED.BTB_ShipmentListNo = DELETED.BTB_ShipmentListNo)
                 AND(INSERTED.BTB_ShipmentLineNo = DELETED.BTB_ShipmentLineNo)
   JOIN BTB_SHIPMENT WITH (NOLOCK) ON (BTB_SHIPMENT.BTB_ShipmentKey = INSERTED.BTB_ShipmentKey)
   OPEN CUR_SHPDET
   
   FETCH NEXT FROM CUR_SHPDET INTO @c_FormType
                                 , @c_FormNo
                                 , @c_HSCode
                                 , @c_Storerkey
                                 , @c_Sku
                                 , @n_QtyExported
                                 , @c_FormNo_DEL
                                 , @c_HSCode_DEL
                                 , @c_Sku_DEL
                                 , @n_QtyExported_DEL
                                 , @c_BTBSHIPItem                                                  --(Wan01)
                                 , @c_BTBSHIPItem_DEL                                              --(Wan01)
                                 , @c_CustomLotNo                                                  --(Wan02)
                                 , @c_CustomLotNo_DEL                                              --(Wan02)

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      -- After populated, Shipmentdetail is save w/o form #
      --IF @n_QtyExported <> @n_QtyExported_DEL AND @n_QtyExported_DEL > 0                         --(Wan01)  
      IF @c_FormNo_DEL <> '' AND  @n_QtyExported_DEL > 0                                           --(Wan01)                     
      BEGIN
      	--(Wan02) - START
      	SET @c_BTB_FTAKey = ''
      	SELECT TOP 1 @c_BTB_FTAKey = BTB_FTAKey
      	FROM BTB_FTA WITH (NOLOCK) 
         WHERE BTB_FTA.FormNo   = @c_FormNo_DEL 
         AND   BTB_FTA.FormType = @c_FormType 
         AND   BTB_FTA.HSCode   = @c_HSCode_DEL 
         AND   BTB_FTA.Storerkey= @c_Storerkey
         AND   BTB_FTA.Sku      = @c_Sku_DEL 
         AND   BTB_FTA.BTBSHIPItem = @c_BTBSHIPItem_DEL                                             --(Wan02)
         AND   BTB_FTA.CustomLotNo = @c_CustomLotNo_DEL                                             --(Wan02) 
         
         IF @c_BTB_FTAKey <> ''
         BEGIN
            UPDATE BTB_FTA WITH (ROWLOCK)
            SET QtyExported = QtyExported - @n_QtyExported_DEL
               ,EditWho = SUSER_NAME()
               ,EditDate= GETDATE()
            WHERE BTB_FTA.BTB_FTAKey = @c_BTB_FTAKey 

            SET @n_err = @@ERROR 
            IF @n_err <> 0
            BEGIN
               SET @n_Continue = 3
               SET @c_errmsg = CONVERT(CHAR(5),@n_err)
               SET @n_err=80030
               SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BTB_FTA. (ntrBTB_ShipmentDetailUpdate)' 
                              + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               GOTO QUIT_TR
            END
         END
      END

      --IF @n_QtyExported <> @n_QtyExported_DEL AND @n_QtyExported > 0                             --(Wan01)                           
      IF @c_FormNo <> '' AND @n_QtyExported > 0                                                    --(Wan01)   
      BEGIN
      	
      	--(Wan02) - START
      	SET @c_BTB_FTAKey = ''
      	SELECT TOP 1 @c_BTB_FTAKey = BTB_FTAKey
      	FROM BTB_FTA WITH (NOLOCK) 
         WHERE BTB_FTA.FormNo   = @c_FormNo 
         AND   BTB_FTA.FormType = @c_FormType 
         AND   BTB_FTA.HSCode   = @c_HSCode 
         AND   BTB_FTA.Storerkey= @c_Storerkey 
         AND   BTB_FTA.Sku      = @c_Sku 
         AND   BTB_FTA.BTBShipItem = @c_BTBShipItem                                                --(Wan02)
         AND   BTB_FTA.CustomLotNo = @c_CustomLotNo                                                --(Wan02) 
         
         IF @c_BTB_FTAKey <> ''
         BEGIN
            UPDATE BTB_FTA 
            SET QtyExported = QtyExported + @n_QtyExported  
               ,EditWho = SUSER_NAME()
               ,EditDate= GETDATE()
            WHERE BTB_FTA.BTB_FTAKey = @c_BTB_FTAKey 

            SET @n_err = @@ERROR 
            IF @n_err <> 0
            BEGIN
               SET @n_Continue = 3
               SET @c_errmsg = CONVERT(CHAR(5),@n_err)
               SET @n_err=80040
               SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BTB_FTA. (ntrBTB_ShipmentDetailUpdate)' 
                              + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               GOTO QUIT_TR
            END
         END
         --(Wan02) - END
      END

      FETCH NEXT FROM CUR_SHPDET INTO @c_FormType
                                    , @c_FormNo
                                    , @c_HSCode
                                    , @c_Storerkey
                                    , @c_Sku
                                    , @n_QtyExported
                                    , @c_FormNo_DEL
                                    , @c_HSCode_DEL
                                    , @c_Sku_DEL
                                    , @n_QtyExported_DEL
                                    , @c_BTBSHIPItem                                               --(Wan01)
                                    , @c_BTBSHIPItem_DEL                                           --(Wan01)
                                    , @c_CustomLotNo                                               --(Wan02)
                                    , @c_CustomLotNo_DEL                                           --(Wan02)

   END
   CLOSE CUR_SHPDET
   DEALLOCATE CUR_SHPDET 

QUIT_TR:

   IF CURSOR_STATUS( 'LOCAL', 'CUR_SHPDET') in (0 , 1)  
   BEGIN
      CLOSE CUR_SHPDET
      DEALLOCATE CUR_SHPDET
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ntrBTB_ShipmentDetailUpdate'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
ALTER TABLE [dbo].[BTB_ShipmentDetail] ADD CONSTRAINT [PK__BTB_Ship__D106209936B2EC37] PRIMARY KEY CLUSTERED ([BTB_ShipmentKey], [BTB_ShipmentListNo], [BTB_ShipmentLineNo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BTB_ShipmentDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BTB_ShipmentDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BTB_ShipmentDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BTB_ShipmentDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back FTA', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment Running #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'BTB_ShipmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment Line #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'BTB_ShipmentLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment List Running #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'BTB_ShipmentListNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BTB Shipment Item', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'BTBShipItem'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Currency', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Currency'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Custom Lot #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'CustomLotNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Extern Order Number', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'ExternOrderkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Form No', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'FormNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'HSCode', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'HSCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Issuing Authority', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'IssueAuthority'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Issuing Country', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'IssueCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Issued Date', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'IssuedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permit No', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'PermitNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Price', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Exported Qty', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'QtyExported'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku Description', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'SkuDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'UOM', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 06', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 07', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 08', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 09', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 10', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Wave #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentDetail', 'COLUMN', N'Wavekey'
GO
