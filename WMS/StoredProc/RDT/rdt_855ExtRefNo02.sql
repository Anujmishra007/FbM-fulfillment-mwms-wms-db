SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_855ExtRefNo02                                   */
/* Purpose: For Levis                                                   */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author   Purposes                                  */
/* 2025-08-04 1.0.0  Jackc    FCR-5413 Created (copy from Extref01)     */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_855ExtRefNo02] (
   @nMobile        INT, 
   @nFunc          INT, 
   @cLangCode      NVARCHAR( 3),  
   @nStep          INT,           
   @cStorer        NVARCHAR( 15), 
   @cFacility      NVARCHAR( 5),  
   @cRefNo         NVARCHAR( 20), 
   @cOrderKey      NVARCHAR( 10), 
   @cDropID        NVARCHAR( 20), 
   @cLoadKey       NVARCHAR( 10), 
   @cPickSlipNo    NVARCHAR( 10), 
   @cID            NVARCHAR( 18),
   @cTaskDetailKey NVARCHAR( 10),
   @cSKU           NVARCHAR( 20),
   @cType          NVARCHAR( 20),
   @nCSKU          INT =0 OUTPUT ,
   @nCQTY          INT =0 OUTPUT ,
   @nPSKU          INT =0 OUTPUT, 
   @nPQTY          INT =0 OUTPUT, 
   @nVariance      INT =0 OUTPUT,
   @nQTY_PPA       INT =0 OUTPUT,
   @nQTY_CHK       INT =0 OUTPUT,
   @nRowRef        INT = 0 OUTPUT,
   @nErrNo         INT           OUTPUT, 
   @cErrMsg        NVARCHAR( 20) OUTPUT
) 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE
      @cSQL             NVARCHAR(1000),
      @cSQLParam        NVARCHAR(1000)

   DECLARE
      @nPQTY_Total         INT,
      @nCQTY_Total         INT,
      @cConvertQTYSP       NVARCHAR( 20),
      @cPreCartonization   NVARCHAR( 1)

   DECLARE
      @nP_QTY           INT,
      @nC_QTY           INT,
      @cP_SKU           NVARCHAR( 20),
      @cC_SKU           NVARCHAR( 20)

   IF @nDebugFlag = 1
      SELECT 'Executing 855ExtRefNo02', @cDropID AS DropID, @cSKU AS SKU, @cStep AS Step

   SELECT @cLangCode=lang_code,
          @nStep     = step
   FROM RDT.RDTMOBREC (NOLOCK)
   WHERE mobile=@nMobile

   IF @nVariance IS NOT NULL
   BEGIN
      DECLARE @tP TABLE (StorerKey NVARCHAR( 15), SKU NVARCHAR(20), QTY INT)
      DECLARE @tC TABLE (StorerKey NVARCHAR( 15), SKU NVARCHAR(20), QTY INT)
   END

   -- Get storer configure
   --SET @cPreCartonization = rdt.RDTGetConfig( @nFunc, 'PreCartonization', @cStorer)
   SET @cConvertQTYSP = rdt.RDTGetConfig( @nFunc, 'ConvertQTYSP', @cStorer)
   IF @cConvertQTYSP = '0'
      SET @cConvertQTYSP = ''
   SET @nPQTY = 0
   SET @nCQTY = 0
   IF @nFunc = 855 -- PPA by labelno
   BEGIN
      --GET PPA DETAILS
      SELECT TOP 1
         @nQTY_PPA = PQTY,
         @nQTY_CHK = CQTY,
         @nRowRef = RowRef
      FROM rdt.rdtPPA WITH (NOLOCK)
      WHERE SKU = @cSKU
         AND StorerKey = @cStorer
         AND DropID = @cDropID
      IF @nRowRef IS NULL
      BEGIN
         SELECT @nQTY_PPA = SUM(Qty)
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE DropID = @cDropID
            AND StorerKey = @cStorer
            AND SKU = @cSKU
      END

      IF @cDropID <> '' AND @cDropID IS NOT NULL
      BEGIN
         IF @nPSKU IS NOT NULL
            SELECT @nPSKU = COUNT( DISTINCT SKU)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorer
               AND DropID = @cDropID
               AND ShipFlag <> 'Y'

         IF @nPQTY IS NOT NULL
         BEGIN
            SELECT @nPQTY = SUM(QTY)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorer
               AND DropID = @cDropID
               AND ShipFlag <>'Y'
         END

         IF @nVariance IS NOT NULL
            INSERT INTO @tP (StorerKey, SKU, QTY)
            SELECT StorerKey, SKU, ISNULL( SUM(QTY), 0)
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE StorerKey = @cStorer
               AND DropID = @cDropID
               AND ShipFlag <> 'Y'
            GROUP BY StorerKey, SKU
      END

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Picked DropID Info', @cDropID AS DropID, @nPSKU AS PickedSKU, @nPQTY AS PickedQty
         SELECT '@tP list'
         SELECT * FROM @tP
         SELECT 'Picked SKU Info', @cDropID AS DropID, @cSKU AS SKU, @nQTY_PPA AS PickedQty
      END


      IF @nCSKU IS NOT NULL
         SELECT
            @nCSKU = COUNT( DISTINCT SKU)
         FROM rdt.rdtPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID

      IF @nCQTY IS NOT NULL
      BEGIN
         SELECT
            @nCQTY = SUM( CQTY)
         FROM rdt.rdtPPA WITH (NOLOCK)
         WHERE StorerKey = @cStorer
            AND DropID = @cDropID
         

         IF @nVariance IS NOT NULL
            INSERT INTO @tC (StorerKey, SKU, QTY)
            SELECT StorerKey, SKU, ISNULL( SUM( CQTY), 0)
            FROM rdt.rdtPPA WITH (NOLOCK)
            WHERE StorerKey = @cStorer
               AND DropID = @cDropID
            GROUP BY StorerKey, SKU
      END

      IF @nDebugFlag = 1
      BEGIN
         SELECT 'Checked DropID Info', @cDropID AS DropID, @nCSKU AS CheckedSKU, @nCQTY AS CheckedQty
         SELECT '@tC list'
         SELECT * FROM @tC
         SELECT 'Checked SKU Info', @cDropID AS DropID, @cSKU AS SKU, ISNULL(@nQTY_CHK,0) AS PickedQty
      END
      -- SUM() might return NULL when no record
      SET @nCQTY = IsNULL( @nCQTY, 0)
      SET @nPQTY = IsNULL( @nPQTY, 0)

      -- Get variance
      IF @nVariance IS NOT NULL
      BEGIN
         IF EXISTS( SELECT TOP 1 1
            FROM @tP P
               FULL OUTER JOIN @tC C ON (P.SKU = C.SKU)
            WHERE P.SKU IS NULL
               OR C.SKU IS NULL
               OR P.QTY <> C.QTY)
            SET @nVariance = 1
         ELSE
            SET @nVariance = 0
      END

      IF @nDebugFlag = 1
         SELECT 'VarianceFlag', @nVariance
   END--855

Quit:

END
 
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON  [RDT].[rdt_855ExtRefNo02] TO [NSQL]
GO
