/************************************************************************/
/* Stored Procedure: ispSKUDC16                                         */
/* Creation Date: 02/07/2025                                            */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: FCR-6199 Sephora - SCE Ecom Packing SKU Decode CR           */
/*                                                                      */
/*                                                                      */
/* Called By: isp_SKUDecode_Wrapper                                     */
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
/* 25-Aug-2025  Sean01  1.1   FCR-6199 - QRCode pipe '|' count check    */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ispSKUDC16]
     @c_Storerkey        NVARCHAR(15)
   , @c_Sku              NVARCHAR(500)
   , @c_NewSku           NVARCHAR(60)      OUTPUT
   , @c_Code01           NVARCHAR(60) = '' OUTPUT
   , @c_Code02           NVARCHAR(60) = '' OUTPUT
   , @c_Code03           NVARCHAR(60) = '' OUTPUT
   , @b_Success          INT          = 1  OUTPUT
   , @n_Err              INT          = 0  OUTPUT
   , @c_ErrMsg           NVARCHAR(250)= '' OUTPUT
   , @c_Pickslipno       NVARCHAR(10) = ''
   , @n_CartonNo         INT = 0
   , @c_UCCNo            NVARCHAR(20) = ''  --Pack by UCC when UCCtoDropID = '1' 
AS
BEGIN
    SET NOCOUNT ON;
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE 
        @c_UPC       NVARCHAR(30),
        @c_BUSR5     NVARCHAR(30),
        @n_Pos       INT,
        @n_PipeCount INT,
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
   

    -- Check if barcode is QRCode by detecting '|'
    SET @n_Pos = CHARINDEX('|', @c_Sku);
    IF @n_Pos > 0
      SET @c_UPC = LEFT( @c_Sku, @n_Pos - 1)
    ELSE
      -- 1D barcode
      SET @c_UPC = LEFT( @c_Sku, 30)
    
    -- Get UPC, for saving into PackDetail.UPC
    SELECT 
       @c_NewSku = SKU
    FROM dbo.UPC WITH (NOLOCK)
    WHERE StorerKey = @c_StorerKey
       AND UPC = @c_UPC

    IF @@ROWCOUNT <> 1
    BEGIN
       SET @c_NewSku = ''
    END

    -- Get BUSR5 and StorerKey from SKU
    SELECT @c_BUSR5 = ISNULL( BUSR5, '')
    FROM dbo.SKU WITH (NOLOCK)
    WHERE StorerKey = @c_Storerkey 
      AND SKU = @c_NewSku;

    IF @@ROWCOUNT = 0
    BEGIN
        SET @n_Continue = 3;
        SET @n_Err = 90008;
        SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Cannot find SKU by UPC/BarCode (ispSKUDC16)';
        GOTO QUIT_SP;
    END

    -- SKU requires QRCode but scanned UPC
    IF (@c_BUSR5 = '1' AND @n_Pos = 0)
    BEGIN
        SET @n_Continue = 3;
        SET @n_Err = 90002;
        SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Must scan QRCode (ispSKUDC16)';
        GOTO QUIT_SP;
    END

    -- SKU does not require QRCode but scanned QRCode
    IF (@c_BUSR5 <> '1' AND @n_Pos > 0)
    BEGIN
        SET @n_Continue = 3;
        SET @n_Err = 90003;
        SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Must scan UPC (ispSKUDC16)';
        GOTO QUIT_SP;
    END

    -- QRCode parsing & validation
    IF (@c_BUSR5 = '1' AND @n_Pos > 0)
    BEGIN
        -- Sean01 B
        SET @n_PipeCount = LEN(@c_Sku) - LEN(REPLACE(@c_Sku,'|',''));

        IF @n_PipeCount = 4  -- No Serial No
        BEGIN
            IF LEN(rdt.rdtGetParsedString(@c_Sku,5,'|')) > 8
            BEGIN
                SET @n_Continue = 3;
                SET @n_Err = 90004;
                SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': QRCode UCC error';
                GOTO QUIT_SP;
            END
        END
        ELSE IF @n_PipeCount = 5  -- Has Serial No
        BEGIN
            IF LEN(rdt.rdtGetParsedString(@c_Sku,5,'|')) > 8
            BEGIN
                SET @n_Continue = 3;
                SET @n_Err = 90004;
                SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': QRCode UCC error';
                GOTO QUIT_SP;
            END
            IF LEN(rdt.rdtGetParsedString(@c_Sku,6,'|')) NOT IN (0,12)
            BEGIN
                SET @n_Continue = 3;
                SET @n_Err = 90005;
                SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': QRCode SerialNo error';
                GOTO QUIT_SP;
            END
        END
        ELSE
        BEGIN
            SET @n_Continue = 3;
            SET @n_Err = 90006;
            SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': QRCode error';
            GOTO QUIT_SP;
        END
        -- Sean01 E
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
      EXECUTE dbo.nsp_LogError @n_Err, @c_Errmsg, 'ispSKUDC16'
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
GRANT EXECUTE ON [dbo].[ispSKUDC16] TO NSQL
GO