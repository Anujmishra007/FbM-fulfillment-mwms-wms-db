
/************************************************************************/
/* Stored Procedure: rdt_600ExtInfoVLT                                  */
/*																		*/
/*                                                                      */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver.  Purposes                                  */
/* 01/05/0224   PPA374  1.0   Predict putaway zone                      */
/* 15/07/0224   PPA374  2.0   Predict putaway zone with new logic       */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_600ExtInfoVLT]
@nMobile            INT,
@nFunc              INT,
@cLangCode          NVARCHAR( 3),
@nStep              INT,
@nAfterStep         INT,
@nInputKey          INT,
@cFacility          NVARCHAR( 5),
@cStorerKey         NVARCHAR( 15),
@cReceiptKey        NVARCHAR( 10),
@cPOKey             NVARCHAR( 10),
@cLOC               NVARCHAR( 10),
@cID                NVARCHAR( 18),
@cSKU               NVARCHAR( 20),
@cLottable01        NVARCHAR( 18),
@cLottable02        NVARCHAR( 18),
@cLottable03        NVARCHAR( 18),
@dLottable04        DATETIME,
@dLottable05        DATETIME,
@cLottable06        NVARCHAR( 30),
@cLottable07        NVARCHAR( 30),
@cLottable08        NVARCHAR( 30),
@cLottable09        NVARCHAR( 30),
@cLottable10        NVARCHAR( 30),
@cLottable11        NVARCHAR( 30),
@cLottable12        NVARCHAR( 30),
@dLottable13        DATETIME,
@dLottable14        DATETIME,
@dLottable15        DATETIME,
@nQTY               INT,
@cReasonCode        NVARCHAR( 10),
@cSuggToLOC         NVARCHAR( 10),
@cFinalLOC          NVARCHAR( 10),
@cReceiptLineNumber NVARCHAR( 10),
@cExtendedInfo      NVARCHAR(20)  OUTPUT,
@nErrNo             INT           OUTPUT,
@cErrMsg            NVARCHAR( 20) OUTPUT  
AS
BEGIN
   SET NOCOUNT ON 

   IF @nstep = 5
   BEGIN

      --Establish an LPN type
      DECLARE 
      @LPNPATYPE NVARCHAR(20),
      @ABC       NVARCHAR(3)

	  select top 1 @ABC = ABC from SKU (NOLOCK) where sku = @cSKU and StorerKey = @cStorerKey

      --Battery
      IF (select top 1 Style from sku (NOLOCK) where sku = @cSKU and StorerKey = @cStorerKey) = 'B'
      BEGIN
         set @LPNPAType = 'Battery' 
      END

      --VelocityA
      ELSE IF @ABC = 'A'
      BEGIN
         set @LPNPAType = 'VelocityA' 
      END

      --VelocityB
      ELSE IF @ABC = 'B'
      BEGIN
         set @LPNPAType = 'VelocityB' 
      END

      --VelocityC
      ELSE IF @ABC = 'C'
      BEGIN
         set @LPNPAType = 'VelocityC' 
      END
	
      --VelocityE
      ELSE IF @ABC = 'E'
      BEGIN
         set @LPNPAType = 'VelocityE' 
      END

      ELSE --If LPN type could not be established
      BEGIN
         set @LPNPATYPE ='UNKNOWN'
      END

      --Giving predicted area for the putaway based on the SKU.
      SET @cExtendedInfo = 
      (select top 1 case when 'VNA' in (select Short from CODELKUP (NOLOCK) where LISTNAME = 'HUSQLPNTYP' and UDF01 = @LPNPATYPE and Storerkey = @cStorerKey) 
      and 'WA' in (select Short from CODELKUP (NOLOCK) where LISTNAME = 'HUSQLPNTYP' and UDF01 = @LPNPATYPE and Storerkey = @cStorerKey) 
      then 'PA target: VNA or WA'
      when 'WA' in (select Short from CODELKUP (NOLOCK) where LISTNAME = 'HUSQLPNTYP' and UDF01 = @LPNPATYPE and Storerkey = @cStorerKey) 
      then 'PA target: WA'
      when 'VNA' in (select Short from CODELKUP (NOLOCK) where LISTNAME = 'HUSQLPNTYP' and UDF01 = @LPNPATYPE and Storerkey = @cStorerKey) 
      then 'PA target: VNA' else 'Unknown PA target' end)

   END

END

GRANT EXECUTE ON [RDT].[rdt_600ExtInfoVLT] TO [NSQL]
