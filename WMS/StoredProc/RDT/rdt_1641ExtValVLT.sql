

/*****************************************************************************/
/* Store procedure: rdt_1641ExtValVLT                                        */
/*                                                                           */
/*                                                                           */
/* Date         Rev   Author   Purposes                                      */
/* 02/09/2024   1.0   PPA374   Checks that label is printed for the DropID   */
/* 12/12/2024   2.0   PPA374   Update pickdetail ID and packdetail DropID    */
/*****************************************************************************/

CREATE OR ALTER     PROCEDURE [RDT].[rdt_1641ExtValVLT] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cStorerKey    NVARCHAR( 15),
   @cDropID       NVARCHAR( 20),
   @cUCCNo        NVARCHAR( 20),
   @cPrevLoadKey  NVARCHAR( 10),
   @cParam1       NVARCHAR(20),
   @cParam2       NVARCHAR(20),
   @cParam3       NVARCHAR(20),
   @cParam4       NVARCHAR(20),
   @cParam5       NVARCHAR(20),
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF (SELECT TOP 1 UserDefine10 FROM dbo.ORDERS WITH(NOLOCK) WHERE OrderKey = (SELECT TOP 1 OrderKey FROM dbo.PICKHEADER WITH(NOLOCK) WHERE PickHeaderKey = (SELECT TOP 1 PickSlipNo FROM dbo.PackDetail WITH(NOLOCK) WHERE Dropid = @cDropID))) IN ('Non-Parcel','')
   BEGIN
      GOTO NonParcelOrder
   END

   IF @nStep = 1 AND @nInputKey = 1
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH(NOLOCK) WHERE DROPID = @cDropID AND StorerKey = @cstorerkey)
         AND EXISTS (SELECT 1 FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE DROPID = @cDropID AND Storerkey = @cstorerkey)
      BEGIN
         SET @nErrNo = 218047
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Not packed pallet ID'
         GOTO Quit
      END

      IF EXISTS(SELECT 1 FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID AND DropIDType = '0')
      BEGIN
         SET @nErrNo = 218021
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'DropID is a child ID'
         GOTO Quit
      END

      ELSE IF LEFT(@cDropID,3) <> '050' OR LEN(@cDropID) <> 18
      BEGIN
         SET @nErrNo = 218048
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Wrong DROPID format'
         GOTO Quit
      END
      GOTO QUIT
   END

   IF @nStep = 3 AND @nInputKey = 1
   BEGIN
      IF @cDropID = @cUCCNo
      BEGIN
         SET @nErrNo = 218049
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Same as DropID'
         GOTO QUIT
      END

      ELSE IF (SELECT TOP 1 UserDefine10 FROM dbo.ORDERS WITH(NOLOCK) WHERE OrderKey = (SELECT TOP 1 OrderKey FROM dbo.PICKHEADER WITH(NOLOCK) WHERE PickHeaderKey = (SELECT TOP 1 PickSlipNo FROM dbo.PackDetail WITH(NOLOCK) WHERE Dropid = @cUCCNo))) IN ('Non-Parcel','')
      BEGIN
         SET @nErrNo = 218022
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Non-parcel order ID'
         GOTO QUIT
      END

      ELSE IF (SELECT TOP 1 Loadkey FROM dbo.Dropid  WITH(NOLOCK) WHERE Dropid = @cUCCNo) <> (SELECT TOP 1 Loadkey FROM dbo.Dropid  WITH(NOLOCK) WHERE Dropid = @cDropID)
         AND (SELECT TOP 1 Loadkey FROM dbo.Dropid  WITH(NOLOCK) WHERE Dropid = @cDropID) <> ''
      BEGIN
         SET @nErrNo = 218023
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Cannot mix load IDs'
         GOTO QUIT
      END

      ELSE IF (SELECT TOP 1 MBOLKey FROM dbo.ORDERS  WITH(NOLOCK) WHERE orderkey = (SELECT TOP 1 OrderKey FROM dbo.PICKHEADER WITH(NOLOCK) WHERE PickHeaderKey = (SELECT TOP 1 PickSlipNo FROM dbo.PackDetail  WITH(NOLOCK) WHERE Dropid = @cUCCNo)))
                 <> (SELECT TOP 1 UDF01 FROM dbo.Dropid  WITH(NOLOCK) WHERE Dropid = @cDropID)
      AND (SELECT TOP 1 UDF01 FROM dbo.Dropid  WITH(NOLOCK) WHERE Dropid = @cDropID) <> ''
      BEGIN
         SET @nErrNo = 218024
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Cannot mix shipments'
         GOTO QUIT
      END

      ELSE IF (SELECT TOP 1 Status FROM dbo.Dropid  WITH(NOLOCK) WHERE Dropid = @cUCCNo) = '9'
      BEGIN
         SET @nErrNo = 218025
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Drop ID is loaded'
         GOTO QUIT
      END

      ELSE IF (SELECT TOP 1 LabelPrinted FROM dbo.Dropid  WITH(NOLOCK) WHERE Dropid = @cUCCNo) = 'N'
      BEGIN
         SET @nErrNo = 218026
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Label is not printed'
         GOTO QUIT
      END

      ELSE IF LEFT(@cUCCNo,3) <> '050' OR LEN(@cUCCNo) <> 18
      BEGIN
         SET @nErrNo = 218050
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Wrong DROPID format'
         GOTO QUIT
      END
      GOTO Quit
   END

   GOTO QUIT

   NonParcelOrder:

   DECLARE
      @OrderKey  NVARCHAR(15),
      @WeightCap NVARCHAR(10),
      @CubeCap   NVARCHAR(10),
      @Storer    NVARCHAR(20)

   set @OrderKey = (SELECT TOP 1 OrderKey FROM dbo.PICKHEADER WITH(NOLOCK) WHERE PickHeaderKey = (SELECT TOP 1 PickSlipNo FROM dbo.PackDetail WITH(NOLOCK) WHERE Dropid = @cDropID))
   set @Storer = (SELECT TOP 1 StorerKey FROM dbo.STORER S WITH(NOLOCK) WHERE EXISTS (SELECT 1 FROM dbo.ORDERS O WITH(NOLOCK) WHERE OrderKey = @OrderKey AND S.Address1 = O.ConsigneeKey AND S.Zip = O.C_Zip))
   set @WeightCap = (SELECT TOP 1 SUSR3 FROM dbo.STORER WITH(NOLOCK) WHERE StorerKey = @Storer)
   set @CubeCap = (SELECT TOP 1 SUSR1 FROM dbo.STORER WITH(NOLOCK) WHERE StorerKey = @Storer)

   IF @nStep = 1 AND @nInputKey = 1
   BEGIN
      IF (SELECT TOP 1 LabelPrinted FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) = 'Y'
         BEGIN
            SET @nErrNo = 218051
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Label is printed'
            GOTO Quit
         END

      IF (EXISTS (SELECT 1 FROM dbo.STORER S WITH(NOLOCK) WHERE pallet <> 'CHEP'
                                                            AND StorerKey = @Storer)
         OR EXISTS (SELECT 1 FROM dbo.STORER S WITH(NOLOCK) WHERE ISNULL(SUSR2,'') NOT IN ('','0')
                                                              AND StorerKey = @Storer))
         BEGIN
            SET @nErrNo = 218052
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Can''t consol storer'
            GOTO Quit
         END

      IF EXISTS (SELECT 1 FROM dbo.DropidDetail WITH(NOLOCK) WHERE ChildId = @cDropID)
         BEGIN
            SET @nErrNo = 218053
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Child of another ID'
            GOTO Quit
         END

      IF (SELECT TOP 1 UserDefine10 FROM dbo.ORDERS WITH(NOLOCK) WHERE orderkey = @OrderKey) IN ('Non-Parcel','')
         BEGIN
            UPDATE dbo.Dropid WITH(ROWLOCK)
            set UDF02 = @OrderKey
            WHERE Dropid = @cDropID AND UDF02 = ''
         END
   END

   IF @nStep = 3 AND @nInputKey = 1
   BEGIN
      IF @cDropID = @cUCCNo
      BEGIN
         SET @nErrNo = 218054
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Same as DropID'
         GOTO Quit
      END

      IF (SELECT TOP 1 LabelPrinted FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cUCCNo) = 'Y'
      BEGIN
         SET @nErrNo = 218055
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Label is printed'
         GOTO Quit
      END

      IF EXISTS (SELECT 1 FROM dbo.DropidDetail WITH(NOLOCK) WHERE ChildId = @cUCCNo)
      BEGIN
         SET @nErrNo = 218056
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'ID already scanned'
         GOTO Quit
      END

      IF (SELECT TOP 1 Loadkey FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <>
         (SELECT TOP 1 Loadkey FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cUCCNo)
      BEGIN
         SET @nErrNo = 218057
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Cannot mix loads'
         GOTO Quit
      END

      IF (SELECT TOP 1 UDF02 FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID) <>
         (SELECT TOP 1 orderkey FROM dbo.PICKHEADER WITH(NOLOCK) WHERE PickHeaderKey = (SELECT TOP 1 PickSlipNo FROM dbo.PackDetail  WITH(NOLOCK) WHERE Dropid = @cUCCNo))
      BEGIN
         SET @nErrNo = 218058
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--Cannot mix orders
         GOTO Quit
      END

      IF EXISTS (SELECT 1 FROM dbo.STORER S  WITH(NOLOCK)
                  WHERE StorerKey = @Storer
                    AND ISNULL(creditlimit,0) <> 0
                    AND creditlimit < (
            SELECT count(distinct sku) FROM dbo.PackDetail  WITH(NOLOCK)
            WHERE Dropid IN (@cDropID,@cUCCNo)
               OR dropid IN (SELECT ChildId FROM dbo.DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID)
           ))
      BEGIN
         SET @nErrNo = 218059
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Over pal SKU limit'
         GOTO Quit
      END

      IF EXISTS (SELECT 1 FROM dbo.STORER S WITH(NOLOCK) WHERE ISNULL(SUSR4,'') <> 'N' AND 1 <(
         SELECT count (distinct Style) FROM dbo.SKU WITH(NOLOCK)
         WHERE EXISTS (SELECT 1 FROM dbo.PackDetail PD WITH(NOLOCK) WHERE SKU.sku = PD.sku
            AND (dropid IN (@cDropID,@cUCCNo) OR dropid IN (
            SELECT ChildId FROM dbo.DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID))))
            AND StorerKey = @Storer)
         BEGIN
            SET @nErrNo = 218060
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Over pal brand limit'
            GOTO Quit
         END

      IF ISNUMERIC(@WeightCap) = 1
      BEGIN
         IF CAST(@WeightCap AS FLOAT)*10 > 0 AND CAST(@WeightCap AS FLOAT) *10 <(
            SELECT SUM(stdgrosswgt * PD.qty)*10 TotalWeight
            FROM dbo.SKU S  WITH(NOLOCK)
               INNER JOIN dbo.PackDetail PD  WITH(NOLOCK) ON S.Sku = PD.SKU
            WHERE S.storerkey = @cStorerKey
             AND (dropid IN (@cDropID, @cUCCNo)
              OR dropid IN (SELECT childid FROM dbo.DropidDetail  WITH(NOLOCK) WHERE Dropid = @cDropID)))
            BEGIN
               SET @nErrNo = 218061
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Over pal weight cap'
               GOTO Quit
            END
      END

      IF ISNUMERIC(@CubeCap) = 1
      BEGIN
         IF CAST(@CubeCap AS FLOAT)*10 > 0 AND CAST(@CubeCap AS FLOAT) *10 <
           (SELECT SUM(HeightUOM3 * LengthUOM3 * WidthUOM3 * PD.qty)*10 TotalCube
            FROM dbo.SKU S  WITH(NOLOCK)
                    INNER JOIN dbo.PackDetail PD  WITH(NOLOCK)
                               ON S.Sku = PD.SKU
                    INNER JOIN PACK P  WITH(NOLOCK)
                               ON P.PackKey = S.PACKKey
            WHERE S.storerkey = @cStorerKey
              AND (dropid IN (@cDropID, @cUCCNo)
               OR dropid IN (SELECT ChildId FROM dbo.DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID)))
            BEGIN
               SET @nErrNo = 218062
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--'Over pal cube limit'
               GOTO Quit
            END
      END

      IF (SELECT TOP 1 LOC FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE Dropid = @cDropID) <>
         (SELECT TOP 1 LOC FROM dbo.PICKDETAIL WITH(NOLOCK) WHERE Dropid = @cUCCNo)
      BEGIN
         SET @nErrNo = 218063
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')--DropIDs IN diff locs
         GOTO Quit
      END
   END

Quit:
END

GRANT EXECUTE ON [RDT].[rdt_1641ExtValVLT] TO [NSQL]
GO

