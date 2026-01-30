SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/      
/* Store procedure: rdt_727Inquiry40								       */      
/*                                                                         */      
/* Modifications log:                                                      */      
/*                                                                         */      
/* Date       Rev  Author   Purposes                                       */      
/* 2025-12-12 1.0  PSJ036   UWP-48150 DROPID INFO                          */    
/***************************************************************************/      
      
CREATE OR ALTER   PROC [RDT].[rdt_727Inquiry40] (      
 @nMobile    INT,             
 @nFunc      INT,             
 @nStep      INT,              
 @cLangCode  NVARCHAR( 3),    
 @cStorerKey NVARCHAR( 15),    
 @cOption    NVARCHAR( 1),    
 @cParam1    NVARCHAR(20),     
 @cParam2    NVARCHAR(20),     
 @cParam3    NVARCHAR(20),     
 @cParam4    NVARCHAR(20),     
 @cParam5    NVARCHAR(20),     
 @c_oFieled01  NVARCHAR(20) OUTPUT,  
 @c_oFieled02  NVARCHAR(20) OUTPUT,  
 @c_oFieled03  NVARCHAR(20) OUTPUT,  
 @c_oFieled04  NVARCHAR(20) OUTPUT,  
 @c_oFieled05  NVARCHAR(20) OUTPUT,  
 @c_oFieled06  NVARCHAR(20) OUTPUT,  
 @c_oFieled07  NVARCHAR(20) OUTPUT,  
 @c_oFieled08  NVARCHAR(20) OUTPUT,  
 @c_oFieled09  NVARCHAR(20) OUTPUT,  
 @c_oFieled10  NVARCHAR(20) OUTPUT,  
 @c_oFieled11  NVARCHAR(20) OUTPUT,  
 @c_oFieled12  NVARCHAR(20) OUTPUT,  
 @nNextPage    INT          OUTPUT,  
 @nErrNo     INT OUTPUT,      
 @cErrMsg    NVARCHAR( 20) OUTPUT  
)      
AS      
   SET NOCOUNT ON          
   SET ANSI_NULLS OFF          
   SET QUOTED_IDENTIFIER OFF          
   SET CONCAT_NULL_YIELDS_NULL OFF       
      
   DECLARE 
          @cSKU            NVARCHAR(20)  
         ,@cDropID         NVARCHAR(20) 
         ,@nRemainQty      INT
         ,@nTTLQty         INT
      
   DECLARE @nSKUCnt        INT  
          ,@b_Success      INT  
          ,@cLabelNo       NVARCHAR(20) 
          ,@cPickSlipNo    NVARCHAR(10)
          ,@cPlatform      NVARCHAR(4000) 
          ,@cUserDefine03  NVARCHAR(20) 
          ,@cOrderKey      NVARCHAR(10)
          ,@cWaveKey       NVARCHAR(10)
          ,@cShipFlag	   NVARCHAR(1)
          ,@nCartonCount   INT
          ,@cCartonCount   NVARCHAR( 20)
          ,@cSeq           NVARCHAR( 30)
          ,@cMessage       NVARCHAR( 30)
          ,@cSingleDesc    NVARCHAR( 30)
		  ,@cTtl_Seq       NVARCHAR( 60)
		  ,@cDocTYpe	   NVARCHAR(1)
            
      
            
SET @nErrNo = 0   
  
IF @nFunc = 727 -- General inquiry
  BEGIN
	SET @cLabelNo = ''
	SET @cSKU	  = ''
	IF @cOption = '1' 
	BEGIN
	IF @nStep = 2   
	BEGIN  
		SET @cLabelNo      = @cParam1
		--SET @cSKU	   	   = @cParam2
		--SET @cUPC        = @cParam3  
			
		IF @cLabelNo = ''  
		BEGIN  
			SET @nErrNo = 257641  
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --CartonIDReq  
			GOTO QUIT   
		END  

		IF NOT EXISTS ( SELECT 1 FROM dbo.PickDetail WITH (NOLOCK)   
						WHERE StorerKey = @cStorerKey
						AND DropID = @cLabelNo)  
		BEGIN  
			SET @nErrNo = 257642  
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidCartonID 
			GOTO QUIT   
		END  

		IF EXISTS ( Select 1 FROM dbo.PickDetail WITH (NOLOCK)   
						WHERE StorerKey = @cStorerKey
						AND DropID = @cLabelNo
						AND Status NOT IN ('3','5'))
		BEGIN  
			SET @nErrNo = 257643  
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidCartonID 
			GOTO QUIT   
		END  
				
		SELECT		@nSKUCnt = sum (qty)  --Count SKU
			FROM dbo.PickDetail WITH (NOLOCK)
			WHERE StorerKey = @cStorerKey
				  AND DropID = @cLabelNo
				  AND (Status > '0' and Status < '9')


		SELECT	top 1 @cOrderKey		= OrderKey 
					 ,@cWaveKey  	= WaveKey 
		FROM dbo.PickDetail WITH (NOLOCK)
		WHERE StorerKey = @cStorerKey
		AND DropID = @cLabelNo
		AND (Status > '0' and Status < '9')

		
		SELECT distinct @cShipFlag = Ecom_Single_Flag
					   ,@cDocTYpe = DocType	
		FROM dbo.Orders WITH (NOLOCK) 
		WHERE UserDefine09 = @cWaveKey
		
		IF (@cShipFlag = 'M' and @cDocTYpe = 'E')
			Begin
			Set @cMessage = 'ENVIA PARA PTW'
			Set @cSingleDesc = 'B2C - MULTI'
			END
		IF (@cShipFlag = 'S' and @cDocTYpe = 'E')
			BEGIN
			SET @cMessage = 'ENVIA PARA PACK'
			SET @cSingleDesc = 'B2C - SINGLE'
			END
		IF (@cShipFlag = '' and @cDocTYpe = 'N')
			BEGIN
			SET @cMessage = 'ENVIA PARA PACK'
			SET @cSingleDesc = 'B2B'
			END
		
/*		SELECT @cPlatform = Notes2 
		FROM dbo.Codelkup WITH (NOLOCK) 
		WHERE Listname  = 'UAEPLCN'
		AND Long = @cUserDefine03 
		AND StorerKey = @cStorerKey 
		
		SELECT @nCartonCount = Count (DISTINCT DropID )
		FROM dbo.PickDetail WITH (NOLOCK) 
		WHERE StorerKey = @cStorerKey 
		AND PickSlipNo = @cPickSlipNo  
		AND ISNULL(DropID,'')  <> '' 
	
		SELECT @cDropID =ISNULL(MAX(CASE WHEN DD.ChildId=@cLabelNo THEN DD.Dropid END),'XX'),
				@cSeq = ISNULL(MAX(CASE WHEN DD.ChildId=@cLabelNo THEN DD.UserDefine01 END),'X'),
				@cTtl_Seq = Count (DISTINCT DD.ChildId )
		FROM dbo.PickDetail PD WITH (NOLOCK) 
		LEFT JOIN dbo.DropidDetail DD WITH (NOLOCK) ON DD.ChildID=PD.DropID
		LEFT JOIN dbo.Dropid D WITH (NOLOCK) ON D.Dropid = DD.Dropid
		WHERE PD.StorerKey = @cStorerKey 
		AND PD.PickSlipNo = @cPickSlipNo  
		AND ISNULL(PD.DropID,'')  <> '' 
		AND D.Status='0'
	
	
		SET @cCartonCount = RIGHT( '0' + SUBSTRING( @cDropID, 14, 1), 2) + '/' + RTRIM( @cSeq) + '/' + RTRIM( @cTtl_Seq) + '/' + CAST( @nCartonCount AS NVARCHAR( 5))
*/	
		SET @c_oFieled01 = 'Tote ID:'
		SET @c_oFieled02 = @cLabelNo     
		SET @c_oFieled03 = 'SINGLE FLAG :'   
		SET @c_oFieled04 = @cSingleDesc   
		SET @c_oFieled05 = 'SKU COUNT:'
		SET @c_oFieled06 = @nSKUCnt    
		SET @c_oFieled07 = 'WaveKey:' 
		SET @c_oFieled08 = @cWaveKey
		SET @c_oFieled09 = 'Instructions:'  
		SET @c_oFieled10 = @cMessage    
			
		SET @nNextPage = 0  
			
		END  
	END  
END
QUIT:  
          
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_727Inquiry40] TO [NSQL]
GO