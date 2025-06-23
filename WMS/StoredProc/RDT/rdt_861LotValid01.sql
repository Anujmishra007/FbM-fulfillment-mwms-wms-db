SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/**************************************************************************/
/* Store procedure: rdt_861LotValid01                                    */
/* Copyright      : Maersk WMS                                            */
/* Customer       : PMI                                                   */
/*                                                                        */
/* Date       Rev    Author  Purposes                                     */
/* 2025-02-24 1.0.0  NLT013  FCR-2519 Create                              */
/* 2025-03-11 1.0.1  CYU027  FCR-2519 Lottable 1-15                       */
/**************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_861LotValid01 (
    @nMobile               INT
   ,@nFunc                 INT
   ,@cLangCode             NVARCHAR(  3)
   ,@cStorerKey            NVARCHAR( 15)
   ,@cFacility             NVARCHAR(  5)
   ,@nStep                 INT
   ,@nInputKey             INT
   ,@cPickSlipNo           NVARCHAR( 10)
   ,@cDropID               NVARCHAR( 18)
   ,@cLOC                  NVARCHAR( 10)
   ,@cID                   NVARCHAR( 18)
   ,@cSKU                  NVARCHAR( 20)
   ,@cUOM                  NVARCHAR( 10)
   ,@cUCC                  NVARCHAR( 20)
   ,@cLottable1            NVARCHAR( 18)
   ,@cLottable2            NVARCHAR( 18)
   ,@cLottable3            NVARCHAR( 18)
   ,@dLottable4            DATETIME
   ,@tValidationData       VariableTable READONLY
   ,@nErrNo                INT           OUTPUT   
   ,@cErrMsg               NVARCHAR( 50) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE   @cMatchUCCLottable      NVARCHAR(20)
            ,@cUCCLottable1         NVARCHAR( 18)     ,@cUCCLottable2         NVARCHAR( 18)     ,@cUCCLottable3         NVARCHAR( 18)
            ,@dUCCLottable4         DATETIME          ,@dUCCLottable5         DATETIME          ,@cUCCLottable6         NVARCHAR( 30)
            ,@cUCCLottable7         NVARCHAR( 30)     ,@cUCCLottable8         NVARCHAR( 30)     ,@cUCCLottable9         NVARCHAR( 30)
            ,@cUCCLottable10        NVARCHAR( 30)     ,@cUCCLottable11        NVARCHAR( 30)     ,@cUCCLottable12        NVARCHAR( 30)
            ,@dUCCLottable13        DATETIME          ,@dUCCLottable14        DATETIME          ,@dUCCLottable15        DATETIME

            ,@dLottable5            DATETIME          ,@cLottable6            NVARCHAR( 30)
            ,@cLottable7            NVARCHAR( 30)     ,@cLottable8            NVARCHAR( 30)     ,@cLottable9            NVARCHAR( 30)
            ,@cLottable10           NVARCHAR( 30)     ,@cLottable11           NVARCHAR( 30)     ,@cLottable12           NVARCHAR( 30)
            ,@dLottable13           DATETIME          ,@dLottable14           DATETIME          ,@dLottable15           DATETIME

   SET @nErrNo = 0
   SET @cErrMsg = ''

   IF @nFunc = 861
   BEGIN
      DECLARE @tLottableList TABLE
      (
         LottableNo     NVARCHAR(5)
      )
      SET @cMatchUCCLottable = rdt.rdtGetConfig( @nFunc, 'MATCHUCCLOTTABLE', @cStorerKey)
      
      INSERT INTO @tLottableList ( LottableNo) 
      SELECT VALUE FROM STRING_SPLIT(@cMatchUCCLottable, ',')

      IF EXISTS(SELECT 1 FROM @tLottableList WHERE LottableNo IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15'))
      BEGIN

         --Original Lottables
         SELECT top 1
            @cLottable1  = ISNULL(LA.Lottable01,''),
            @cLottable2  = ISNULL(LA.Lottable02,''),
            @cLottable3  = ISNULL(LA.Lottable03,''),
            @dLottable4  = LA.Lottable04,
            @dLottable5  = LA.Lottable05,
            @cLottable6  = ISNULL(LA.Lottable06,''),
            @cLottable7  = ISNULL(LA.Lottable07,''),
            @cLottable8  = ISNULL(LA.Lottable08,''),
            @cLottable9  = ISNULL(LA.Lottable09,''),
            @cLottable10 = ISNULL(LA.Lottable10,''),
            @cLottable11 = ISNULL(LA.Lottable11,''),
            @cLottable12 = ISNULL(LA.Lottable12,''),
            @dLottable13 = LA.Lottable13,
            @dLottable14 = LA.Lottable14,
            @dLottable15 = LA.Lottable15
         FROM dbo.PickHeader PH (NOLOCK)
                 INNER JOIN dbo.PickDetail PD (NOLOCK) ON (PH.OrderKey = PD.OrderKey)
                 INNER JOIN dbo.LotAttribute LA (NOLOCK) ON (PD.LOT = LA.LOT)
         WHERE PH.PickHeaderKey = @cPickSlipNo
           AND PD.Status < '5' -- Not yet picked
           AND PD.LOC = @cLOC
           AND PD.ID = @cID
           AND PD.SKU = @cSKU
           AND PD.UOM = @cUOM
           AND LA.Lottable01 = @cLottable1
           AND LA.Lottable02 = @cLottable2
           AND LA.Lottable03 = @cLottable3
           AND IsNULL( @dLottable4, 0) = IsNULL( LA.Lottable04, 0)

         --UCC Lottables
         SELECT top 1
            @cUCCLottable1  = ISNULL(LA.Lottable01,''),
            @cUCCLottable2  = ISNULL(LA.Lottable02,''),
            @cUCCLottable3  = ISNULL(LA.Lottable03,''),
            @dUCCLottable4  = LA.Lottable04,
            @dUCCLottable5  = LA.Lottable05,
            @cUCCLottable6  = ISNULL(LA.Lottable06,''),
            @cUCCLottable7  = ISNULL(LA.Lottable07,''),
            @cUCCLottable8  = ISNULL(LA.Lottable08,''),
            @cUCCLottable9  = ISNULL(LA.Lottable09,''),
            @cUCCLottable10 = ISNULL(LA.Lottable10,''),
            @cUCCLottable11 = ISNULL(LA.Lottable11,''),
            @cUCCLottable12 = ISNULL(LA.Lottable12,''),
            @dUCCLottable13 = LA.Lottable13,
            @dUCCLottable14 = LA.Lottable14,
            @dUCCLottable14 = LA.Lottable15
         FROM dbo.UCC UCC WITH (NOLOCK)
                 INNER JOIN dbo.LotAttribute LA WITH (NOLOCK) ON (UCC.Lot = LA.LOT)
         WHERE UCC.UCCNo = @cUCC
           AND UCC.StorerKey = @cStorerKey
           AND UCC.Status = '1' -- Received

         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '01')
         BEGIN
            IF @cUCCLottable1 <> @cLottable1
            BEGIN
               SET @nErrNo = 233751
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233751 Diff Lottable01
               GOTO Fail
            END
         END
         
         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '02')
         BEGIN
            IF @cUCCLottable2 <> @cLottable2
            BEGIN
               SET @nErrNo = 233752
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233752 Diff Lottable02
               GOTO Fail
            END
         END

         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '03')
         BEGIN
            IF @cUCCLottable3 <> @cLottable3
            BEGIN
               SET @nErrNo = 233753
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233753 Diff Lottable03
               GOTO Fail
            END
         END

         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '04')
         BEGIN
            IF IsNULL(@dUCCLottable4, 0) <> IsNULL(@dLottable4, 0)
            BEGIN
               SET @nErrNo = 233754
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233754 Diff Lottable04
               GOTO Fail
            END
         END

         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '05')
         BEGIN
            IF IsNULL(@dUCCLottable5, 0) <> IsNULL(@dLottable5, 0)
            BEGIN
               SET @nErrNo = 233755
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233755 Diff Lottable05
               GOTO Fail
            END
         END


         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '06')
         BEGIN
            IF IsNULL(@cUCCLottable6, 0) <> IsNULL(@cLottable6, 0)
            BEGIN
               SET @nErrNo = 233756
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233756 Diff Lottable06
               GOTO Fail
            END
         END


         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '07')
         BEGIN
            IF IsNULL(@cUCCLottable7, 0) <> IsNULL(@cLottable7, 0)
            BEGIN
               SET @nErrNo = 233757
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233757 Diff Lottable07
               GOTO Fail
            END
         END


         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '08')
         BEGIN
            IF IsNULL(@cUCCLottable8, 0) <> IsNULL(@cLottable8, 0)
            BEGIN
               SET @nErrNo = 233758
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233758 Diff Lottable08
               GOTO Fail
            END
         END


         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '09')
         BEGIN
            IF IsNULL(@cUCCLottable9, 0) <> IsNULL(@cLottable9, 0)
            BEGIN
               SET @nErrNo = 233759
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233759 Diff Lottable09
               GOTO Fail
            END
         END


         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '10')
         BEGIN
            IF IsNULL(@cUCCLottable10, 0) <> IsNULL(@cLottable10, 0)
            BEGIN
               SET @nErrNo = 233760
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233760 Diff Lottable10
               GOTO Fail
            END
         END


         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '11')
         BEGIN
            IF IsNULL(@cUCCLottable11, 0) <> IsNULL(@cLottable11, 0)
            BEGIN
               SET @nErrNo = 233761
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233761 Diff Lottable11
               GOTO Fail
            END
         END


      IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '12')
         BEGIN
            IF IsNULL(@cUCCLottable12, 0) <> IsNULL(@cLottable12, 0)
            BEGIN
               SET @nErrNo = 233762
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233762 Diff Lottable12
               GOTO Fail
            END
         END


         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '13')
         BEGIN
            IF IsNULL(@dUCCLottable13, 0) <> IsNULL(@dLottable13, 0)
            BEGIN
               SET @nErrNo = 233763
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233764 Diff Lottable13
               GOTO Fail
            END
         END

         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '14')
         BEGIN
            IF IsNULL(@dUCCLottable14, 0) <> IsNULL(@dLottable14, 0)
            BEGIN
               SET @nErrNo = 233764
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233764 Diff Lottable14
               GOTO Fail
            END
         END

         IF EXISTS(SELECT 1 FROM @tLottableList WHERE TRIM(LottableNo) = '15')
         BEGIN
            IF IsNULL(@dUCCLottable15, 0) <> IsNULL(@dLottable15, 0)
            BEGIN
               SET @nErrNo = 233765
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --233765 Diff Lottable13
               GOTO Fail
            END
         END



      END
   END

END
Fail:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_861LotValid01 TO NSQL
GO
