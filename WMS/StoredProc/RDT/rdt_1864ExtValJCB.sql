
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************************************************************/
/* Store procedure: [rdt_1864ExtValJCB]                                              */
/* Copyright: Maersk                                                                 */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 15/09/2025   1.0   PPA374   Only allow TOLOC from CODELKUP JCBPPALLOC             */
/*************************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1864ExtValJCB]
(
    @nMobile       INT,                    
    @nFunc         INT,
    @cLangCode     NVARCHAR(3), 
    @nStep         INT,         
    @nInputKey     INT,         
    @cFacility     NVARCHAR(5), 
    @cStorerKey    NVARCHAR(15), 
    @cPickSlipNo   NVARCHAR(10), 
    @cPickZone     NVARCHAR(10),
    @cLOC          NVARCHAR(10), 
    @cID           NVARCHAR(18), 
    @cSKU          NVARCHAR(20), 
    @cLottable01   NVARCHAR(18), 
    @cLottable02   NVARCHAR(18), 
    @cLottable03   NVARCHAR(18), 
    @dLottable04   DATETIME,     
    @dLottable05   DATETIME,       
    @cLottable06   NVARCHAR(30),
    @cLottable07   NVARCHAR(30), 
    @cLottable08   NVARCHAR(30), 
    @cLottable09   NVARCHAR(30), 
    @cLottable10   NVARCHAR(30), 
    @cLottable11   NVARCHAR(30), 
    @cLottable12   NVARCHAR(30), 
    @dLottable13   DATETIME,      
    @dLottable14   DATETIME,      
    @dLottable15   DATETIME,      
    @nTaskQTY      INT,            
    @cToLOC        NVARCHAR(10), 
    @cOption       NVARCHAR(1),  
    @nErrNo        INT OUTPUT, 
    @cErrMsg       NVARCHAR(20) OUTPUT   
)
AS
BEGIN
   SET NOCOUNT ON;

   -- Variable declarations
   DECLARE 
      @nRowCount    INT,
      @cActLoc      NVARCHAR(20),
      --@cID        NVARCHAR(50),
      @cPalType     NVARCHAR(10),
      @cLocRoom     NVARCHAR(20),
      @cLocCat      NVARCHAR(20),
      @cMidLoc      NVARCHAR(20),
      @cFstLoc      NVARCHAR(20),
      @cTrdLoc      NVARCHAR(20),
      @cUser        NVARCHAR(50),
      @cLocPAZ      NVARCHAR(20)

   -- Initial retrieval of values from mobility record
   SELECT 
      @cStorerKey = storerkey,
      @cFacility  = Facility,
      @cID        = V_String2,
      @cUser      = UserName
   FROM RDT.RDTMobrec WITH (NOLOCK)
   WHERE Mobile = @nMobile;

   IF @nFunc = 1864 
   BEGIN
      IF @nStep = 5 
      BEGIN
         IF @nInputKey = 1 -- Enter pressed
         BEGIN
            BEGIN
	           SELECT TOP 1 
		          @cLocCat = LocationCategory, 
			      @cLocPAZ = PutawayZone 
		       FROM dbo.LOC WITH(NOLOCK) 
		       WHERE Facility = @cFacility 
		          AND LOC = @cToLOC

	           IF NOT EXISTS (
		          SELECT 1 
				  FROM dbo.CODELKUP WITH(NOLOCK) 
			      WHERE LISTNAME = 'JCBPPALLOC' 
			         AND Short = @cLocCat
			         AND Long = @cLocPAZ
			   )
		       BEGIN
		          SET @nErrNo = 218237
			      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
			      GOTO QUIT
		       END
            END
         END        
      END
   END
QUIT:
END
GO

GRANT EXECUTE ON rdt_1864ExtValJCB TO NSQL
GO

