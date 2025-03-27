SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store Procedure:  fnc_CalcCheckDigitLuhn_M10                         */
/* Creation Date: 26-Mar-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by: Supriya Sangeetham                                       */
/*                                                                      */
/* Purpose:  To calculate Modulus 10 Check Digits of a string using Luhn*/
/*           Algorithm as part of UWP-31693 - FCR-3325                  */
/*           https://en.wikipedia.org/wiki/Luhn_algorithm               */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 06/03/2025   SSA01     To calc check digit by using Luhn Algorithm   */
/************************************************************************/
CREATE OR ALTER FUNCTION [dbo].[fnc_CalcCheckDigitLuhn_M10] (
   @c_String     NVARCHAR(100),
   @b_RtnFullStr INT = 1
)
RETURNS NVARCHAR(100)
AS
BEGIN
   DECLARE @c_Digit             NVARCHAR(1)
         , @c_CheckDigit        NVARCHAR(1)
         , @n_Sum      INT
         , @n_Len               INT
         , @n_Pos               INT
         , @b_Error             INT
         , @n_doubled     INT

   SET @c_String       = LTRIM(RTRIM(@c_String))
   SET @c_CheckDigit   = ''
   SET @n_Sum = 0
   SET @n_Len          = LEN(@c_String)
   SET @n_Pos          = 0
   SET @b_Error        = 0

   WHILE @b_Error = 0 AND @n_Pos < @n_Len
   BEGIN
   	SET @n_Pos = @n_Pos + 1
   	SET @c_Digit = SUBSTRING(@c_String, @n_Len - @n_Pos + 1, 1)

      IF @c_Digit < '0' OR @c_Digit > '9'
      BEGIN
         SET @b_Error = 1
      END
      ELSE
      BEGIN
      	IF @n_Pos % 2 = 0
          BEGIN
            SET @n_Sum = @n_Sum + @c_Digit;
          END
          ELSE
            BEGIN
                SET @n_doubled = @c_Digit * 2;
                IF @n_doubled > 9
                BEGIN
                    SET @n_doubled = @n_doubled - 9;
                END
                SET @n_Sum = @n_Sum + @n_doubled;
            END
   	END
   END

   IF @b_Error = 0
   	SET @c_CheckDigit = CONVERT(NVARCHAR(1), ((10 - (@n_Sum % 10)) % 10))

   RETURN CASE WHEN @b_RtnFullStr=1 THEN @c_String + @c_CheckDigit ELSE @c_CheckDigit END
END
GO
GRANT EXECUTE ON [dbo].[fnc_CalcCheckDigitLuhn_M10] TO nSQL
GO
