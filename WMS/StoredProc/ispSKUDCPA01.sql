/************************************************************************/
/* Stored Procedure: ispSKUDCPA01                                       */
/* Creation Date: 02/07/2025                                            */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-6199 Sephora - SCE Ecom Packing SKU Decode CR           */
/*                                                                      */
/*                                                                      */
/* Called By: isp_ECOMP_SKUDecode_PostAction_Wrapper                    */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 02-Jul-2025  Sean    1.0   FCR-6199 - Initial                        */
/* 15-Jul-2025  Sean01  1.1   FCR-6199 - Bug fix                        */
/* 15-Jul-2025  Sean02  1.2   FCR-6199 - Update the LabelLine format    */
/* 15-Jul-2025  Sean03  1.3   FCR-6199 - Update eror message            */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ispSKUDCPA01]
   @b_Debug          INT            = 0
,  @c_PickSlipNo     NVARCHAR(10)
,  @n_CartonNo       INT
,  @c_OrderKey       NVARCHAR(10)
,  @c_Storerkey      NVARCHAR(15) 
,  @c_Sku            NVARCHAR(500)
,  @b_Success        INT            OUTPUT  
,  @n_Err            INT            OUTPUT  
,  @c_ErrMsg         NVARCHAR(255)  OUTPUT   
AS
BEGIN
    SET NOCOUNT ON;
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE 
        @c_UPC       NVARCHAR(30),
        @c_PackDtlSKU NVARCHAR(30),
        @c_PackDtlUPC NVARCHAR(30),
        @c_BUSR5     NVARCHAR(30),
        @c_SerialNo  NVARCHAR(30),
        @n_LabelLineNo  INT = 0,
        @n_SerialQTY INT,
        @n_Position  INT,
        @n_Continue  INT = 1,
        @n_StartTcnt INT = @@TRANCOUNT; 

    SELECT @b_success = 1, @n_err = 0, @c_errmsg = ''

    SET @c_Sku = ISNULL(RTRIM(@c_Sku), '')

    
    /*
    -- 2D barcode
    6925350518422|A2915022|20260314|GZ|00398776
       6925350518422 = UPC
       A2915022 = BatchNo
       20260314 = ExpiryDate
    */

    SET @n_Position = CHARINDEX( '|', @c_Sku)
    IF @n_Position > 0
       SET @c_UPC = LEFT( @c_Sku, @n_Position - 1)
    ELSE
      -- 1D barcode
       SET @c_UPC = LEFT( @c_Sku, 30)

    -- Get UPC, for saving into PackDetail.UPC
    SELECT 
       @c_PackDtlSKU = SKU, 
       @c_PackDtlUPC = UPC
    FROM dbo.UPC WITH (NOLOCK)
    WHERE StorerKey = @c_StorerKey
       AND UPC = @c_UPC

    -- QRCode
	IF CHARINDEX( '|', @c_Sku) > 0
	BEGIN
	  SET @c_SerialNo = rdt.rdtGetParsedString( @c_Sku, 6, '|')
	  IF @c_SerialNo = ''
	     SET @c_SerialNo = 'NONE'
	  SET @n_SerialQTY = 1
	END
   ELSE
   BEGIN
      SET @c_SerialNo = 'NONE'
   END
 
    -- Check serial no is unique.
   IF @c_SerialNo NOT IN ('', 'NONE')
	BEGIN
	  -- Check SNO already scanned
	  IF EXISTS( SELECT 1 
	     FROM PackSerialNo WITH (NOLOCK)
	     WHERE PickSlipNo = @c_PickSlipNo
	        AND StorerKey = @c_StorerKey
	        AND SerialNo = @c_SerialNo)
	  BEGIN
        SET @n_Continue = 3; -- Sean03
	     SET @n_Err = 90010;
        SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': SerialNo already scan (ispSKUDCPA01)'; -- Sean03
	     GOTO QUIT_SP;
	  END
	END

	-- Insert PackDetail
	IF NOT EXISTS ( SELECT 1 FROM [dbo].[PackDetail] WITH (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo AND StorerKey = @c_StorerKey AND SKU = @c_PackDtlSKU AND CartonNo = @n_CartonNo)
	BEGIN
      -- Sean01 S
      SELECT @n_LabelLineNo = (COUNT(1) + 1)
         FROM [dbo].[PackDetail](NOLOCK) 
         WHERE PickSlipNo = @c_PickSlipNo 
         AND StorerKey = @c_StorerKey
         AND CartonNo = @n_CartonNo
      -- Sean01 E
      -- Sean02 B 
		INSERT INTO [dbo].[PackDetail] (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, Qty, DropId, UPC)
	 	VALUES(@c_PickSlipNo, @n_CartonNo, '', RIGHT('0000'+CONVERT(NVARCHAR, @n_LabelLineNo),5), @c_StorerKey, @c_PackDtlSKU, 1, '', @c_PackDtlUPC)
      -- Sean02 E
	END
	ELSE
	BEGIN
		UPDATE [dbo].[PackDetail] WITH (ROWLOCK)
		SET Qty = (Qty + 1)
		WHERE PickSlipNo = @c_PickSlipNo
		AND StorerKey = @c_StorerKey
		AND SKU = @c_PackDtlSKU
	END

	-- Insert PackSerialNo
   BEGIN
      -- Sean02 B 
      INSERT INTO [dbo].[PackSerialNo] (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, SerialNo, QTY, Barcode)
      SELECT TOP 1 
          PickSlipNo, CartonNo, '', LabelLine, StorerKey, SKU, @c_SerialNo, 1, 
          CASE 
              WHEN CHARINDEX('|', @c_SKU) = 0 THEN ''
              ELSE @c_SKU                               
          END
      FROM [dbo].[PackDetail] WITH (NOLOCK) 
      WHERE PickSlipNo = @c_PickSlipNo 
      AND CartonNo = @n_CartonNo
      AND StorerKey = @c_StorerKey
      AND SKU = @c_PackDtlSKU
      -- Sean02 E
   END
    
QUIT_SP:

   IF @n_Continue=3  -- Error Occured - Process AND Return
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'ispSKUDCPA01'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END -- End Procedure
GO
GRANT EXECUTE ON [dbo].[ispSKUDCPA01] TO NSQL
GO