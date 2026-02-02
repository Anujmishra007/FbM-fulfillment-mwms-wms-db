SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/  
/* Store procedure: rdt_SimpleCC_Confirm                                      */  
/* Copyright      : MAERSK                                                    */  
/*                                                                            */  
/* Purpose: Update CCDetail                                                   */  
/*                                                                            */  
/* Called from: rdtfnc_SimpleCC                                               */  
/*                                                                            */  
/* Modifications log:                                                         */  
/*                                                                            */  
/* Date        Rev  Author      Purposes                                      */  
/* 2023-08-23  1.0  James       WMS-23197  Created                            */  
/* 2025-03-07  1.1  James       FCR-2054 Add ExtendedCfmSP (james01)          */
/******************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdt_SimpleCC_Confirm]  
   @nFunc         INT,  
   @nMobile       INT,  
   @cLangCode     NVARCHAR( 3),  
   @cFacility     NVARCHAR( 5),
   @cStorerKey    NVARCHAR( 15),
   @cCCKey        NVARCHAR( 10),
   @cCCSheetNo    NVARCHAR( 10),
   @nCountNo      INT,
   @cLOC          NVARCHAR( 10),            
   @cID           NVARCHAR( 18),
   @cSKU          NVARCHAR( 20),
   @nQty          INT,   
   @cLottable01   NVARCHAR( 18),  
   @cLottable02   NVARCHAR( 18),  
   @cLottable03   NVARCHAR( 18),  
   @dLottable04   DATETIME,  
   @dLottable05   DATETIME,  
   @cLottable06   NVARCHAR( 30),  
   @cLottable07   NVARCHAR( 30),  
   @cLottable08   NVARCHAR( 30),  
   @cLottable09   NVARCHAR( 30),  
   @cLottable10   NVARCHAR( 30),  
   @cLottable11   NVARCHAR( 30),  
   @cLottable12   NVARCHAR( 30),  
   @dLottable13   DATETIME,  
   @dLottable14   DATETIME,  
   @dLottable15   DATETIME,  
   @tCCDtlCfm     VARIABLETABLE READONLY,
   @nErrNo        INT           OUTPUT,  
   @cErrMsg       NVARCHAR( 20) OUTPUT
AS
BEGIN  
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF
  
   DECLARE @cSQL              NVARCHAR( MAX)
   DECLARE @cSQLParam         NVARCHAR( MAX)
   DECLARE @cExtendedCfmSP    NVARCHAR( 20)
   DECLARE @nStep             INT
   DECLARE @nInputKey         INT
   DECLARE @cUserName         NVARCHAR( 18)
   
   SELECT 
      @nStep = Step,
      @nInputKey = InputKey, 
      @cUserName = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cExtendedCfmSP = rdt.RDTGetConfig( @nFunc, 'ExtendedCfmSP', @cStorerKey)
   IF @cExtendedCfmSP NOT IN ('0', '')
   BEGIN
      SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedCfmSP) +
         ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, ' + 
         ' @cCCKey, @cCCSheetNo, @nCountNo, @cLOC, @cID, @cSKU, @nQty, ' +
         ' @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05, ' +
         ' @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10, ' +
         ' @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15, ' +
         ' @tCCDtlCfm, @nErrNo OUTPUT, @cErrMsg OUTPUT '

      SET @cSQLParam =
         '@nMobile            INT,           ' +
         '@nFunc              INT,           ' +
         '@cLangCode          NVARCHAR( 3),  ' +
         '@nStep              INT,           ' +
         '@nInputKey          INT,           ' +
         '@cFacility          NVARCHAR( 10), ' +
         '@cStorerkey         NVARCHAR( 15), ' +
         '@cCCKey             NVARCHAR( 10), ' +
         '@cCCSheetNo         NVARCHAR( 10), ' +
         '@nCountNo           INT,           ' +
         '@cLOC               NVARCHAR( 10), ' +            
         '@cID                NVARCHAR( 18), ' +
         '@cSKU               NVARCHAR( 20), ' +
         '@nQty               INT,           ' +
         '@cLottable01        NVARCHAR( 18), ' +  
         '@cLottable02        NVARCHAR( 18), ' +  
         '@cLottable03        NVARCHAR( 18), ' +  
         '@dLottable04        DATETIME,      ' +  
         '@dLottable05        DATETIME,      ' +
         '@cLottable06        NVARCHAR( 30), ' +  
         '@cLottable07        NVARCHAR( 30), ' +  
         '@cLottable08        NVARCHAR( 30), ' +  
         '@cLottable09        NVARCHAR( 30), ' +  
         '@cLottable10        NVARCHAR( 30), ' +  
         '@cLottable11        NVARCHAR( 30), ' +  
         '@cLottable12        NVARCHAR( 30), ' +  
         '@dLottable13        DATETIME,      ' +  
         '@dLottable14        DATETIME,      ' +  
         '@dLottable15        DATETIME,      ' +  
         '@tCCDtlCfm          VARIABLETABLE READONLY, ' +
         '@nErrNo             INT           OUTPUT,   ' +
         '@cErrMsg            NVARCHAR( 20) OUTPUT    '

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cFacility, @cStorerkey, 
         @cCCKey, @cCCSheetNo, @nCountNo, @cLOC, @cID, @cSKU, @nQty,
         @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
         @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
         @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
         @tCCDtlCfm, @nErrNo OUTPUT, @cErrMsg OUTPUT

      IF @nErrNo <> 0
         GOTO Fail
   END
   ELSE
   BEGIN
      DECLARE @nTranCount        INT  
      DECLARE @bsuccess          INT
      DECLARE @nQTY_PD           INT
      DECLARE @cLottableCode     NVARCHAR( 30)
      DECLARE @cWhere            NVARCHAR( MAX)
      DECLARE @cCCDetailKey      NVARCHAR(10) = ''    
      DECLARE @curCCD            CURSOR  
      DECLARE @debug             INT = 0
      DECLARE @nLottableNo  INT
      DECLARE @cLottableNo  NVARCHAR( 2)
      DECLARE @cLottableVar NVARCHAR( 15)
      DECLARE @cLottableCol NVARCHAR( 15)
      DECLARE @cWhere1     NVARCHAR( MAX)
      DECLARE @cWhere2     NVARCHAR( MAX)
      DECLARE @nRowCount   INT

      SELECT @cLottableCode = LottableCode
      FROM dbo.SKU WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND   Sku = @cSKU
   
      SET @cID = ISNULL( @cID, '')
   
      -- Temp table for lottable
      DECLARE @tLC TABLE
      (
         RowRef      INT           IDENTITY( 1,1),
         LottableNo  INT           NOT NULL,
         Visible     NVARCHAR(  1) NOT NULL,
         Editable    NVARCHAR(  1) NOT NULL,
         Required    NVARCHAR(  1) NOT NULL,
         Sequence    INT           NOT NULL,
         Description NVARCHAR( 20) NOT NULL,
         FormatSP    NVARCHAR( 50) NOT NULL
      )

      SET @cWhere = ''

      IF @cLottableCode = ''
         GOTO Quit

      -- If function specific lottablecode not setup, use generic one
      IF @nFunc > 0
         IF NOT EXISTS( SELECT TOP 1 1
            FROM rdt.rdtLottableCode WITH (NOLOCK)
            WHERE LottableCode = @cLottableCode
               AND Function_ID = @nFunc
               AND StorerKey = @cStorerKey)
            SET @nFunc = 0

      INSERT INTO @tLC (LottableNo, Visible, Editable, Required, Sequence, Description, FormatSP)
      SELECT 
         LottableNo, Visible, Editable, Required, Sequence, Description, FormatSP
      FROM rdt.rdtLottableCode WITH (NOLOCK)
      WHERE LottableCode = @cLottableCode
         AND Function_ID = @nFunc
         AND StorerKey = @cStorerKey
         AND Visible = '1'
      ORDER BY Sequence

      DECLARE @curLC CURSOR
      SET @curLC = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT LottableNo
         FROM @tLC
         ORDER BY Sequence
      OPEN @curLC
      FETCH NEXT FROM @curLC INTO @nLottableNo

      -- Loop lottable display on screen
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Get lottable
         SET @cLottableNo = RIGHT( '0' + CAST( @nLottableNo AS NVARCHAR(2)), 2)
         SET @cLottableCol = 'Lottable' + @cLottableNo
         SET @cLottableVar = CASE WHEN @nLottableNo IN (4, 5, 13, 14, 15) THEN '@d' ELSE '@c' END + 'Lottable' + @cLottableNo

         SET @cLottableCol = @cLottableCol + CASE WHEN @nCountNo = 2 THEN '_CNT2' 
                                                  WHEN @nCountNo = 3 THEN '_CNT3' 
                                                  ELSE '' END

         -- Construct SQL clause
         SET @cWhere = @cWhere + ' AND ' + @cLottableCol + ' = ' + @cLottableVar

         FETCH NEXT FROM @curLC INTO @nLottableNo
      END

      -- Construct remain SQL clause
      IF @cWhere <> ''
         SET @cWhere = SUBSTRING( @cWhere, 5, LEN( @cWhere)) -- Remove leading " AND "
      
      IF @debug = 1      
         SELECT @cWhere '@cWhere'

      -- Open cursor
      SET @cSQL =
         ' SET @curCCD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR ' +  
         ' SELECT CCDetailKey, SystemQty ' +  
         ' FROM dbo.CCDetail WITH (NOLOCK) ' +  
         ' WHERE Storerkey = @cStorerKey ' +   
         ' AND   CCKey = @cCCKey ' +  
         ' AND   LOC = @cLOC ' +
         ' AND   SKU = @cSKU ' +   
         CASE WHEN ISNULL( @cID, '') = '' THEN '' ELSE ' AND   ID = @cID ' END +
         CASE WHEN @cWhere = '' THEN '' ELSE ' AND ' + @cWhere END
      SET @cSQL = @cSQL + ' ORDER BY CCDetailKey'
      SET @cSQL = @cSQL + ' OPEN @curCCD'

      SET @cSQLParam =
         ' @curCCD      CURSOR OUTPUT, ' +
         ' @cStorerKey  NVARCHAR( 15), ' +
         ' @cCCKey      NVARCHAR( 10), ' +
         ' @cLOC        NVARCHAR( 10), ' +
         ' @cID         NVARCHAR( 18), ' +
         ' @cSKU        NVARCHAR( 20), ' +
         ' @cLottable01 NVARCHAR( 18), ' +
         ' @cLottable02 NVARCHAR( 18), ' +
         ' @cLottable03 NVARCHAR( 18), ' +
         ' @dLottable04 DATETIME,      ' +
         ' @dLottable05 DATETIME,      ' +
         ' @cLottable06 NVARCHAR( 30), ' +
         ' @cLottable07 NVARCHAR( 30), ' +
         ' @cLottable08 NVARCHAR( 30), ' +
         ' @cLottable09 NVARCHAR( 30), ' +
         ' @cLottable10 NVARCHAR( 30), ' +
         ' @cLottable11 NVARCHAR( 30), ' +
         ' @cLottable12 NVARCHAR( 30), ' +
         ' @dLottable13 DATETIME,      ' +
         ' @dLottable14 DATETIME,      ' +
         ' @dLottable15 DATETIME       '

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @curCCD OUTPUT, @cStorerKey, @cCCKey, @cLOC, @cID, @cSKU, 
         @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
         @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
         @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15

      IF @debug = 1      
         SELECT @cSQL '@cSQL', @cSQLParam '@cSQLParam'


      SET @nTranCount = @@TRANCOUNT  
  
      BEGIN TRAN  
      SAVE TRAN CycleCountTran  
   
      FETCH NEXT FROM @curCCD INTO @cCCDetailKey, @nQTY_PD  
      WHILE @@FETCH_STATUS = 0    
      BEGIN    
         IF @nQTY_PD = @nQty    
         BEGIN    
            UPDATE dbo.CCDEtail SET  
               Qty      = CASE WHEN @nCountNo = '1' THEN Qty  + @nQty ELSE Qty  END,  
               Qty_Cnt2 = CASE WHEN @nCountNo = '2' THEN Qty_Cnt2 + @nQty ELSE Qty_Cnt2 END,  
               Qty_Cnt3 = CASE WHEN @nCountNo = '3' THEN Qty_Cnt3 + @nQty ELSE Qty_Cnt3 END,  
               Status  = '2',  
               Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END,  
               Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END,  
               Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END
            WHERE CCDetailKey = @cCCDetailKey  
    
            IF @@ERROR <> 0     
            BEGIN    
               SET @nErrNo = 205151  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
               GOTO RollBackTran    
            END    
         END    
         ELSE    
         IF @nQty > @nQTY_PD    
         BEGIN    
            UPDATE dbo.CCDEtail SET  
               Qty      = CASE WHEN @nCountNo = '1' THEN Qty  + @nQTY_PD ELSE Qty  END,  
               Qty_Cnt2 = CASE WHEN @nCountNo = '2' THEN Qty_Cnt2  + @nQTY_PD ELSE Qty_Cnt2 END,  
               Qty_Cnt3 = CASE WHEN @nCountNo = '3' THEN Qty_Cnt3  + @nQTY_PD ELSE Qty_Cnt3 END,  
               Status  = '2',  
               Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END,  
               Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END,  
               Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END  
            WHERE CCDetailKey = @cCCDetailKey  
    
            IF @@ERROR <> 0     
            BEGIN    
               SET @nErrNo = 205152  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
               GOTO RollBackTran    
            END     
         END    
         ELSE    
         IF @nQty < @nQTY_PD AND @nQty > 0    
         BEGIN    
            UPDATE dbo.CCDEtail SET  
               Qty      = CASE WHEN @nCountNo = '1' THEN Qty  + @nQty ELSE Qty  END,  
               Qty_Cnt2 = CASE WHEN @nCountNo = '2' THEN Qty_Cnt2 + @nQty ELSE Qty_Cnt2 END,  
               Qty_Cnt3 = CASE WHEN @nCountNo = '3' THEN Qty_Cnt3 + @nQty ELSE Qty_Cnt3 END,  
               Status  = '2',  
               Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END,  
               Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END,  
               Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END  
            WHERE CCDetailKey = @cCCDetailKey  
    
             IF @@ERROR <> 0     
             BEGIN    
                SET @nErrNo = 205153  
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
                GOTO RollBackTran    
             END     
         END    
         IF @nQty = 0 -- Treat as Counted when Qty = 0 and still have same SKU and Loc not counted.  
         BEGIN  
            UPDATE dbo.CCDEtail SET  
               Status  = '2',  
               Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END,  
               Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END,  
               Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END  
            WHERE CCDetailKey = @cCCDetailKey  
    
            IF @@ERROR <> 0     
            BEGIN    
               SET @nErrNo = 205154  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
               GOTO RollBackTran    
            END     
         END  
    
         SET @nQty = @nQty - @nQTY_PD   
        
         IF @nQty < 0   
         BEGIN  
             SET @nQty = 0   
         END  
    
         FETCH NEXT FROM @curCCD INTO @cCCDetailKey, @nQTY_PD  
      END -- While Loop for PickDetail Key    

     
      IF @nQty > 0 AND @cCCDetailKey <> '' -- Update Remaining Qty to last of the CCDetail line with Same Loc and SKU  
      BEGIN  
         UPDATE dbo.CCDEtail WITH (ROWLOCK)  
         SET Qty      = CASE WHEN @nCountNo = '1' THEN Qty  + @nQty ELSE Qty  END  
         , Qty_Cnt2 = CASE WHEN @nCountNo = '2' THEN Qty_Cnt2 + @nQty ELSE Qty_Cnt2 END  
         , Qty_Cnt3 = CASE WHEN @nCountNo = '3' THEN Qty_Cnt3 + @nQty ELSE Qty_Cnt3 END  
         , Status  = '2'  
         , Counted_Cnt1 = CASE WHEN @nCountNo = '1' THEN '1' ELSE Counted_Cnt1 END  
         , Counted_Cnt2 = CASE WHEN @nCountNo = '2' THEN '1' ELSE Counted_Cnt2 END  
         , Counted_Cnt3 = CASE WHEN @nCountNo = '3' THEN '1' ELSE Counted_Cnt3 END  
         WHERE CCKey = @cCCKey  
         AND CCDetailKey = @cCCDetailKey  
    
         IF @@ERROR <> 0     
         BEGIN    
            SET @nErrNo = 205155  
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --UPD CCDtl Fail  
            GOTO RollBackTran    
         END      
      END  
  
		SET @cSQL = ''
		SET @cSQLParam =''
		SET @nRowCount = 0

		SET @cSQL = ' SELECT 1 ' + 
		            ' FROM CCDetail WITH (NOLOCK) ' + 
		            ' WHERE CCKey = @cCCKey ' +  
		            ' AND   Storerkey = @cStorerKey ' + 
		            ' AND   SKU = @cSKU ' +  
		            ' AND   LOC = @cLOC ' + 
                  CASE WHEN ISNULL( @cID, '') = '' THEN '' ELSE ' AND   ID = @cID ' END +
		            CASE WHEN @cWhere = '' THEN '' ELSE ' AND ' + @cWhere END +
		            ' SELECT @nRowCount = @@ROWCOUNT'

		SET @cSQLParam =
		   ' @nRowCount   INT    OUTPUT, ' +
		   ' @cStorerKey  NVARCHAR( 15), ' +
		   ' @cCCKey      NVARCHAR( 10), ' +
		   ' @cLOC        NVARCHAR( 10), ' +
         ' @cID         NVARCHAR( 18), ' +
		   ' @cSKU        NVARCHAR( 20), ' +
		   ' @cLottable01 NVARCHAR( 18), ' +
		   ' @cLottable02 NVARCHAR( 18), ' +
		   ' @cLottable03 NVARCHAR( 18), ' +
		   ' @dLottable04 DATETIME,      ' +
		   ' @dLottable05 DATETIME,      ' +
		   ' @cLottable06 NVARCHAR( 30), ' +
		   ' @cLottable07 NVARCHAR( 30), ' +
		   ' @cLottable08 NVARCHAR( 30), ' +
		   ' @cLottable09 NVARCHAR( 30), ' +
		   ' @cLottable10 NVARCHAR( 30), ' +
		   ' @cLottable11 NVARCHAR( 30), ' +
		   ' @cLottable12 NVARCHAR( 30), ' +
		   ' @dLottable13 DATETIME,      ' +
		   ' @dLottable14 DATETIME,      ' +
		   ' @dLottable15 DATETIME       '

		EXEC sp_ExecuteSQL @cSQL, @cSQLParam, @nRowCount OUTPUT, @cStorerKey, @cCCKey, @cLOC, @cID, @cSKU, 
		   @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,
		   @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
		   @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15

		IF @debug = 1      
		   SELECT @cSQL '@cSQL', @cSQLParam '@cSQLParam'
		   
		IF @nRowCount = 0
		BEGIN    
		   EXECUTE dbo.nspg_GetKey                                        
		      @KeyName       = 'CCDETAILKEY',                                    
		      @fieldlength   = 10 ,                                          
		      @keystring     = @cCCDetailKey   OUTPUT,                         
		      @b_success     = @bsuccess       OUTPUT,                             
		      @n_err         = @nErrNo         OUTPUT,                                   
		      @c_errmsg      = @cErrMsg        OUTPUT                                
		              
		   IF @bsuccess <> 1        
		   BEGIN        
		      SET @nErrNo = 205156        
		      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --GetKey Fail  
		      GOTO RollBackTran         
		   END    
		          
		   SELECT TOP 1 
		      @cCCSheetNo = CCSheetNo
		   FROM CCDetail WITH (NOLOCK)    
		   WHERE CCKey = @cCCKey     
		   AND   Storerkey = @cStorerKey
		   AND   Loc = @cLOC        
		   AND   SKU = @cSKU
		   ORDER BY 1
                  
         IF ISNULL(RTRIM(@cCCSheetNo), '') = ''    
         BEGIN    
            EXECUTE dbo.nspg_GetKey                
               @KeyName       = 'CCSheetNo',                        
               @fieldlength   = 10 ,                                
               @keystring     = @cCCSheetNo  OUTPUT,          
               @b_success     = @bsuccess    OUTPUT,           
               @n_err         = @nErrNo      OUTPUT,          
               @c_errmsg      = @cErrMsg     OUTPUT            
                 
            IF @bsuccess <> 1        
            BEGIN        
               SET @nErrNo = 205157  
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --GetKey Fail  
               GOTO RollBackTran         
            END                   
         END    

         IF ISNULL(@nCountNo,'') = '1'    
         BEGIN    
            INSERT INTO CCDETAIL (  
               CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty, Qty,   
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               FinalizeFlag, Status, Counted_Cnt1)    
            VALUES (  
               @cCCKey, @cCCDetailKey, @cCCSheetNo, '', @cStorerKey, @cSKU, '', @cLOC, @cID, 0, @nQty,   
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               'N', '4', '1')    
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 205158       
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --INS CCDtl Fail      
               GOTO RollBackTran        
            END       
         END               
         ELSE IF ISNULL(@nCountNo,'') = '2'    
         BEGIN       
            INSERT INTO CCDETAIL (  
               CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty, Qty_Cnt2,   
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               FinalizeFlag, Status, Counted_Cnt2)    
            VALUES (  
               @cCCKey, @cCCDetailKey, @cCCSheetNo, '', @cStorerKey, @cSKU, '', @cLOC, @cID, 0, @nQty,   
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               'N', '4', '1')    
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 205159        
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --INS CCDtl Fail      
               GOTO RollBackTran        
            END               
         END     
         ELSE IF ISNULL(@nCountNo,'') = '3'    
         BEGIN       
            INSERT INTO CCDETAIL (  
               CCKey, CCDetailKey, CCSheetNo, TagNo, Storerkey, Sku, Lot, Loc, Id, SystemQty, Qty_Cnt3,   
               Lottable01, Lottable02, Lottable03, Lottable04, Lottable05, 
               Lottable06, Lottable07, Lottable08, Lottable09, Lottable10,
               Lottable11, Lottable12, Lottable13, Lottable14, Lottable15,
               FinalizeFlag, Status, Counted_Cnt3)    
            VALUES (@cCCKey, @cCCDetailKey, @cCCSheetNo, '', @cStorerKey, @cSKU, '', @cLOC, @cID, 0, @nQty,   
               @cLottable01, @cLottable02, @cLottable03, @dLottable04, @dLottable05,    
               @cLottable06, @cLottable07, @cLottable08, @cLottable09, @cLottable10,
               @cLottable11, @cLottable12, @dLottable13, @dLottable14, @dLottable15,
               'N', '4', '1')    
            IF @@ERROR <> 0        
            BEGIN        
               SET @nErrNo = 205160        
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')  --INS CCDtl Fail      
               GOTO RollBackTran        
            END               
         END       
                         
      END     
     
      GOTO QUIT  
     
  
      RollBackTran:  
       ROLLBACK TRAN CycleCountTran  
  
      Quit:  
       WHILE @@TRANCOUNT>@nTranCount -- Commit until the level we started  
             COMMIT TRAN CycleCountTran  
   END

   Fail:    
  
END -- End Procedure  
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_SimpleCC_Confirm TO NSQL
GO