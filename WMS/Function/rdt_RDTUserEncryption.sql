IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[rdt].[rdt_RDTUserEncryption]')  AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')) 
   DROP FUNCTION [rdt].[rdt_RDTUserEncryption]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Function: rdt_RDTUserEncryption                               */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: UWP- 21905                                                 */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Version    Author   Purposes                            */
/* 2024-07-26   1.0        JACKC    UWP-21905 created                   */
/************************************************************************/
CREATE FUNCTION rdt.rdt_RDTUserEncryption
(
   @cUsrName    NVARCHAR(18),
   @cPassword   NVARCHAR(15)
)
RETURNS NVARCHAR(32)
BEGIN

   DECLARE
      @cEncryptPassword NVARCHAR(32) 
   
   SET @cEncryptPassword = MASTER.dbo.fnc_CryptoEncrypt(@cPassword, UPPER(@cUsrName))

   RETURN @cEncryptPassword
END
GO

GRANT EXECUTE ON rdt.rdt_RDTUserEncryption TO NSQL
GO