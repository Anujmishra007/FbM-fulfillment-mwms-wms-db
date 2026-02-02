SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_511ExtInfo01                                    */
/* Purpose: Move By ID Extended Validate                                */
/*                                                                      */
/* Called from: rdtfnc_Move_ID                                          */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 19-Sep-2025 1.0  JBI034      WMS7487 - Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtInfo01_HP] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cFromID          NVARCHAR( 18),    
   @cFromLOC         NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @cToID            NVARCHAR( 18),
   @cSKU             NVARCHAR( 20),
   @cExtendedInfo    NVARCHAR( 20) OUTPUT
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @cReceiptkey char(10)
		   ,@cSOStatus char(10)
		    ,@cPlaceOfLoading char(10)

   IF @nFunc = 511 and @nStep = 2 AND @nInputKey = 1
  
      BEGIN

Select @cExtendedInfo = ''

Select Top 1 @cReceiptkey = rd.receiptkey, 
             @cSOStatus   = orders.SOStatus, 
             @cPlaceOfLoading = mbol.placeofloading
from receiptdetail rd (nolock)
left join orders (nolock) on rd.Externreceiptkey = orders.Externorderkey and rd.Storerkey = Orders.Storerkey
left join mbol   (nolock) on orders.mbolkey = mbol.mbolkey
left join RECEIPT r (nolock) on rd.receiptkey=r.ReceiptKey
where rd.storerkey = @cStorerkey 
and rd.Toid = @cFromID 
and rd.ToLoc = @cFromLoc 
and r.ASNStatus = '9'
and (rd.BeforeReceivedQty > 0 or rd.QtyReceived > 0)
order by rd.editdate desc

if @@ROWCOUNT = 0 set @cExtendedInfo = '<none>'
else
if exists(select 1 from receiptdetail (nolock) where receiptkey = @cReceiptkey and ConditionCode = 'DMG') set  @cExtendedInfo = 'Move to Damage'
else 
if @cSOStatus = 'BK' set @cExtendedInfo = 'Move to Buffer'
else
set @cExtendedInfo = 'Move to ' + @cPlaceOfLoading

      END
   

QUIT:
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_511ExtInfo01_HP] TO NSQL
GO
