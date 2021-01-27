IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_RFID_GetASNKey01]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_RFID_GetASNKey01]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_RFID_GetASNKey01                                    */
/* Creation Date: 2020-08-28                                            */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:  WMS-14739 - CN NIKE O2 WMS RFID Receiving Module           */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 09-OCT-2020 Wan      1.0   Created                                   */
/* 26-Jan-2021 Wan      1.1   WMS-16143 - NIKE_O2_RFID_Receiving_CR V1.0*/
/************************************************************************/
CREATE PROC isp_RFID_GetASNKey01
           @c_Facility           NVARCHAR(5)  
         , @c_Storerkey          NVARCHAR(15)
         , @c_RefNo              NVARCHAR(50)
         , @c_ReceiptKey         NVARCHAR(10) = '' OUTPUT
         , @b_Success            INT          = 1  OUTPUT
         , @n_Err                INT          = 0  OUTPUT
         , @c_ErrMsg             NVARCHAR(255)= '' OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT = @@TRANCOUNT
         , @n_Continue        INT = 1

         , @b_QRCode          INT = 0
         , @c_TrackingNo      NVARCHAR(40) = ''
         , @c_WarehouseRef    NVARCHAR(18) = ''
         , @c_SellerPhone1    NVARCHAR(18) = ''

         , @c_ASNReason       NVARCHAR(10) = ''
         , @dt_Orderdate      DATETIME     = NULL
         , @dt_today          DATETIME     = GETDATE()   
         , @n_ValidDay        INT          = 0

   DECLARE @tMATCHASN         TABLE
         ( RowRef             INT            IDENTITY(1,1) PRIMARY KEY
         , ReceiptKey         NVARCHAR(10)   DEFAULT('')
         , TrackingNo         NVARCHAR(40)   DEFAULT('')
         , WarehouseRef       NVARCHAR(18)   DEFAULT('')
         , SellerPhone1       NVARCHAR(18)   DEFAULT('')
         , Orderdate          DATETIME                         --(Wan01)
         )
         
   DECLARE @tTrackingNo      TABLE     --2021-01-07  
         ( RowRef             INT            IDENTITY(1,1) PRIMARY KEY  
         , ReceiptKey         NVARCHAR(10)   DEFAULT('')  
         , TrackingNo         NVARCHAR(40)   DEFAULT('')  
         )  
                        
  
   SET @n_err      = 0
   SET @c_errmsg   = ''
   
   SET @c_ReceiptKey = ''
   
   -- FBR v2.2 2020-12-12
   SELECT @c_ReceiptKey   = RH.ReceiptKey
        , @c_WarehouseRef = RH.WarehouseReference 
        , @c_SellerPhone1 = ISNULL(RH.SellerPhone1,'')
        , @dt_Orderdate   = RH.Userdefine07               --(Wan01)
   FROM RECEIPT RH WITH (NOLOCK)
   WHERE RH.Receiptkey = @c_RefNo
   AND RH.Storerkey = @c_Storerkey
   AND RH.Facility  = @c_Facility
   AND RH.DocType   = 'R'
   AND RH.[Status]  < '9'
   AND RH.[ASNStatus]  < '9'
   
   IF @c_ReceiptKey = ''     -- Search WarehouseRef By QRCode, Get SellerPhone1 by matching WarehouseRef
   BEGIN
   	SET @c_WarehouseRef = ''
   	SET @c_SellerPhone1 = ''

      SELECT TOP 1 @c_WarehouseRef = EOH.ExternOrderkey  --V2.4 2020-12-14
      FROM EXTERNORDERS EOH WITH (NOLOCK) 
      JOIN EXTERNORDERSDETAIL EOD WITH (NOLOCK) ON EOH.ExternOrderkey = EOD.ExternOrderkey
      WHERE EOD.QRCOde = @c_RefNo
      AND   EOD.Storerkey = @c_Storerkey
      AND   EOD.[Status]  = '9'
      ORDER BY EOD.EditDate DESC

      IF @c_WarehouseRef <> ''   --Get Receiptkey, SellerPhone1 by matching WarehouseRef
      BEGIN 
         INSERT INTO @tMATCHASN ( ReceiptKey, SellerPhone1, OrderDate ) --(Wan01)
         SELECT ReceiptKey   = RH.ReceiptKey
              , SellerPhone1 = ISNULL(RH.SellerPhone1,'')
              , Orderdate    = RH.Userdefine07                          --(Wan01)
         FROM RECEIPT RH WITH (NOLOCK)
         WHERE RH.WarehouseReference = @c_WarehouseRef
         AND RH.Storerkey = @c_Storerkey
         AND RH.Facility  = @c_Facility
         AND RH.DocType   = 'R'
         AND RH.[Status]  < '9'
         AND RH.[ASNStatus]  < '9'

         IF EXISTS (SELECT 1 FROM @tMATCHASN WHERE RowRef > 1)
         BEGIN
            SET @n_Continue = 3
            SET @n_Err      = 82010
            SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Duplicate ASN # for QRCode: ' + @c_RefNo
                            + ' (isp_RFID_GetASNKey01)'
            GOTO QUIT_SP
         END
      
         SELECT TOP 1 @c_ReceiptKey   = T.ReceiptKey
              , @c_SellerPhone1 = ISNULL(T.SellerPhone1,'')
              , @dt_Orderdate   = T.OrderDate                  --(Wan01)
         FROM @tMATCHASN T
         ORDER BY RowRef

         IF @c_ReceiptKey <> ''
         BEGIN
            SET @b_QRCode = 1 
         END 
      END
   END
  
   IF @c_ReceiptKey = ''   -- Get WarehouseRef, Receiptkey, SellerPhone1 By TrackingNo
   BEGIN
      SET @c_WarehouseRef = ''
      SET @c_SellerPhone1 = ''

      INSERT INTO @tMATCHASN ( ReceiptKey, WarehouseRef, SellerPhone1, OrderDate )  --(Wan01)
      SELECT ReceiptKey = RH.ReceiptKey
            ,WarehauseRef = ISNULL(RH.WarehouseReference,'')
            ,SellerPhone1 = ISNULL(RH.SellerPhone1,'')
            ,OrderDate    = RH.Userdefine07                                         --(Wan01)
      FROM  RECEIPT RH WITH (NOLOCK)
      JOIN  DOCINFO DI WITH (NOLOCK) ON  DI.TableName = 'RECEIPT'
                                     AND RH.ReceiptKey = DI.Key1
      WHERE RH.Storerkey = @c_Storerkey
      AND   RH.Facility  = @c_Facility
      AND   RH.DocType   = 'R'
      AND   RH.[Status]  < '9' 
      AND   RH.[ASNStatus]  < '9'  
      AND   DI.[Key2]    = 'TrackingNo'
      AND   DI.[Key3]    = @c_RefNo

      IF EXISTS (SELECT 1 FROM @tMATCHASN WHERE RowRef > 1)
      BEGIN
         SET @n_Continue = 3
         SET @n_Err      = 82020
         SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Duplicate ASN # for TrackingNo: ' + @c_RefNo
                           + ' (isp_RFID_GetASNKey01)'
         GOTO QUIT_SP
      END

      SELECT TOP 1 @c_ReceiptKey   = T.ReceiptKey
            , @c_WarehouseRef = ISNULL(T.WarehouseRef,'')
            , @c_SellerPhone1 = ISNULL(T.SellerPhone1,'')
            , @dt_Orderdate   = T.OrderDate                    --(Wan01)
      FROM @tMATCHASN T
      ORDER BY RowRef

      IF @c_ReceiptKey <> ''
      BEGIN
         SET @c_TrackingNo = @c_RefNo
         
         INSERT INTO @tTrackingNo (Receiptkey, TrackingNo)  --2021-01-07
   	   VALUES (@c_ReceiptKey, @c_TrackingNo)
      END 
   END 

   IF @c_ReceiptKey = '' -- Get Receiptkey, SellerPhone1 By WarehouseRef 
   BEGIN
      INSERT INTO @tMATCHASN ( ReceiptKey, SellerPhone1, OrderDate )    --(Wan01)
      SELECT ReceiptKey = RH.ReceiptKey
            ,SellerPhone1= ISNULL(RH.SellerPhone1,'')
            ,Orderdate   = RH.Userdefine07                              --(Wan01)
      FROM RECEIPT RH WITH (NOLOCK)
      WHERE RH.WarehouseReference = @c_RefNo
      AND RH.Storerkey = @c_Storerkey
      AND RH.Facility  = @c_Facility
      AND RH.DocType   = 'R'
      AND RH.[Status]  < '9'
      AND RH.[ASNStatus]  < '9'  

      IF EXISTS (SELECT 1 FROM @tMATCHASN WHERE RowRef > 1)
      BEGIN
         SET @n_Continue = 3
         SET @n_Err      = 82040
         SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Duplicate ASN # for Warehouse Reference: ' + @c_RefNo
                         + ' (isp_RFID_GetASNKey01)'
         GOTO QUIT_SP
      END

      SELECT TOP 1 @c_ReceiptKey = T.ReceiptKey
            , @c_WarehouseRef = ISNULL(T.WarehouseRef,'')
            , @c_SellerPhone1 = ISNULL(T.SellerPhone1,'')
            , @dt_Orderdate   = T.OrderDate                 --(Wan01)
      FROM @tMATCHASN T
      ORDER BY RowRef

      IF @c_ReceiptKey <> ''
      BEGIN
         SET @b_QRCode = 0
         SET @c_WarehouseRef = @c_RefNo
      END
   END

   --IF ReceiptKey is found and WarehouseRef/SellerPhone/TrackingNo in CHECKLIST Table, prompt error and update ASNReason
   IF @c_ReceiptKey <> ''            --2021-01-07
   BEGIN
   	--(Wan01) - START
   	SET @dt_Orderdate = CONVERT(DATETIME, CONVERT(NVARCHAR(10), @dt_Orderdate, 121))
   	IF @dt_Orderdate IS NOT NULL AND CONVERT(NVARCHAR(10), @dt_Orderdate, 121) <> '1900-01-01'
   	BEGIN 
   		SET @n_ValidDay = 0
   		SELECT TOP 1  @n_ValidDay = CASE WHEN ISNUMERIC(c.UDF02) = 1 THEN c.UDF02 ELSE 0 END
   		FROM CODELKUP AS c WITH (NOLOCK)
   	   WHERE c.ListName = 'RDATA'
   	   AND   c.Code = '001'
   	   AND c.Storerkey = @c_Storerkey
   	   
   	   SET @dt_today = CONVERT(DATETIME, CONVERT(NVARCHAR(10), @dt_today, 121))
   	   IF  @n_ValidDay > 0 AND DATEDIFF(DAY, @dt_Orderdate, @dt_today) > @n_ValidDay  
   	   BEGIN
            SET @n_Continue = 3
            SET @n_Err      = 82025
            SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Order is Over ' + CAST(@n_ValidDay AS NVARCHAR) +' days .'
                            + ' (isp_RFID_GetASNKey01)'
            GOTO QUIT_SP
   	   END
   	END
   	--(Wan01) - END
   	
      IF @c_TrackingNo = ''  
      BEGIN
   	   INSERT INTO @tTrackingNo (Receiptkey, TrackingNo)
   	   SELECT  DI.Key1
   	         , DI.Key3
         FROM  DOCINFO DI WITH (NOLOCK) 
         WHERE DI.TableName = 'RECEIPT' 
         AND   DI.[Key1]    = @c_ReceiptKey      
         AND   DI.[Key2]    = 'TrackingNo' 
         AND   DI.[Key3]    <> '' 
      END
   
      --2020-01-07
      IF EXISTS ( SELECT 1
                  FROM @tTrackingNo TN
                  JOIN DOCINFO DI WITH (NOLOCK) ON  DI.TableName = 'CheckList'
                                                AND TN.TrackingNo = DI.Key1
                  WHERE DI.Storerkey = @c_Storerkey
               )
      BEGIN
         SET @c_ASNReason= 'CHECKLIST'
         SET @n_Continue = 3
         SET @n_Err      = 82030
         SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Tracking # Found in Customer CheckList.'
                           + ' (isp_RFID_GetASNKey01)'
      END  

      IF @c_WarehouseRef <> '' AND @c_ASNReason = ''
      BEGIN
         IF EXISTS ( SELECT 1
                     FROM DOCINFO DI WITH (NOLOCK)
                     WHERE DI.TableName = 'CheckList'
                     AND   DI.Storerkey = @c_Storerkey
                     AND   DI.Key2      = @c_WarehouseRef
                )
         BEGIN
            SET @c_ASNReason= 'CHECKLIST'
            SET @n_Continue = 3
            SET @n_Err      = 82050
            SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Sales Order Found in Customer CheckList.'
                            + ' (isp_RFID_GetASNKey01)'
         END 

         IF @c_ASNReason = ''
         BEGIN
            IF @c_SellerPhone1 <> ''
            BEGIN
               IF EXISTS ( SELECT 1
                           FROM DOCINFO DI WITH (NOLOCK)
                           WHERE DI.TableName = 'CheckList'
                           AND   DI.Storerkey = @c_Storerkey
                           AND   DI.Key3      = @c_SellerPhone1
                         )
               BEGIN
                  SET @c_ASNReason= 'CHECKLIST'
                  SET @n_Continue = 3
                  SET @n_Err      = 82060
                  SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Mobile # Found in Customer CheckList.'
                                  + ' (isp_RFID_GetASNKey01)'
               END
            END
         END
      END 

      IF @c_ASNReason <> ''
      BEGIN
         WHILE @@TRANCOUNT > 0
         BEGIN
            COMMIT TRAN
         END

         UPDATE RECEIPT 
            SET ASNReason = @c_ASNReason
               ,EditWho   = SUSER_SNAME()
               ,EditDate  = GETDATE()
               ,TrafficCop= NULL
         WHERE ReceiptKey = @c_ReceiptKey

         SET @n_Err = @@ERROR
         IF @n_Err <> 0
         BEGIN
            SET @n_Continue = 3
            SET @c_ErrMsg   = CONVERT(CHAR(250),@n_err)  
            SET @n_Err      = 82070
            SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Update RECEIPT Table fail.'
                            + ' (isp_RFID_GetASNKey01) (' + @c_ErrMsg + ')'
            GOTO QUIT_SP
         END 
      END   
   END
   ELSE IF @c_ReceiptKey = ''  
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 82080
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': ReceiptKey Not Found/ASN Received/ ASN Closed.'
                        + ' (isp_RFID_GetASNKey01)'
      GOTO QUIT_SP
   END
   
QUIT_SP:
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_RFID_GetASNKey01'
      --RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RFID_GetASNKey01] TO nSQL 
GO
