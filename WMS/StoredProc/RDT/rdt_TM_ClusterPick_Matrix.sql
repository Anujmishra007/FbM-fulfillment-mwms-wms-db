IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_TM_ClusterPick_Matrix]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_TM_ClusterPick_Matrix]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO    
/************************************************************************/  
/* Store procedure: rdt_TM_ClusterPick_Matrix                           */  
/* Copyright      : IDS                                                 */  
/*                                                                      */  
/* Purpose: Show carton matrix                                          */  
/*                                                                      */  
/* Called from: rdtfnc_PostPackSort                                     */
/*                                                                      */  
/* Date         Rev  Author   Purposes                                  */  
/* 2020-03-17   1.0  James    WMS-12055 Created                         */  
/* 2021-07-15   1.1  James    WMS-17429 Show carton position (james01)  */  
/*                            Add custom matrix sp                      */  
/************************************************************************/  
  
CREATE PROC [RDT].[rdt_TM_ClusterPick_Matrix] (  
   @nMobile        INT,  
   @nFunc          INT,  
   @cLangCode      NVARCHAR( 3),  
   @nStep          INT,  
   @nInputKey      INT,  
   @cFacility      NVARCHAR( 5),  
   @cStorerKey     NVARCHAR( 15),  
   @cGroupKey      NVARCHAR( 10),  
   @cTaskDetailKey NVARCHAR( 10),  
   @cResult01      NVARCHAR( 20) OUTPUT,  
   @cResult02      NVARCHAR( 20) OUTPUT,  
   @cResult03      NVARCHAR( 20) OUTPUT,  
   @cResult04      NVARCHAR( 20) OUTPUT,  
   @cResult05      NVARCHAR( 20) OUTPUT,  
   @cResult06      NVARCHAR( 20) OUTPUT,  
   @cResult07      NVARCHAR( 20) OUTPUT,  
   @cResult08      NVARCHAR( 20) OUTPUT,  
   @nNextPage      INT           OUTPUT,  
   @nErrNo         INT           OUTPUT,  
   @cErrMsg        NVARCHAR( 20) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @cSQL        NVARCHAR( MAX)    
   DECLARE @cSQLParam   NVARCHAR( MAX)    
   DECLARE @cMatrixSP   NVARCHAR( 20)    
     
   -- Get storer config    
   SET @cMatrixSP = rdt.RDTGetConfig( @nFunc, 'MatrixSP', @cStorerKey)    
   IF @cMatrixSP = '0'    
      SET @cMatrixSP = ''    
    
   /***********************************************************************************************    
                                              Custom confirm    
   ***********************************************************************************************/    
   -- Check confirm SP blank    
   IF @cMatrixSP <> ''    
   BEGIN    
      -- Confirm SP    
      SET @cSQL = 'EXEC rdt.' + RTRIM( @cMatrixSP) +    
         ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, ' +   
         ' @cFacility, @cStorerKey, @cGroupKey, @cTaskDetailKey, ' +    
         ' @cResult01 OUTPUT, @cResult02 OUTPUT, @cResult03 OUTPUT, @cResult04 OUTPUT, ' +   
         ' @cResult05 OUTPUT, @cResult06 OUTPUT, @cResult07 OUTPUT, @cResult08 OUTPUT, ' +     
         ' @nNextPage OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT '    
      SET @cSQLParam =    
         ' @nMobile        INT,           ' +    
         ' @nFunc          INT,           ' +    
         ' @cLangCode      NVARCHAR( 3),  ' +    
         ' @nStep          INT,           ' +    
         ' @nInputKey      INT,           ' +    
         ' @cFacility      NVARCHAR( 5) , ' +    
         ' @cStorerKey     NVARCHAR( 15), ' +    
         ' @cGroupKey      NVARCHAR( 10), ' +  
         ' @cTaskDetailKey NVARCHAR( 10), ' +  
         ' @cResult01      NVARCHAR( 20) OUTPUT, ' +  
         ' @cResult02      NVARCHAR( 20) OUTPUT, ' +  
         ' @cResult03      NVARCHAR( 20) OUTPUT, ' +  
         ' @cResult04      NVARCHAR( 20) OUTPUT, ' +  
         ' @cResult05      NVARCHAR( 20) OUTPUT, ' +  
         ' @cResult06      NVARCHAR( 20) OUTPUT, ' +  
         ' @cResult07      NVARCHAR( 20) OUTPUT, ' +  
         ' @cResult08      NVARCHAR( 20) OUTPUT, ' +  
         ' @nNextPage      INT           OUTPUT, ' +  
         ' @nErrNo         INT           OUTPUT, ' +    
         ' @cErrMsg        NVARCHAR(250) OUTPUT  '    
    
      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,    
         @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey,   
         @cFacility, @cStorerKey, @cGroupKey, @cTaskDetailKey,   
         @cResult01 OUTPUT, @cResult02 OUTPUT, @cResult03 OUTPUT, @cResult04 OUTPUT,   
         @cResult05 OUTPUT, @cResult06 OUTPUT, @cResult07 OUTPUT, @cResult08 OUTPUT,   
         @nNextPage OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT   
    
      GOTO Quit    
   END    
    
   /***********************************************************************************************    
                                              Standard matrix    
   ***********************************************************************************************/    
     
   DECLARE @curPD CURSOR  
   DECLARE @cPickSlipNo    NVARCHAR( 10) = ''  
   DECLARE @cCartonType    NVARCHAR( 10) = ''  
   DECLARE @nCount         INT = 0  
   DECLARE @nCartonNo      INT  
     
   CREATE TABLE #CaseInfo  (    
      RowRef         BIGINT IDENTITY(1,1)  Primary Key,    
      PickSlipNo     NVARCHAR( 10),  
      LabelNo        NVARCHAR( 20))    
  
   -- Get PickslipNo, LabelNo  
   INSERT INTO #CaseInfo (PickSlipNo, LabelNo)  
   SELECT DISTINCT PH.PickSlipNo, TD.Caseid  
   FROM dbo.TASKDETAIL TD (NOLOCK)   
   JOIN dbo.PICKDETAIL PD (NOLOCK) ON ( TD.Caseid = PD.CaseID)   
   JOIN dbo.PackHeader PH (NOLOCK) ON ( PD.OrderKey = PH.orderkey)  
   WHERE TD.Groupkey = @cGroupKey  
   AND   TD.[Status] < '9'  
     
   SET @nCount = 1  
  
   SET @curPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT PD.PickSlipNo, PD.CartonNo, PIF.CartonType  
   FROM #CaseInfo C   
   JOIN dbo.PackDetail PD WITH (NOLOCK) ON ( C.PickSlipNo = PD.PickSlipNo AND C.LabelNo = PD.LabelNo)  
   JOIN dbo.PackInfo PIF WITH (NOLOCK) ON ( PD.PickSlipNo = PIF.PickSlipNo AND PD.CartonNo = PIF.CartonNo)  
   JOIN dbo.CARTONIZATION CZ WITH (NOLOCK) ON ( PIF.CartonType = CZ.CartonType)  
   JOIN STORER ST WITH (NOLOCK) ON ( CZ.CartonizationGroup = ST.CartonGroup)  
   WHERE ST.StorerKey = @cStorerKey  
   GROUP BY PD.PickSlipNo, PD.CartonNo, PIF.CartonType, CZ.[CUBE], CZ.UseSequence  
   ORDER BY CZ.CUBE, CZ.UseSequence  
   OPEN @curPD  
   FETCH NEXT FROM @curPD INTO @cPickSlipNo, @nCartonNo, @cCartonType  
   WHILE @@FETCH_STATUS = 0  
   BEGIN  
      IF @nCount = 1 SET @cResult01 = '1-' + @cCartonType  
      IF @nCount = 2 SET @cResult02 = '2-' + @cCartonType  
      IF @nCount = 3 SET @cResult03 = '3-' + @cCartonType  
      IF @nCount = 4 SET @cResult04 = '4-' + @cCartonType  
      IF @nCount = 5 SET @cResult05 = '5-' + @cCartonType  
      IF @nCount = 6 SET @cResult06 = '6-' + @cCartonType  
      IF @nCount = 7 SET @cResult07 = '7-' + @cCartonType  
      IF @nCount = 8 SET @cResult08 = '8-' + @cCartonType  
        
      SET @nCount = @nCount + 1  
        
      IF @nCount >= 8  
         BREAK  
  
      FETCH NEXT FROM @curPD INTO @cPickSlipNo, @nCartonNo, @cCartonType  
   END  
   
  
   Quit:  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_TM_ClusterPick_Matrix to nSQL
GO