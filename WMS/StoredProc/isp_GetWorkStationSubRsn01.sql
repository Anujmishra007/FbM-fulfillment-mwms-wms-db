IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetWorkStationSubRsn01]') AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_GetWorkStationSubRsn01]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: isp_GetWorkStationSubRsn01                          */
/* Purpose: Show workstation sub reason code in drop down list          */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2015-11-19 1.0  James      SOS#315942. Created                       */
/************************************************************************/
    
CREATE PROC [dbo].[isp_GetWorkStationSubRsn01] (    
   @nMobile       int   
)     
AS    
BEGIN    
     
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
     

   SELECT CODE AS Label, CODE AS ColText 
   FROM dbo.CODELKUP WITH (NOLOCK)   
   WHERE ListName = 'VAPSDWNRSN'
   ORDER BY 1
        
END
GO
GRANT EXECUTE ON [dbo].[isp_GetWorkStationSubRsn01] TO nSQL 
GO
