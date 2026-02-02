SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: isp_TPS_ExtValidP09                                       */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date         Rev  Author      Purposes                                     */
/* 2025-05-08   1.0  GCH225      FCR-4548                                     */
/* 2025-08-26   1.0  GCH225      UWP-40099 Further check previous barcode     */
/******************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPS_ExtValidP09] (
	@json       NVARCHAR( MAX),
   @jResult    NVARCHAR( MAX) OUTPUT,
   @b_Success  INT = 1        OUTPUT,
   @n_Err      INT = 0        OUTPUT,
   @c_ErrMsg   NVARCHAR( 255) = ''  OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
BEGIN
	DECLARE
		@cStorerKey       NVARCHAR ( 15),
      @cFacility        NVARCHAR ( 5),
      @nFunc            INT,
      @cBarcode         NVARCHAR( 60),
      @cUserName        NVARCHAR( 30),
      @cLangCode        NVARCHAR( 3),
      @cSKU             NVARCHAR( 30),
      @cScanNo          NVARCHAR( 50),
      @cPreviousBarcode NVARCHAR(MAX),
      @Duplicates       NVARCHAR(2000)

   SET @Duplicates = ''
	--Decode Json Format
   SELECT @cStorerKey = StorerKey, @cFacility = Facility,  @nFunc = Func, @cBarcode = Barcode, @cUserName = UserName, @cLangCode = LangCode, @cScanNo = ScanNo, @cPreviousBarcode = PreviousBarcode
   FROM OPENJSON(@json)
   WITH (
      StorerKey         NVARCHAR ( 15),
      Facility          NVARCHAR ( 5),
      Func              INT,
      Barcode           NVARCHAR( 60),
      UserName          NVARCHAR( 30),
      LangCode          NVARCHAR( 3),
      ScanNo            NVARCHAR( 50),
      PreviousBarcode   NVARCHAR(MAX) as JSON
   )

   SELECT  @Duplicates = STRING_AGG(value, ',')
   FROM OPENJSON(@cPreviousBarcode)
   GROUP BY value
   HAVING COUNT(value) > 1

   IF @Duplicates <> ''
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Duplicated Scan found in current batch.(' + @Duplicates + ')'
      GOTO EXIT_SP
   END

   SET @b_Success = 1
   SET @jResult = ''

   IF LEFT(@cBarcode, 2) = '00'
   BEGIN
      SET @cBarcode = SUBSTRING(@cBarcode, 3, LEN(@cBarcode))
   END

   IF LEN(@cBarcode) < 5
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No must be at least 5 characters long.'
      GOTO EXIT_SP
   END

   IF LEN(@cBarcode) > 18
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No must not be more than 18 characters long.' 
      GOTO EXIT_SP
   END

   IF EXISTS (SELECT 1 FROM SKU (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cBarcode)
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No cannot be same as SKU code.' 
      GOTO EXIT_SP
   END

   IF EXISTS(SELECT 1 FROM PackSerialNo WITH (NOLOCK)
         WHERE PickSlipNo=@cScanNo    
               and StorerKey=@cStorerKey    
               and SerialNo=@cBarcode )
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No(' + @cBarcode + ') already been packed in PackSerialNo Table.'
      GOTO EXIT_SP
   END

   IF EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK)
         WHERE SerialNo = @cBarcode
         AND storerKey = @cStorerKey
         AND [Status] <> '1')
   BEGIN
      SET @b_Success = 0
      SET @n_Err = 400000
	   SET @c_ErrMsg = CAST(@n_Err AS NVARCHAR(20))+'Error: Serial No(' + @cBarcode + ') already been used or exists in SerialNo Table.'   
      GOTO EXIT_SP
   END

   SET @jResult = (SELECT '' AS SKU
   FOR JSON PATH,INCLUDE_NULL_VALUES)

EXIT_SP:
   SELECT @cStorerKey '@cStorerKey', @cBarcode '@cBarcode', @jResult '@jResult'

END

