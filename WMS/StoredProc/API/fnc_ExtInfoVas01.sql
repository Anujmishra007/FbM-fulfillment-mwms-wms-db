IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[API].[fnc_ExtInfoVas01]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [API].[fnc_ExtInfoVas01]
GO

/****** Object:  StoredProcedure [API].[fnc_ExtInfoVas01]    Script Date: 6/3/2020 4:50:51 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/  
/* Store procedure: fnc_ExtInfoVas01                                          */  
/* Copyright      : LFLogistics                                               */  
/*                                                                            */  
/* Date         Rev  Author     Purposes                                      */  
/* 2020-06-26   1.0  Chermaine  Created                                       */  
/******************************************************************************/  
  
Create PROC [API].[fnc_ExtInfoVas01] (  
   @cStorerKey    NVARCHAR( 15),  
   @cOrderKey     NVARCHAR( 10),  
   @b_Success     INT = 1  OUTPUT,  
   @n_Err         INT = 0  OUTPUT,  
   @c_ErrMsg      NVARCHAR( 255) = ''  OUTPUT,   
   @cNotes        NVARCHAR( 4000) = ''  OUTPUT,  
   @cLong         NVARCHAR( 250) = ''  OUTPUT
)  
AS  
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  
SET CONCAT_NULL_YIELDS_NULL OFF  
  
  
SELECT @cLong = ISNULL(C.long,''), @cNotes = ISNULL(C.NOTES,'') 
FROM ORDERS O WITH (NOLOCK)
JOIN CODELKUP C WITH (NOLOCK) ON (O.C_ISOCntryCode = C.CODE)
WHERE C.ListName ='ISOCOUNTRY' 
AND O.OrderKey = @cOrderKey
AND o.StorerKey = @cStorerKey


SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON api.fnc_GetPrinter TO NSQL
GO


