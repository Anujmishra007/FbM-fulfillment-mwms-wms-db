SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store procedure: isp_838GenLabelNo05                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev Author      Purposes                                  */
/* 2026-04-01 1.0  Dennis     FCR-11611 Created                         */
/*                            Generate SSCC LabelNo for B2B orders      */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_838GenLabelNo05] (
   @cPickslipNo NVARCHAR(10),
   @nCartonNo   INT,
   @cLabelNo    NVARCHAR(20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @bSuccess    INT
   DECLARE @nErrNo      INT
   DECLARE @cErrMsg     NVARCHAR(250)
   DECLARE @cStorerKey  NVARCHAR(20)
   DECLARE @cOrderKey   NVARCHAR(10)
   DECLARE @cType    NVARCHAR(10)
   DECLARE @cOption     NVARCHAR(1)
   DECLARE @nMobile     INT
   DECLARE @cLangCode   NVARCHAR(20) = 'ENG'

   DECLARE @cGS1Prefix  NVARCHAR(10)
   DECLARE @cCode2      NVARCHAR(10)
   DECLARE @cUDF01      NVARCHAR(10)
   DECLARE @cUDF02      NVARCHAR(10)
   DECLARE @nSeqLength  INT
   DECLARE @nNextSeq    BIGINT

   -- Get StorerKey and OrderKey from PackHeader
   SELECT TOP 1
      @cStorerKey = PH.StorerKey,
      @cOrderKey = PH.OrderKey
   FROM PackHeader PH WITH (NOLOCK)
   WHERE PH.PickSlipNo = @cPickslipNo

   -- If OrderKey is empty, return error
   IF ISNULL(@cOrderKey, '') = ''
   BEGIN
      SET @nErrNo = 180071
      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- OrderNotFound
      GOTO Quit
   END

   -- Get DocType from Orders
   SELECT @cType = Type
   FROM Orders WITH (NOLOCK)
   WHERE OrderKey = @cOrderKey

   IF EXISTS (SELECT 1
   FROM CODELKUP WITH (NOLOCK)
   WHERE ListName = 'GENSSCC'
   AND Storerkey = @cStorerKey
   AND UDF03 = @cType
   AND UDF03 <> ''
   )
   AND @cType IN ('B2B','B2C')
   BEGIN
      DECLARE @cAutoID NVARCHAR(18)
      DECLARE @tExtData VariableTable
      BEGIN
         DECLARE   @nCounterKey       NVARCHAR(18)
                  ,@cNCounter         NVARCHAR(9)
                  ,@nSequenceLen      INT
                  ,@dMinSequence      INT
                  ,@dMaxSequence      INT
                  ,@cAppId            NVARCHAR(2)

                  /******************** SSCC generation patterns ********************/
                  /**   E PPPPPPP RRRRRRRRR C       */
                  /** Fixed 00 */
                  ,@nCompanyPrefix        NVARCHAR (10)
                  /** 1 Extension digit (0-9) +  7 or 9 digit GS1 company Prefix */
                  ,@nSerialRef            NVARCHAR (9)
                  ,@nCheckDigit           NVARCHAR (1)
                  /******************************************************************/

         SELECT TOP 1
            @nCompanyPrefix = ISNULL(code,''),
            @nSequenceLen = convert(INT,code2),
            @dMinSequence = convert(INT,UDF01),
            @dMaxSequence = convert(INT,UDF02),
            @cAppId = LEFT(TRIM(ISNULL(UDF04,'')),2)
         FROM CODELKUP WITH (NOLOCK)
         WHERE ListName = 'GENSSCC'
         AND Storerkey = @cStorerKey
         AND UDF03 = @cType
         AND UDF03 <> ''

         IF @@ROWCOUNT <> 1
         BEGIN
            SET @nErrNo = 218501
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Setup CodeLKUP
            GOTO Quit
         END

         IF ( @nSequenceLen IS NULL OR @nSequenceLen NOT IN (7,9))
            BEGIN
               SET @nErrNo = 218502
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidCode2Value
               GOTO Quit
            END

         IF ( @nCompanyPrefix = '' OR ( LEN(@nCompanyPrefix) <> (17 - @nSequenceLen) ))
         BEGIN
            SET @nErrNo = 218503
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidCodeValue
            GOTO Quit
         END

         IF @dMaxSequence = 0
            SET @dMaxSequence = REPLICATE('9',@nSequenceLen)

         IF (  @dMaxSequence <= @dMinSequence)
         BEGIN
            SET @nErrNo = 218504
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UDF01/UDF02 Error
            GOTO Quit
         END

         SET @nCounterKey = 'SSCC_' + @cStorerKey

         --    First init, set counter start from dMinSequence
         IF NOT EXISTS(
            SELECT 1 FROM nCounter (NOLOCK)
            WHERE KeyName = @nCounterKey
         )
         BEGIN
            INSERT nCounter (KeyName, KeyCount) VALUES (@nCounterKey, @dMinSequence)
         END

         --    IF keycount is smaller than dMinSequence, Reset key
         ELSE IF EXISTS ( SELECT 1 FROM nCounter (NOLOCK)
                     WHERE KeyName = @nCounterKey
                     AND (KeyCount < @dMinSequence OR KeyCount >= @dMaxSequence)
         )
         BEGIN

            UPDATE nCounter WITH (ROWLOCK)
            SET KeyCount = @dMinSequence,
               EditDate = GETDATE()
            WHERE KeyName = @nCounterKey

            IF @@ROWCOUNT = 0
            BEGIN
               SET @nErrNo = 218505
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Reset nCounter failed
               GOTO Quit
            END
         END


         SET @cNCounter = ''
         SET @bSuccess = 1
         EXECUTE dbo.nspg_getkey
               @nCounterKey
               , @nSequenceLen
               , @nSerialRef         OUTPUT
               , @bSuccess          OUTPUT
               , @nErrNo            OUTPUT
               , @cErrMsg           OUTPUT
         IF @bSuccess <> 1
         BEGIN
            SET @nErrNo = 218506
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Getkey Error
            GOTO Quit
         END


         DECLARE @dCurrentDgit numeric(38,0)
         SET @dCurrentDgit = convert( numeric(38,0), @nCompanyPrefix + @nSerialRef)

         EXEC dbo.isp_CheckDigits
            @dCurrentDgit,
            @nCheckDigit OUTPUT


         SET @cAutoID = @nCompanyPrefix + @nSerialRef + @nCheckDigit
      END

      -- Prepend '00' to the SSCC
      SET @cLabelNo = @cAppId + @cAutoID
   END
   ELSE
   BEGIN
      EXEC isp_GenUCCLabelNo
         @cStorerKey,
         @cLabelNo      OUTPUT, 
         @bSuccess      OUTPUT,
         @nErrNo        OUTPUT,
         @cErrMsg       OUTPUT
      IF @nErrNo <> 0
      BEGIN
         SET @nErrNo = 180074
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --GenLabelNoFail
         GOTO QUIT
      END
   END

Quit:

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [dbo].[isp_838GenLabelNo05] TO [NSQL]
GO
