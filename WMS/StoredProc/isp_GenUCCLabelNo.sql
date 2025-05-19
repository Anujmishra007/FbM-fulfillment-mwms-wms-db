SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/**************************************************************************/
/* Stored Procedure: isp_GenUCCLabelNo                                    */
/* Creation Date: 04-Aug-2009                                             */
/* Copyright: IDS                                                         */
/* Written by: NJOW                                                       */
/*                                                                        */
/* Purpose: SOS#141877 - Generate UCC Label No                            */
/*                                                                        */
/* Called By: isp_AutoPackLoad                                            */ 
/*                                                                        */
/* Parameters:                                                            */
/*                                                                        */
/* PVCS Version: 1.0	                                                     */
/*                                                                        */
/* Version: 5.4                                                           */
/*                                                                        */
/* Data Modifications:                                                    */
/*                                                                        */
/* Updates:                                                               */
/* Date         Author    Ver.  Purposes                                  */
/* 04-Jun-2024  NJOW01    1.0   WMS-25578 When susr1 len is 7-9 adjust the*/
/*                              running# len to for making the labelno    */
/*                              len to 19 plus check digit become len 20  */
/* 14-May-2025  Michael   1.1   FCR-2087 get @cPacktype from OPTION5(ML01)*/
/**************************************************************************/

CREATE OR ALTER PROC isp_GenUCCLabelNo (
   @cStorerKey NVARCHAR( 15),
   @cLabelNo   NVARCHAR( 20) OUTPUT, 
   @b_success  int OUTPUT,
   @n_err      int OUTPUT,
   @c_errmsg   NVARCHAR(225) OUTPUT
)
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
	 DECLARE 	
   @cIdentifier    NVARCHAR( 2),
	 @cPacktype      NVARCHAR( 1),
   @cSUSR1         NVARCHAR( 20),
   @c_nCounter     NVARCHAR( 25),
   @nCheckDigit    INT,
   @nTotalCnt      INT,
   @nTotalOddCnt   INT,
   @nTotalEvenCnt  INT,
   @nAdd           INT,
   @nDivide        INT,
   @nRemain        INT,
   @nOddCnt        INT,
   @nEvenCnt       INT,
   @nOdd           INT,
   @nEven          INT,
   @n_RunNoLen     INT = 9,  --NJOW01
   @c_SSCCDynSerialByCompPrefix NVARCHAR(10) = 'N',  --NJOW01
   @c_Option5      NVARCHAR(1000) --NJOW01

	 SELECT @b_success = 1, @c_errmsg='', @n_err=0 

   IF EXISTS (SELECT 1 FROM StorerConfig WITH (NOLOCK)
              WHERE StorerKey = @cStorerKey
              AND ConfigKey = 'GenUCCLabelNoConfig'
              AND SValue = '1')
   BEGIN
     SET @cIdentifier = '00'   --SSCC AI
	   SET @cPacktype = '0'      --SSCC Ext. Digit
     SET @cLabelNo = ''

     SELECT @cSUSR1 = ISNULL(SUSR1, '0')   --SSCC company prefix
	   FROM Storer WITH (NOLOCK)
	   WHERE Storerkey = @cStorerkey
	   AND Type = '1'
	   
	   --NJOW01 S
     SELECT @c_Option5 = SC.Option5
     FROM dbo.fnc_GetRight2('', @cStorerkey,'','GenUCCLabelNoConfig') AS SC	   
     
     SELECT @c_SSCCDynSerialByCompPrefix = dbo.fnc_GetParamValueFromString ('@c_SSCCDynSerialByCompPrefix', @c_option5, @c_SSCCDynSerialByCompPrefix)
     --NJOW01 E     

     SELECT @cPacktype = dbo.fnc_GetParamValueFromString ('@cPacktype', @c_option5, @cPacktype)    --ML01
     IF ISNULL(@cPacktype,'') NOT LIKE '[0-9]' SET @cPacktype = '0'                                --ML01

	   IF LEN(@cSUSR1) >= 9 AND @c_SSCCDynSerialByCompPrefix <> 'Y' --NJOW01
     BEGIN
  	    SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 60201   
	      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Invalid part barcode. (isp_GenUCCLabelNo)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) ' 
	      SELECT @b_success = 0
		    GOTO Quit
     END 
     
     --NJOW01 S
     IF LEN(@cSUSR1) IN(7,8,9) AND @c_SSCCDynSerialByCompPrefix = 'Y'
     BEGIN
     	  SET @n_RunNoLen = 9 - (LEN(@cSUSR1) - 7)

	      EXEC isp_getucckey
			   @cStorerkey,
			   @n_RunNoLen,     --SSCC serial reference (running number)
			   @c_nCounter OUTPUT ,
			   @b_success  OUTPUT,
			   @n_err      OUTPUT,
			   @c_errmsg   OUTPUT,
			   0,
			   1        	
     END --NJOW01 E
     ELSE
     BEGIN
     	  --Original logic
	      EXEC isp_getucckey
			   @cStorerkey,
			   9,
			   @c_nCounter OUTPUT ,
			   @b_success  OUTPUT,
			   @n_err      OUTPUT,
			   @c_errmsg   OUTPUT,
			   0,
			   1
        
	      IF LEN(@cSUSR1) <> 8 
            SELECT @cSUSR1 = RIGHT('0000000' + CAST(@cSUSR1 AS NVARCHAR( 7)), 7)     	
     END
                 
	   SET @cLabelNo = @cIdentifier + @cPacktype + RTRIM(@cSUSR1) + RTRIM(@c_nCounter) --+ @nCheckDigit

	   SET @nOdd = 1
     SET @nOddCnt = 0
     SET @nTotalOddCnt = 0
     SET @nTotalCnt = 0

     WHILE @nOdd <= 20 
     BEGIN
		   SET @nOddCnt = CAST(SUBSTRING(@cLabelNo, @nOdd, 1) AS INT)
		   SET @nTotalOddCnt = @nTotalOddCnt + @nOddCnt
		   SET @nOdd = @nOdd + 2
     END

	   SET @nTotalCnt = (@nTotalOddCnt * 3) 
	
	   SET @nEven = 2
     SET @nEvenCnt = 0
     SET @nTotalEvenCnt = 0

	   WHILE @nEven <= 20 
     BEGIN
		   SET @nEvenCnt = CAST(SUBSTRING(@cLabelNo, @nEven, 1) AS INT)
		   SET @nTotalEvenCnt = @nTotalEvenCnt + @nEvenCnt
		   SET @nEven = @nEven + 2
	   END

     SET @nAdd = 0
     SET @nRemain = 0
     SET @nCheckDigit = 0

	   SET @nAdd = @nTotalCnt + @nTotalEvenCnt
	   SET @nRemain = @nAdd % 10
	   SET @nCheckDigit = 10 - @nRemain  --SSCC check digit

	   IF @nCheckDigit = 10 
			  SET @nCheckDigit = 0

	   SET @cLabelNo = ISNULL(RTRIM(@cLabelNo), '') + CAST(@nCheckDigit AS NVARCHAR( 1))
   END   -- GenUCCLabelNoConfig
   ELSE
   BEGIN
      EXECUTE nspg_GetKey
         'PACKNO', 
         10 ,
         @cLabelNo   OUTPUT,
         @b_success  OUTPUT,
         @n_err      OUTPUT,
         @c_errmsg   OUTPUT
   END
   Quit:

END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON isp_GenUCCLabelNo to nSQL
GO


