SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store Procedure:  fnc_CalcGS1CheckDigit                              */
/* Creation Date: 29-May-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by: Shong                                                    */
/*                                                                      */
/* Purpose:  To calculate GS1 Check Digits of a @c_GSINKey              */
/*           UWP-35196                                                  */
/* Reference:                                                           */
/*    https://www.gs1.org/services/how-calculate-check-digit-manually   */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 29-May-2025  SWT       Created                                       */
/************************************************************************/
CREATE OR ALTER FUNCTION dbo.fnc_CalcGS1CheckDigit
(
    @c_GSINKey VARCHAR(20)  -- Usually 12 or more digits
)
RETURNS CHAR(1)
AS
BEGIN
    DECLARE @n_Len    INT = LEN(@c_GSINKey)
          , @n_Sum    INT = 0
          , @n_I      INT = 1
          , @n_Digit  INT
          , @n_Weight INT

    WHILE @n_I <= @n_Len
    BEGIN
        SET @n_Digit = CAST(SUBSTRING(@c_GSINKey, @n_I, 1) AS INT);
        SET @n_Weight = CASE WHEN ((@n_Len - @n_I + 1) % 2) = 0 THEN 1 ELSE 3 END;
        SET @n_Sum += @n_Digit * @n_Weight;
        SET @n_I += 1;
    END

    DECLARE @c_CheckDigit INT = (10 - (@n_Sum % 10)) % 10;
    RETURN CAST(@c_CheckDigit AS CHAR(1));
END
