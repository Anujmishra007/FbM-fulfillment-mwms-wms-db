
/****** Object:  StoredProcedure [RDT].[rdt_685AutoGenJCB]    Script Date: 7/15/2025 3:33:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************************************/
/* Store procedure: rdt_685AutoGenJCB                                            */
/* Copyright      : Maersk                                                       */
/* Customer       : JCB                                                          */
/*                                                                               */
/*                                                                               */
/* Date         Rev   Author   Purposes                                          */
/* 11/03/2025   1.0   SKE140   Providing automatic XLPN ID                       */
/*********************************************************************************/
 
CREATE OR ALTER PROC [RDT].[rdt_685AutoGenJCB] (
   @nMobile     INT,          
   @nFunc       INT,          
   @nStep       INT,          
   @cLangCode   NVARCHAR( 3),  
   @tExtData    VariableTable READONLY,
   @cAutoID     NVARCHAR( 18) OUTPUT,
   @nErrNo      INT           OUTPUT,  
   @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
 
   DECLARE
      @cReceiptKey AS NVARCHAR(50),
      @cPOKey AS NVARCHAR(50),
      @cLoc AS NVARCHAR(50),
      @dAddDate AS DATETIME,
      @cAddUser AS NVARCHAR(20),
      @cUDF01 AS NVARCHAR(50),
      @cUDF02 AS NVARCHAR(50),
      @cUDF03 AS NVARCHAR(50),
      @cUDF04 AS NVARCHAR(50),
      @cUDF05 AS NVARCHAR(50),
      @cUDF06 AS NVARCHAR(50),
      @cUDF07 AS NVARCHAR(50),
      @cUDF08 AS NVARCHAR(50),
      @cUDF09 AS NVARCHAR(50),
      @cUDF10 AS NVARCHAR(50),
      @cUDF11 AS NVARCHAR(50),
      @cUDF12 AS NVARCHAR(50),
      @nInputKey AS INT
 
   SELECT @nInputKey = InputKey FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile
 
   SELECT TOP 1
      @cReceiptKey = V_ReceiptKey,
      @cPOKey = V_POKey,
      @cLoc = V_Loc,
      @dAddDate = GETDATE(),
      @cAddUser = UserName,
      @cUDF01 = '',
      @cUDF02 = '',
      @cUDF03 = '',
      @cUDF04 = '',
      @cUDF05 = '',
      @cUDF06 = '',
      @cUDF07 = '',
      @cUDF08 = '',
      @cUDF09 = '',
      @cUDF10 = '',
      @cUDF11 = '',
      @cUDF12 = ''
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile
 
   IF EXISTS (SELECT 1 FROM ReceiptJCBXLPNCounter WITH(NOLOCK) WHERE AddUser = @cAddUser AND ISNULL(STATUS,'') IN ('NOT RECEIVED',''))
   BEGIN
      SELECT TOP 1 @cAutoID = (SELECT MAX(LPN) FROM ReceiptJCBXLPNCounter WITH(NOLOCK) WHERE AddUser = @cAddUser AND ISNULL(STATUS,'') IN ('NOT RECEIVED',''))
      GOTO HOUSEKEEPING
   END
 
   IF @nStep = 2 OR NOT EXISTS (SELECT 1 FROM ReceiptJCBXLPNCounter WITH(NOLOCK) WHERE AddUser = @cAddUser AND ISNULL(STATUS,'') IN ('NOT RECEIVED',''))
   BEGIN
      BEGIN
         SELECT TOP 1 @cAutoID = CASE WHEN MAX(LPN) IS NULL OR MAX(LPN) = 'X999999999' THEN 'X000000001' ELSE 'X' + RIGHT('000000000' + CONVERT(NVARCHAR(10), CONVERT(INT, RIGHT(MAX(LPN), 9)) + 1), 9) END FROM ReceiptJCBXLPNCounter WITH(NOLOCK)
 
         INSERT INTO ReceiptJCBXLPNCounter (
            PO, ASN, LOC, LPN, AddDate, AddUser, UDF01, UDF02, UDF03, UDF04, UDF05, UDF06, UDF07, UDF08, UDF09, UDF10, UDF11, UDF12, STATUS
         )
         VALUES (
            @cPOKey, @cReceiptKey, ''/*@cLoc*/, @cAutoID, @dAddDate, @cAddUser, @cUDF01, @cUDF02, @cUDF03, @cUDF04, @cUDF05, @cUDF06, @cUDF07, @cUDF08, @cUDF09, @cUDF10, @cUDF11, @cUDF12, 'NOT RECEIVED'
         );
         GOTO HOUSEKEEPING
      END
 
      --Keeping no more than 1000 records in the table
      HOUSEKEEPING:
      IF (SELECT COUNT(1) FROM ReceiptJCBXLPNCounter WITH(NOLOCK)) >= 2000
      BEGIN
         DELETE FROM ReceiptJCBXLPNCounter
         WHERE LPN IN (
            SELECT TOP 1000 LPN
            FROM ReceiptJCBXLPNCounter
            ORDER BY AddDate ASC
         );
      END

	  IF @cAutoID = 'X000000001'
	  BEGIN
         DELETE FROM ReceiptJCBXLPNCounter
	  END

   END

   UPDATE RDT.RDTMOBREC WITH(ROWLOCK)
   SET V_ID = @cAutoID
   WHERE Mobile = @nMobile

END
 
GO
GRANT EXECUTE ON [RDT].[rdt_685AutoGenJCB] TO [NSQL]
GO

