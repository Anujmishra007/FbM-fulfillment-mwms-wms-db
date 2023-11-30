SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   

/******************************************************************************/                     
/* Copyright: IDS                                                             */                     
/* Purpose: isp_Bartender_CN_TPYSKULBL02_001                                  */                     
/*                                                                            */                     
/* Modifications log:                                                         */                     
/*                                                                            */                     
/* Date       Rev  Author     Purposes                                        */     
/* 2023-09-20 1.0  CSCHONG    Devops Scripts Combine & Created (WMS-23532)    */                 
/******************************************************************************/   
CREATE OR ALTER PROC [dbo].[isp_Bartender_CN_TPYSKULBL02_001]                 
(  @c_Sparm01            NVARCHAR(250),        
   @c_Sparm02            NVARCHAR(250),        
   @c_Sparm03            NVARCHAR(250),        
   @c_Sparm04            NVARCHAR(250),        
   @c_Sparm05            NVARCHAR(250),        
   @c_Sparm06            NVARCHAR(250),        
   @c_Sparm07            NVARCHAR(250),        
   @c_Sparm08            NVARCHAR(250),        
   @c_Sparm09            NVARCHAR(250),        
   @c_Sparm10            NVARCHAR(250),  
   @b_debug              INT = 0                 
)                
AS                
BEGIN                
   SET NOCOUNT ON           
   SET ANSI_NULLS OFF          
   SET QUOTED_IDENTIFIER OFF           
   SET CONCAT_NULL_YIELDS_NULL OFF              
                        
   DECLARE            
      @c_PalletKey         NVARCHAR(50),              
      @c_SKU               NVARCHAR(20),             
      @c_serialno          NVARCHAR(4000),        
      @c_SQL               NVARCHAR(4000),  
      @c_SQLSORT           NVARCHAR(4000),  
      @c_SQLJOIN           NVARCHAR(4000),  
      @n_TTLCopy           INT,  
      @c_ChkStatus         NVARCHAR(2),  
      @c_Uccno             NVARCHAR(80),  
      @c_storerkey         NVARCHAR(80),  
      @n_continue          INT,  
      @c_ExecStatements    NVARCHAR(4000),     
      @c_ExecArguments     NVARCHAR(4000),  
      @n_MaxLine           INT,     
      @n_pageno            INT,     
      @n_totalpg           INT,
      @d_RDLOTT04          DATETIME,
      @c_col16             NVARCHAR(80)        
   
  
  
    -- SET RowNo = 0       
    SET @c_SQL = ''    
    SET @n_TTLCopy = 1  
    SET @n_MaxLine = 100  
        
    CREATE TABLE [#Result] (       
      [ID]    [INT] IDENTITY(1,1) NOT NULL,                      
      [Col01] [NVARCHAR] (80) NULL,        
      [Col02] [NVARCHAR] (80) NULL,        
      [Col03] [NVARCHAR] (80) NULL,        
      [Col04] [NVARCHAR] (80) NULL,        
      [Col05] [NVARCHAR] (80) NULL,        
      [Col06] [NVARCHAR] (80) NULL,        
      [Col07] [NVARCHAR] (80) NULL,        
      [Col08] [NVARCHAR] (80) NULL,        
      [Col09] [NVARCHAR] (80) NULL,        
      [Col10] [NVARCHAR] (80) NULL,        
      [Col11] [NVARCHAR] (80) NULL,        
      [Col12] [NVARCHAR] (80) NULL,        
      [Col13] [NVARCHAR] (80) NULL,        
      [Col14] [NVARCHAR] (80) NULL,        
      [Col15] [NVARCHAR] (80) NULL,        
      [Col16] [NVARCHAR] (80) NULL,        
      [Col17] [NVARCHAR] (80) NULL,        
      [Col18] [NVARCHAR] (80) NULL,        
      [Col19] [NVARCHAR] (80) NULL,        
      [Col20] [NVARCHAR] (80) NULL,        
      [Col21] [NVARCHAR] (80) NULL,        
      [Col22] [NVARCHAR] (80) NULL,        
      [Col23] [NVARCHAR] (80) NULL,        
      [Col24] [NVARCHAR] (80) NULL,        
      [Col25] [NVARCHAR] (80) NULL,        
      [Col26] [NVARCHAR] (80) NULL,        
      [Col27] [NVARCHAR] (80) NULL,        
      [Col28] [NVARCHAR] (80) NULL,        
      [Col29] [NVARCHAR] (80) NULL,        
      [Col30] [NVARCHAR] (80) NULL,        
      [Col31] [NVARCHAR] (80) NULL,        
      [Col32] [NVARCHAR] (80) NULL,        
      [Col33] [NVARCHAR] (80) NULL,        
      [Col34] [NVARCHAR] (80) NULL,        
      [Col35] [NVARCHAR] (80) NULL,        
      [Col36] [NVARCHAR] (80) NULL,        
      [Col37] [NVARCHAR] (80) NULL,        
      [Col38] [NVARCHAR] (80) NULL,        
      [Col39] [NVARCHAR] (80) NULL,        
      [Col40] [NVARCHAR] (80) NULL,        
      [Col41] [NVARCHAR] (80) NULL,        
      [Col42] [NVARCHAR] (80) NULL,        
      [Col43] [NVARCHAR] (80) NULL,        
      [Col44] [NVARCHAR] (80) NULL,        
      [Col45] [NVARCHAR] (80) NULL,        
      [Col46] [NVARCHAR] (80) NULL,        
      [Col47] [NVARCHAR] (80) NULL,        
      [Col48] [NVARCHAR] (80) NULL,        
      [Col49] [NVARCHAR] (80) NULL,        
      [Col50] [NVARCHAR] (80) NULL,       
      [Col51] [NVARCHAR] (80) NULL,        
      [Col52] [NVARCHAR] (80) NULL,        
      [Col53] [NVARCHAR] (80) NULL,        
      [Col54] [NVARCHAR] (80) NULL,        
      [Col55] [NVARCHAR] (80) NULL,        
      [Col56] [NVARCHAR] (80) NULL,        
      [Col57] [NVARCHAR] (80) NULL,        
      [Col58] [NVARCHAR] (80) NULL,        
      [Col59] [NVARCHAR] (80) NULL,        
      [Col60] [NVARCHAR] (80) NULL       
     )       
  
     IF @c_Sparm04='N'
     BEGIN

         SELECT TOP 1 @d_RDLOTT04 = MIN(RD.Lottable04)
         FROM dbo.RECEIPTDETAIL RD (NOLOCK)
         WHERE RD.ReceiptKey = @c_Sparm01 
         AND RD.sku = @c_Sparm02
         AND RD.StorerKey =@c_Sparm03
         
     END
     ELSE IF @c_Sparm04='Y'
     BEGIN

         SELECT TOP 1 @d_RDLOTT04 = LOTT.Lottable04
         FROM dbo.LOTxLOCxID lli (NOLOCK)
         JOIN dbo.LOTATTRIBUTE LOTT WITH (NOLOCK) ON LOTT.lot=lli.lot AND LOTT.StorerKey=lli.StorerKey AND LOTT.sku = lli.Sku
         WHERE lli.sku = @c_Sparm02
         AND lli.StorerKey =@c_Sparm03 
         AND lli.qty > 0
         ORDER BY LOTT.Lottable04 

     END
     

  
     IF @c_Sparm04='N'
     BEGIN

         INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09    
             ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22    
             ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34    
             ,Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44   
             ,Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54  
             ,Col55,Col56,Col57,Col58,Col59,Col60)  
    SELECT TOP 1  N'思缇韦曼' ,ISNULL(S.busr5,''),S.Style + '*'+ S.Color,ISNULL(S.busr3,''),ISNULL(S.CountryofOrigin,''),
          (ISNULL(S.busr1,'')+ISNULL(S.busr9,'')),ISNULL(S.busr2,''),ISNULL(S.busr10,''),ISNULL(S.busr8,''),ISNULL(S.productmodel,''),
           '01',N'蔻驰贸易（上海）有限公司',N'上海市静安区山西北路99号 2001-04A单元','021-50196016','200040',  --15
           CONVERT(NVARCHAR(4),YEAR(@d_RDLOTT04))+N'年' + CONVERT(NVARCHAR(4),MONTH(@d_RDLOTT04)) +N'月' +CONVERT(NVARCHAR(4),DAY(@d_RDLOTT04)) +N'日' ,--16
           S.Descr,S.SKU,S.SKU,S.Price,(S.BUSR3 +' ' + S.BUSR4),'','','','', 
           '','','','','','','','','','', 
           '','','','','','','','','','', 
           '','','','','','','','','','', 
           '','','','',''
    FROM dbo.RECEIPT R WITH (nolock)
    JOIN dbo.RECEIPTDETAIL RD WITH (nolock) on RD.ReceiptKey=R.receiptkey
    JOIN SKU S WITH (nolock) on S.StorerKey = RD.StorerKey AND S.sku = RD.Sku
    WHERE R.ReceiptKey=@c_Sparm01
    AND RD.sku = @c_Sparm02
   ORDER by R.ReceiptKey,RD.Sku
   END
   ELSE IF @c_Sparm04='Y'
     BEGIN

         INSERT INTO #Result (Col01,Col02,Col03,Col04,Col05, Col06,Col07,Col08,Col09    
             ,Col10,Col11,Col12,Col13,Col14,Col15,Col16,Col17,Col18,Col19,Col20,Col21,Col22    
             ,Col23,Col24,Col25,Col26,Col27,Col28,Col29,Col30,Col31,Col32,Col33,Col34    
             ,Col35,Col36,Col37,Col38,Col39,Col40,Col41,Col42,Col43,Col44   
             ,Col45,Col46,Col47,Col48,Col49,Col50,Col51,Col52,Col53,Col54  
             ,Col55,Col56,Col57,Col58,Col59,Col60)  
    SELECT  N'思缇韦曼' ,ISNULL(S.busr5,''),S.Style + '*'+ S.Color,ISNULL(S.busr3,''),ISNULL(S.CountryofOrigin,''),
          (ISNULL(S.busr1,'')+ISNULL(S.busr9,'')),ISNULL(S.busr2,''),ISNULL(S.busr10,''),ISNULL(S.busr8,''),ISNULL(S.productmodel,''),
           '01',N'蔻驰贸易（上海）有限公司',N'上海市静安区山西北路99号 2001-04A单元','021-50196016','200040',  --15
           CONVERT(NVARCHAR(4),YEAR(@d_RDLOTT04))+N'年' + CONVERT(NVARCHAR(4),MONTH(@d_RDLOTT04)) +N'月' +CONVERT(NVARCHAR(4),DAY(@d_RDLOTT04)) +N'日' ,--16
           S.Descr,S.SKU,S.SKU,S.Price,(S.BUSR3 +' ' + S.Color),'','','','', 
           '','','','','','','','','','', 
           '','','','','','','','','','', 
           '','','','','','','','','','', 
           '','','','',''
    FROM SKU S WITH (nolock) --on S.StorerKey = RD.StorerKey AND S.sku = RD.Sku
    WHERE S.StorerKey=@c_Sparm03
    AND S.sku = @c_Sparm02

   END
   
    
   SELECT * FROM #Result WITH (NOLOCK)  

  
   EXIT_SP:         
                                 
   END -- procedure       

GO
GRANT EXECUTE ON [dbo].[isp_Bartender_CN_TPYSKULBL02_001] TO nsql
GO 

