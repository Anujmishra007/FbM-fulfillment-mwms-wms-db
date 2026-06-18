SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/************************************************************************/  
/* Store procedure: rdt_1855DisableQTY03                                */  
/* Copyright      : Maersk                                              */  
/* Customer       : CSCUK01                                             */  
/*                                                                      */  
/* Purpose: Disable qty field based on product type                     */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date         Author    Ver.  Purposes                                */  
/* 2026-03-23   AGA399    1.0   Created                                 */  
/************************************************************************/  
     
CREATE OR ALTER PROCEDURE [RDT].[rdt_1855DisableQTY03]  
   @nMobile                INT,  
   @nFunc                  INT,  
   @cLangCode              NVARCHAR( 3),  
   @nStep                  INT,  
   @nInputKey              INT,  
   @cTaskdetailKey         NVARCHAR( 10),  
   @tVarDisableQTYField    VARIABLETABLE READONLY,  
   @cDisableQTYField       NVARCHAR( 1)  OUTPUT,  
   @nErrNo                 INT           OUTPUT,  
   @cErrMsg                NVARCHAR( 20) OUTPUT  
AS  
BEGIN  
    SET NOCOUNT ON  
    SET QUOTED_IDENTIFIER OFF  
    SET ANSI_NULLS OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
    SET @nErrNo = 0
    SET @cErrMsg = ''
    SET @cDisableQTYField = '0'  -- Enable by default
    
    DECLARE @cProductCategory  NVARCHAR( 30)    
    DECLARE @cStorerKey        NVARCHAR( 15)  
    DECLARE @cSKU              NVARCHAR( 20)  
    
    -- Get TaskDetail info    
    SELECT @cStorerKey = Storerkey,  
            @cSKU = Sku  
    FROM dbo.TaskDetail WITH (NOLOCK)  
    WHERE TaskDetailKey = @cTaskdetailKey  
        
    -- Get product category, 505 = Footwear; 305/405 = Apparel; 705/805/900 = Equipment  
    SELECT @cProductCategory = BUSR7  
    FROM dbo.SKU WITH (NOLOCK)  
    WHERE StorerKey = @cStorerKey  
    AND   SKU = @cSKU  
    
    -- TM Assisted Cluster Pick  
    IF @nFunc = 1855  
    BEGIN  
        -- Enable by default  
        SET @cDisableQTYField = '0'  
    
        IF EXISTS ( SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK)  
                    WHERE LISTNAME = 'PickPcByCT'  
                    AND   Code = @cProductCategory  
                    AND   StorerKey = @cStorerKey  
                    AND   Code2 = CAST( @nFunc AS NVARCHAR(30))
                    AND   Short = '1')  
        BEGIN  
            SET @cDisableQTYField = '1' -- Disable    
        END  
    END    
END  
GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON [RDT].[rdt_1855DisableQTY03] TO nSQL
GO