IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'dbo.ispNIKECNL3FrRcptSKU') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE dbo.ispNIKECNL3FrRcptSKU
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: ispNIKECNL3FrRcptSKU                                */
/* Copyright: IDS                                                       */
/* Purpose: Default lottable03 from ReceiptDetail                       */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2012-04-02   Ung       1.0   Created                                 */
/************************************************************************/

CREATE PROCEDURE dbo.ispNIKECNL3FrRcptSKU
   @c_Storerkey        char(15),
   @c_Sku              char(20),
	@c_Lottable01Value  char(18),
	@c_Lottable02Value  char(18),
	@c_Lottable03Value  char(18),
	@dt_Lottable04Value datetime,
	@dt_Lottable05Value datetime,
	@c_Lottable01       char(18) OUTPUT,
	@c_Lottable02       char(18) OUTPUT,
	@c_Lottable03       char(18) OUTPUT,
	@dt_Lottable04      datetime OUTPUT,
   @dt_Lottable05      datetime OUTPUT,
   @b_Success          int = 1  OUTPUT,
   @n_ErrNo            int = 0  OUTPUT,
   @c_Errmsg           char(250) = '' OUTPUT,
   @c_Sourcekey        char(15) = '',  
   @c_Sourcetype       char(20) = '',  
   @c_LottableLabel    char(20) = ''   
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @c_Sourcetype IN ('RECEIPT','RECEIPTFINALIZE')
      RETURN

   -- Get ToID
   DECLARE @cToID NVARCHAR(18)
   SET @cToID = ''
   SELECT TOP 1 
      @cToID = V_ID
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE V_ReceiptKey = @c_Sourcekey
      AND StorerKey = @c_Storerkey
      -- AND V_SKU = @c_Sku
      AND UserName = SUSER_SNAME()
   ORDER BY EditDate DESC

   -- Get receipt detail info
   SET @c_Lottable03 = ''
   SELECT TOP 1
      @c_Lottable03 = Lottable03
   FROM dbo.ReceiptDetail WITH (NOLOCK)
   WHERE ReceiptKey = @c_Sourcekey
      AND SKU = @c_SKU
      AND Lottable03 <> ''
   ORDER BY 
       CASE WHEN QTYExpected > BeforeReceivedQTY THEN 0 ELSE 1 END
      ,CASE WHEN ToID = @cToID THEN 0 ELSE 1 END
      ,ReceiptLineNumber
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.ispNIKECNL3FrRcptSKU TO NSQL
GO
