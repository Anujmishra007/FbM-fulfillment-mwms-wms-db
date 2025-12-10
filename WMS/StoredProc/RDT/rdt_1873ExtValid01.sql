
/************************************************************************/
/* Store procedure: rdt_1873ExtValid01                                  */
/* Purpose: for NLRT2                                                   */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author     Purposes                                 */
/* 2025-12-10  1.0  Jackc      FCR-7406 - Created                       */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1873ExtValid01] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cFromID          NVARCHAR( 18),    
   @cToLOC           NVARCHAR( 10),
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR(1024) OUTPUT
)
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @cFacility         NVARCHAR( 5)
   DECLARE @cLocPAZone        NVARCHAR(10)
   DECLARE @fLocWgtCapacity   FLOAT
   DECLARE @fLocWgt           FLOAT
   DECLARE @fPalletWgt        FLOAT
   DECLARE @fSKUWgt           FLOAT
   DECLARE @cbusr3            NVARCHAR(30)
   DECLARE @cLocPltType       NVARCHAR(30)
   DECLARE @cIDPltType        NVARCHAR(30)
   DECLARE @nCount            INT
   DECLARE @cLocAisle         NVARCHAR(10)      
   DECLARE @cLocBay           NVARCHAR(10)         
   DECLARE @nLocLevel         INT     

   DECLARE @tValidPAZone TABLE
   (
      PAZone   NVARCHAR(10)
   )

   SET @nErrNo = 0

   SELECT @cFacility = FACILITY
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nInputKey = 1
   BEGIN
      IF @nStep = 1
      BEGIN     
         IF (SELECT COUNT (DISTINCT SKU)
               FROM dbo.KITDetail WITH (NOLOCK)
               WHERE ID = @cFromID
                  AND Type = 'T'
                  AND Status <> '9') > 1
         BEGIN
            SET @nErrNo = 252951
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Single SKU pallet allowed'
            GOTO Quit
         END

         GOTO Quit  
      END--st1

      IF @nStep = 2
      BEGIN
         INSERT INTO @tValidPAZone
            SELECT 'CS_STAGE'
            UNION ALL
            SELECT 'CS_MEZ_01'
            UNION ALL
            SELECT 'DMG'
            UNION ALL
            SELECT 'CS_MEZ_02'
            UNION ALL
            SELECT 'QUARANTINE'
            UNION ALL
            SELECT 'SH_C'
            UNION ALL
            SELECT 'QC'

         SELECT 
            @cLocPAZone       = ISNULL(PutawayZone,''),
            @fLocWgtCapacity  = ISNULL(WeightCapacity,0),
            @cLocAisle        = ISNULL(LocAisle,''),
            @cLocBay          = ISNULL(LocBay,''),
            @nLocLevel        = ISNULL(LocLevel,'')
         FROM dbo.Loc WITH (NOLOCK)
         WHERE Loc = @cToLOC

         --one pallet one sku
         SELECT 
            @cbusr3 = MAX(SKU.busr3),
            @fPalletWgt = SUM(KTD.ExpectedQty * ISNULL(SKU.STDGROSSWGT, 0)),
            @cIDPltType = MAX(ISNULL(KTD.PalletType,''))
         FROM dbo.KITDetail KTD WITH (NOLOCK)
         JOIN dbo.SKU WITH (NOLOCK)
            ON KTD.StorerKey = SKU.Storerkey
            AND KTD.SKU = SKU.SKU
         WHERE KTD.StorerKey = @cStorerKey
            AND KTD.ID = @cFromID
            AND KTD.Type = 'T'
            AND KTD.Status <> '9'

         IF NOT EXISTS (SELECT 1 
                        FROM dbo.KITDETAIL WITH (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                           AND ID = @cFromID
                           AND Type = 'T'
                           AND Status <> '9')
         BEGIN
            SET @nErrNo = 252955
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'ID not found'
            GOTO Quit
         END
         
         IF NOT EXISTS (SELECT 1 FROM @tValidPAZone WHERE PAZone = @cLocPAZone)
         BEGIN
            IF @cbusr3 NOT IN ('OG', 'STD', 'ALG')
            BEGIN
               SET @nErrNo = 252952
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'SKU.busr3 not valid'
               GOTO Quit
            END
            ELSE
            BEGIN
               IF RIGHT(@cLocPAZone, LEN(@cbusr3)) <> @cbusr3
               BEGIN
                  SET @nErrNo = 252953
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'Invalid PutawayZone'
                  GOTO Quit
               END
            END
         END
         
         SELECT 
            @fLocWgt = SUM(KTD.ExpectedQty * ISNULL(SKU.STDGROSSWGT, 0))
         FROM dbo.KITDetail KTD WITH (NOLOCK)
         JOIN dbo.SKU WITH (NOLOCK)
            ON KTD.StorerKey = SKU.Storerkey
            AND KTD.SKU = SKU.SKU
         WHERE KTD.Loc = @cToLOC
         AND KTD.Type = 'T'
         AND KTD.Status <> '9'

         IF @fPalletWgt + @fLocWgt > @fLocWgtCapacity AND @fLocWgtCapacity > 0
         BEGIN
            SET @nErrNo = 252954
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'Exceed Wgt capacity'
            GOTO Quit
         END

         IF @cIDPltType = ''
         BEGIN
            SET @nErrNo = 252956
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'Pallet type empty '
            GOTO Quit
         END

         SELECT @cLocPltType = ISNULL(PalletType, '')
         FROM dbo.KITDetail KTD WITH (NOLOCK)
         JOIN dbo.LOC WITH (NOLOCK)
            ON KTD.Loc = LOC.Loc
         WHERE KTD.Type = 'T'
            AND KTD.Status <> '9'
            AND LOC.PutawayZone = @cLocPAZone
            AND LOC.LocAisle = @cLocAisle  
            AND LOC.LocBay = @cLocBay
            AND LOC.LocLevel = @nLocLevel

         IF @@ROWCOUNT > 0
         BEGIN
            IF @cIDPltType <> @cLocPltType
            BEGIN
               SET @nErrNo = 252957
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 'Inconsistent pallet type '
               GOTO Quit
            END
         END

     
      END -- st2
   END--inputkey=1

   QUIT:
END
GO

GRANT EXECUTE ON [RDT].[rdt_1873ExtValid01] TO NSQL  
GO 
