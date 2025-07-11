
/****** Object:  StoredProcedure [dbo].[ispPRPPLPO_GBR_JCB]    Script Date: 7/10/2025 1:03:45 PM ******/
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/
/* Store procedure: ispPRPPLPO_GBR_JCB                                           */
/* Copyright      : Maersk                                                       */
/* Customer       : JCB                                                          */
/*                                                                               */
/*                                                                               */
/* Date         Rev   Author   Purposes                                          */
/* 09/07/2025   1.0   PPA374   Updatiing TMS_Shipment for an ASN as per PO       */
/*********************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[ispPRPPLPO_GBR_JCB]
   @c_ReceiptKey NVARCHAR(10)
   , @c_POKeys NVARCHAR(MAX)
   , @c_POLineNumbers NVARCHAR(MAX)
   , @b_Success INT OUTPUT
   , @n_Err INT OUTPUT
   , @c_ErrMsg NVARCHAR(255) OUTPUT

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cVehicleLPN       NVARCHAR(30),
      @cDriveName        NVARCHAR(30),
      @cRoute            NVARCHAR(30),
      @cAppointmentID    NVARCHAR(30),
      @cEquipment        NVARCHAR(30),
      @cExternReceiptKey NVARCHAR(30),
      @cPoKey            NVARCHAR(30),
      @cUDF05            NVARCHAR(30),
      @cUDF08            NVARCHAR(30),
      @cUDF09            NVARCHAR(30)

   SET @cEquipment = ''
   SET @n_Err = 0

   CREATE TABLE #tPOs
   (
      RowRef      INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
      PORefKey    NVARCHAR(10)   NOT NULL DEFAULT('')
   )

   INSERT INTO #tPOs (PORefKey)
   SELECT DISTINCT T.[Value] FROM string_split (@c_POKeys, ',')T

   SELECT TOP 1 @cPoKey = PORefKey FROM #tPOs

   IF (
      SELECT COUNT(DISTINCT UserDefine05)
      FROM (
         SELECT PO.UserDefine05
         FROM dbo.PO WITH(NOLOCK)
         INNER JOIN #tPOs TP ON PO.POKey = TP.PORefKey

         UNION ALL

         SELECT R.UserDefine05
         FROM dbo.RECEIPT R WITH(NOLOCK)
         WHERE R.ReceiptKey = @c_ReceiptKey
         AND ISNULL(R.UserDefine05,'') <> ''
      ) AS CombinedPOASN
   ) > 1
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 562002
      SET @c_ErrMsg = ERROR_MESSAGE()
      SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Cannot create an ASN from multiple trucks. (lsp_ASN_PopulatePOs_Wrapper)'
                     + '(' + @c_ErrMsg + ')'
   END

   IF EXISTS (
      SELECT 1 FROM RECEIPTDETAIL RD WITH(NOLOCK)
      INNER JOIN #tPOs T ON RD.POKey = T.PORefKey
      WHERE RD.ReceiptKey <> @c_Receiptkey
   )
   BEGIN
      DECLARE @cExistingASN AS NVARCHAR(20)

      SELECT TOP 1 @cExistingASN = ReceiptKey, @cPoKey = POKey 
      FROM RECEIPTDETAIL RD WITH(NOLOCK)
      INNER JOIN #tPOs T ON RD.POKey = T.PORefKey
      WHERE RD.ReceiptKey <> @c_Receiptkey

      SET @b_Success = 0
      SET @n_Err = 562002
      SET @c_ErrMsg = ERROR_MESSAGE()
      SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': PO '+@cPoKey+' already in another ASN '+@cExistingASN+'. (lsp_ASN_PopulatePOs_Wrapper)'
                     + '(' + @c_ErrMsg + ')'
   END

   IF @n_err = 0
   BEGIN
      SELECT TOP 1 
         @cUDF05 = UserDefine05, 
         @cUDF08 = UserDefine08, 
         @cUDF09 = UserDefine09 
      FROM dbo.PO WITH(NOLOCK)
      WHERE POKey = @cPoKey

      UPDATE RECEIPT WITH(ROWLOCK)
      SET 
         ContainerKey = @cUDF08, 
         VehicleNumber = @cUDF09, 
         UserDefine05 = @cUDF05
      WHERE ReceiptKey = @c_Receiptkey
   END
   ELSE
   BEGIN
      GOTO QUIT
   END

   SELECT TOP 1 
      @cVehicleLPN = ContainerKey, --UserDefine08
      @cRoute = VehicleNumber,     --UserDefine09
      @cAppointmentID = @cUDF05,   --UserDefine05
      @cExternReceiptKey = ExternReceiptKey 
   FROM dbo.RECEIPT WITH(NOLOCK)
   WHERE ReceiptKey = @c_Receiptkey

   IF EXISTS (
      SELECT 1 
      FROM dbo.SKU S WITH(NOLOCK)  
      INNER JOIN dbo.PODETAIL PD WITH(NOLOCK) ON S.Sku = PD.Sku
      INNER JOIN #tPOs TP ON PD.POKey = TP.PORefKey
      WHERE S.Size = 'HEAVY'
   )
   BEGIN
      SET @cEquipment = 'HEAVY'
   END

   UPDATE dbo.TMS_Shipment WITH(ROWLOCK)
   SET 
      VehicleLPN = @cVehicleLPN, 
      DriveName = DriveName, 
      Route = @cRoute, 
      AppointmentID = @cAppointmentID, 
      EquipmentID = @cEquipment, 
      ShipmentGID = @c_Receiptkey
   WHERE (ShipmentGID = @c_Receiptkey OR ShipmentGID = @cExternReceiptKey)

   UPDATE dbo.TMS_ShipmentTransOrderLink WITH(ROWLOCK)
   SET ShipmentGID = @c_Receiptkey
   WHERE (ShipmentGID = @c_Receiptkey OR ShipmentGID = @cExternReceiptKey)

QUIT:
END

