SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/****************************************************************************/
/* Store procedure: rdt_511ExtInfoVLT1                                      */
/*                                                                          */
/*                                                                          */
/* Date         VER   Author   Purpose                                      */
/* 25/04/2024   1.0   PPA374   Suggesting up to 2 locations for VNA PA      */
/* 15/07/2024   2.0   PPA374   Stopping picked LPNs to be moved incorrectly */
/* 12/12/2024   2.1   PPA374   Excluding specific location from substring   */
/****************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_511ExtInfoVLT1] (
@nMobile         INT,
@nFunc           INT,
@cLangCode       NVARCHAR( 3),
@nStep           INT,
@nInputKey       INT,
@cStorerKey      NVARCHAR( 15),
@cFromID         NVARCHAR( 18),
@cFromLOC        NVARCHAR( 10),
@cToLOC          NVARCHAR( 10),
@cToID           NVARCHAR( 18),
@cSKU            NVARCHAR( 20),
@cExtendedInfo   NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 511 AND @nStep = 2 AND @nInputKey = 1
   BEGIN
      DECLARE 
      @PNDPICKChk int,
      @VASChk int,
      @Facility NVARCHAR(20)

      SELECT TOP 1 @Facility = FACILITY FROM rdt.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile
      SET @PNDPICKChk = CASE WHEN (SELECT TOP 1 LocationType FROM dbo.LOC WITH (NOLOCK) WHERE loc = @cFromLoc AND Facility = @Facility AND loc LIKE 'B_999%') = 'PND' AND EXISTS (SELECT 1 FROM dbo.PICKDETAIL WITH (NOLOCK) WHERE id = @cFromID AND sku = @cSKU AND STATUS = 5 AND dropid <> '' AND Storerkey = @cStorerKey) THEN 1 ELSE 0 END
      SET @VASChk = CASE WHEN (SELECT TOP 1 LocationType FROM dbo.LOC WITH (NOLOCK) WHERE loc = @cFromLoc AND Facility = @Facility) = 'VAS' AND EXISTS(SELECT 1 FROM dbo.PICKDETAIL WITH (NOLOCK) WHERE id = @cFromID AND sku = @cSKU AND STATUS = 5 AND dropid <> '' AND Storerkey = @cStorerKey) THEN 1 ELSE 0 END

      IF @PNDPICKChk = 1 OR @VASChk = 1
      BEGIN
         SET @cExtendedInfo = 'Move to '+
         (SELECT TOP 1 case when OtherReference LIKE 'DNEDEL%' or OtherReference LIKE 'DNPALN%' THEN OtherReference ELSE 
		 reverse(substring(reverse(OtherReference),4,10)) END FROM dbo.MBOL WITH (NOLOCK) WHERE facility = @Facility 
         AND mbolkey = (SELECT TOP 1 mbolkey FROM dbo.ORDERS WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND orderkey = 
         (SELECT TOP 1 OrderKey FROM dbo.PICKDETAIL WITH (NOLOCK) WHERE Storerkey = @cStorerKey AND id = @cFromID)))
      END
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [RDT].[rdt_511ExtInfoVLT1] TO [NSQL]
GO
