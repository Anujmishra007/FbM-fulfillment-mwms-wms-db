SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: mspRLWAVGenID01                                    */
/* Creation Date: 21-MAY-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose: UWP-30411 - add storerconfig ASNExplodeByPackkeySP          */
/*          using Svalue to call sub-script and get a customized ID     */
/* Called By: lsp_ExplodeByPackKey_Wrapper                              */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[mspRLWAVGenID01] (
   @c_StorerKey   NVARCHAR(15),
   @c_IDKey       NVARCHAR(20)    OUTPUT,
   @b_Success     INT = 1         OUTPUT,
   @n_ErrNo       INT             OUTPUT,
   @c_ErrMsg      NVARCHAR(250)   OUTPUT
)
AS
   SET NOCOUNT ON                    
   SET ANSI_NULLS OFF                 
   SET QUOTED_IDENTIFIER OFF          
   SET CONCAT_NULL_YIELDS_NULL OFF  

DECLARE
   @n_Continue      INT            = 1,
   @c_Identifier    NVARCHAR( 2),
   @c_Packtype      NVARCHAR( 1),
   @c_SUSR1         NVARCHAR( 20),
   @c_nCounter      NVARCHAR( 25),
   @n_CheckDigit    INT,
   @n_TotalCnt      INT,
   @n_TotalOddCnt   INT,
   @nTotalEvenCnt   INT,
   @n_Add           INT,
   @n_Remain        INT,
   @n_OddCnt        INT,
   @n_EvenCnt       INT,
   @n_Odd           INT,
   @n_Even          INT

BEGIN
      SET @c_Identifier = '00'
      SET @c_Packtype = '0'
      SET @c_IDKey = ''

      SELECT @c_SUSR1 = ISNULL(SUSR1, '0')
      FROM dbo.Storer WITH (NOLOCK)
      WHERE Storerkey = @c_StorerKey
      AND Type = '1'

    IF LEN(@c_SUSR1) >= 9
      BEGIN
         SET @b_Success = 0
         SET @n_ErrNo = 99001
         SET @c_ErrMsg = 'Invld Barcode(mspRLWAVGenID01)'
         GOTO QUIT_SP
      END   

      EXEC dbo.isp_getucckey
            @c_StorerKey,
            9,
            @c_nCounter OUTPUT ,
            @b_success  OUTPUT,
            @n_ErrNo      OUTPUT,
            @c_ErrMsg   OUTPUT,
            0,
            1

      IF @b_success <> 1
      BEGIN
         SET @b_Success = 0
         SET @n_ErrNo = 99002
         SET @c_ErrMsg = 'GenUCCKeyFail(mspRLWAVGenID01)'
         GOTO QUIT_SP
      END

      IF LEN(@c_SUSR1) <> 8
         SELECT @c_SUSR1 = RIGHT('0000000' + CAST(@c_SUSR1 AS NVARCHAR( 7)), 7)
      SET @c_IDKey = @c_Identifier + @c_Packtype + RTRIM(@c_SUSR1) + RTRIM(@c_nCounter) 
      SET @n_Odd = 1
      SET @n_OddCnt = 0
      SET @n_TotalOddCnt = 0
      SET @n_TotalCnt = 0

      WHILE @n_Odd <= 20
      BEGIN
         SET @n_OddCnt = CAST(SUBSTRING(@c_IDKey, @n_Odd, 1) AS INT)
         SET @n_TotalOddCnt = @n_TotalOddCnt + @n_OddCnt
         SET @n_Odd = @n_Odd + 2
      END

      SET @n_TotalCnt = (@n_TotalOddCnt * 3)

      SET @n_Even = 2
      SET @n_EvenCnt = 0
      SET @nTotalEvenCnt = 0

      WHILE @n_Even <= 20
      BEGIN
         SET @n_EvenCnt = CAST(SUBSTRING(@c_IDKey, @n_Even, 1) AS INT)
         SET @nTotalEvenCnt = @nTotalEvenCnt + @n_EvenCnt
         SET @n_Even = @n_Even + 2
      END

      SET @n_Add = 0
      SET @n_Remain = 0
      SET @n_CheckDigit = 0

      SET @n_Add = @n_TotalCnt + @nTotalEvenCnt
      SET @n_Remain = @n_Add % 10
      SET @n_CheckDigit = 10 - @n_Remain

      IF @n_CheckDigit = 10
         SET @n_CheckDigit = 0
      SET @c_IDKey = ISNULL(RTRIM(@c_IDKey), '') + CAST(@n_CheckDigit AS NVARCHAR( 1))

   QUIT_SP:
END
GO
