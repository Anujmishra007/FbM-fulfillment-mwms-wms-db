USE [GLOWMS]
GO
/****** Object:  StoredProcedure [dbo].[isp_BT_Bartender_EU_ARLASHPLBL]    Script Date: 6/21/2026 3:39:52 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************************************/
/* Stored Procedure: isp_BT_Bartender_EU_ARLASHPLBL                    */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : ARLA Shipping Label  UWP-59479                             */
/*                                                                           */
/* Called By: Bartender Label isp_BT_Bartender_EU_ARLASHPLBL                  */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 01-04-2026   KMS043   1.0  Initial version created                        */
/*****************************************************************************/
CREATE OR ALTER       PROC [dbo].[isp_BT_Bartender_EU_ARLASHPLBL]
(
   @c_Sparm1  NVARCHAR(250),
   @c_Sparm2  NVARCHAR(250),
   @c_Sparm3  NVARCHAR(250),
   @c_Sparm4  NVARCHAR(250),
   @c_Sparm5  NVARCHAR(250),
   @c_Sparm6  NVARCHAR(250),
   @c_Sparm7  NVARCHAR(250),
   @c_Sparm8  NVARCHAR(250),
   @c_Sparm9  NVARCHAR(250),
   @c_Sparm10 NVARCHAR(250),
   @b_debug   INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cOrderkey NVARCHAR(30);

    SELECT TOP 1 @cOrderkey = ORDERKEY

	
    FROM PICKDETAIL WITH (NOLOCK)
    WHERE DROPID = RIGHT(@c_Sparm1,18)
      AND UOM IN ('1','2','6');


    IF @cOrderkey IS NULL RETURN;


    DECLARE @MaxValue INT;

    SELECT @Maxvalue = ISNULL(MAX(TRY_CAST(NOTES AS INT)),0)
    FROM PICKDETAIL  WITH (NOLOCK)
    WHERE ORDERKEY = @cOrderkey
      --AND UOM IN (1,2,6)
   --   AND TRY_CAST(NOTES AS INT) IS NOT NULL OR NOTES=''
	 

    ;WITH MISSING_DROP AS
    (
        SELECT 
            DROPID,
            ROW_NUMBER() OVER (ORDER BY DROPID) AS RN
        FROM PICKDETAIL  WITH (NOLOCK)
        WHERE ORDERKEY = @cOrderkey
          AND UOM IN ('1','2','6')
        GROUP BY DROPID,NOTES
        HAVING MAX(TRY_CAST(NOTES AS INT)) IS NULL  OR NOTES =''
    )
    UPDATE PD
    SET NOTES = CAST(@MaxValue + M.RN AS NVARCHAR(20))
    FROM PICKDETAIL PD WITH (ROWLOCK)
    JOIN MISSING_DROP M  WITH (NOLOCK)
        ON PD.DROPID = M.DROPID
    WHERE PD.ORDERKEY = @cOrderkey
      AND PD.UOM IN ('1','2','6');

    
    IF NOT EXISTS (SELECT 1 FROM PICKDETAIL  WITH (NOLOCK) WHERE DROPID = RIGHT(@c_Sparm1,18))
        RETURN;

   
    CREATE TABLE #Result
    (
      ID INT IDENTITY(1,1),
      Col01 NVARCHAR(80),Col02 NVARCHAR(80),Col03 NVARCHAR(80),Col04 NVARCHAR(80),Col05 NVARCHAR(80),
      Col06 NVARCHAR(80),Col07 NVARCHAR(80),Col08 NVARCHAR(80),Col09 NVARCHAR(80),Col10 NVARCHAR(80),
      Col11 NVARCHAR(80),Col12 NVARCHAR(80),Col13 NVARCHAR(80),Col14 NVARCHAR(80),Col15 NVARCHAR(80),
      Col16 NVARCHAR(80),Col17 NVARCHAR(80),Col18 NVARCHAR(80),Col19 NVARCHAR(80),Col20 NVARCHAR(80),
      Col21 NVARCHAR(80),Col22 NVARCHAR(80),Col23 NVARCHAR(80),Col24 NVARCHAR(80),Col25 NVARCHAR(80),
      Col26 NVARCHAR(80),Col27 NVARCHAR(80),Col28 NVARCHAR(80),Col29 NVARCHAR(80),Col30 NVARCHAR(80),
      Col31 NVARCHAR(80),Col32 NVARCHAR(80),Col33 NVARCHAR(80),Col34 NVARCHAR(80),Col35 NVARCHAR(80),
      Col36 NVARCHAR(80),Col37 NVARCHAR(80),Col38 NVARCHAR(80),Col39 NVARCHAR(80),Col40 NVARCHAR(80),
      Col41 NVARCHAR(80),Col42 NVARCHAR(80),Col43 NVARCHAR(80),Col44 NVARCHAR(80),Col45 NVARCHAR(80),
      Col46 NVARCHAR(80),Col47 NVARCHAR(80),Col48 NVARCHAR(80),Col49 NVARCHAR(80),Col50 NVARCHAR(80),
      Col51 NVARCHAR(80),Col52 NVARCHAR(80),Col53 NVARCHAR(80),Col54 NVARCHAR(80),Col55 NVARCHAR(80),
      Col56 NVARCHAR(80),Col57 NVARCHAR(80),Col58 NVARCHAR(80),Col59 NVARCHAR(80),Col60 NVARCHAR(80)
    );


   DECLARE @SQL NVARCHAR(MAX)

   SET @SQL = '
   ;WITH BASE AS
   (
       SELECT 
            PD.DropID,
            PD.ORDERKEY,
            PD.SKU,
            PD.LOT,
            PD.WAVEKEY,
            SUM(PD.QTY) AS QTY,
            ISNULL(S.STDGROSSWGT,0) AS GrossWeight,
            TRY_CAST(PD.NOTES AS INT) AS NOTES,O.SEQUENCENO
       FROM PICKDETAIL PD WITH (NOLOCK)
       JOIN ORDERS O WITH (NOLOCK) ON O.ORDERKEY = PD.ORDERKEY
       JOIN SKU S WITH (NOLOCK) ON S.SKU = PD.SKU AND S.STORERKEY = O.STORERKEY
       WHERE PD.DROPID = RIGHT(@c_Sparm1,18)
       GROUP BY PD.DropID, PD.ORDERKEY, PD.SKU, PD.LOT, PD.WAVEKEY, S.STDGROSSWGT, PD.NOTES,O.SEQUENCENO
   ),
   TOTALS AS
   (
       SELECT 
            DropID,
            COUNT(DISTINCT SKU) AS SKU_COUNT,SEQUENCENO,
            SUM(QTY) AS TOTAL_QTY,
            SUM(QTY * GrossWeight) AS TOTAL_WEIGHT
       FROM BASE  WITH (NOLOCK)
       GROUP BY DropID,SEQUENCENO
   ),
   COUNTS AS 
   (SELECT MAX(NOTES) AS MAXES,ORDERKEY FROM PICKDETAIL WITH (NOLOCK) PD WHERE ORDERKEY=(SELECT TOP 1 ORDERKEY FROM PICKDETAIL  WITH (NOLOCK)  WHERE DROPID=RIGHT(@c_Sparm1,18))
   GROUP BY ORDERKEY
   )

   INSERT INTO #Result
   SELECT 
       ''Maersk Export warehouse - Fredericia'', --1
       CONVERT(NVARCHAR,GETDATE(),104),          --2
       MAX(O.ExternOrderKey),                    --3
       MAX(O.BuyerPO),                           --4
       MAX(O.ExternOrderKey),                    --5
       MAX(O.ConsigneeKey),                      --6
       MAX(W.UserDefine01),                      --7
       MAX(O.Route),                             --8
       MAX(O.C_Company),                         --9
       MAX(O.C_Address1),                        --10
       MAX(O.C_City),                            --11
       MAX(O.C_Zip),                             --12
       MAX(O.C_Country),                         --13
       MAX(O.C_ISOCntryCode),                    --14
       NULL,                                     --15
       CAST(SUM(T.TOTAL_WEIGHT) AS DECIMAL(18,3)),--16
       CAST(SUM(T.TOTAL_QTY) AS INT),            --17
       SUBSTRING( B.DropID,1,17),                                --18
       NULL,NULL,NULL,NULL,NULL,NULL,            --19-24
       CAST(SUM(T.TOTAL_QTY) AS INT),            --25
       CAST(SUM(T.TOTAL_QTY) AS INT),            --26
       CAST(SUM(T.TOTAL_WEIGHT) AS DECIMAL(18,3)),--27
       MAX(B.NOTES),                             --28
       
       C.MAXES,B.DROPID,B.SEQUENCENO,NULL,NULL,NULL,NULL,NULL,
       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
   FROM BASE B WITH (NOLOCK)
   JOIN TOTALS T  WITH (NOLOCK) ON T.DropID=B.DropID AND T.SKU_COUNT > 1
   JOIN ORDERS O  WITH (NOLOCK) ON O.ORDERKEY=B.ORDERKEY
   LEFT JOIN WAVE W WITH (NOLOCK) ON W.WAVEKEY=B.WAVEKEY
   JOIN COUNTS C WITH (NOLOCK) ON C.ORDERKEY=O.ORDERKEY
   GROUP BY B.DropID,C.MAXES,B.SEQUENCENO

   UNION ALL

   SELECT 
       ''Maersk Export warehouse - Fredericia'', --1
       CONVERT(NVARCHAR,GETDATE(),104),          --2
       O.ExternOrderKey,                         --3
       O.BuyerPO,                                --4
       O.ExternOrderKey,                         --5
       O.ConsigneeKey,                           --6
       W.UserDefine01,                           --7
       O.Route,                                  --8
       O.C_Company,                              --9
       O.C_Address1,                             --10
       O.C_City,                                 --11
       O.C_Zip,                                  --12
       O.C_Country,                              --13
       O.C_ISOCntryCode,                         --14
      CASE     WHEN LEFT(U.UPC, 1) = ''0''        THEN SUBSTRING(U.UPC, 2, 13)    ELSE         SUBSTRING(U.UPC, 1, 13) END AS UPC ,                                   --15
       CAST((B.QTY * B.GrossWeight) AS DECIMAL(18,3)), --16
       CAST(B.QTY AS INT),                       --17
      SUBSTRING( B.DropID,1,17),                                 --18
       CONVERT(NVARCHAR,LA.LOTTABLE04,104),      --19
       B.SKU,                                    --20
       B.SKU,                                    --21
       
CASE     WHEN LEFT(U.UPC, 1) = ''0''        THEN SUBSTRING(U.UPC, 2, 13)    ELSE         SUBSTRING(U.UPC, 1, 13) END AS UPC2  ,                               --22
       S.DESCR,                                  --23
       CONVERT(NVARCHAR,LA.LOTTABLE04,104),      --24
       CAST(B.QTY AS INT),                       --25
       CAST(T.TOTAL_QTY AS INT),                 --26
       CAST((B.QTY * B.GrossWeight) AS DECIMAL(18,3)), --27
       B.NOTES,                                  --28
       -- pad to 60
      C.MAXES,B.DROPID,B.SEQUENCENO,FORMAT(LA.LOTTABLE04,''ddMMyy''),NULL,NULL,NULL,NULL,
       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
   FROM BASE B WITH (NOLOCK)
   JOIN TOTALS T  WITH (NOLOCK) ON T.DropID=B.DropID AND T.SKU_COUNT = 1
   JOIN ORDERS O WITH (NOLOCK) ON O.ORDERKEY=B.ORDERKEY
   JOIN SKU S WITH (NOLOCK) ON S.SKU=B.SKU AND S.STORERKEY=O.STORERKEY
   LEFT JOIN WAVE W WITH (NOLOCK)  ON W.WAVEKEY=B.WAVEKEY
    JOIN COUNTS C ON C.ORDERKEY=O.ORDERKEY
   OUTER APPLY
   (
       SELECT TOP 1 UPC
       FROM UPC U WITH (NOLOCK)
       WHERE U.SKU=B.SKU AND U.STORERKEY=O.STORERKEY AND LEN(U.UPC)=13
       ORDER BY U.UOM
   ) U
   LEFT JOIN LOTATTRIBUTE LA WITH (NOLOCK)
       ON LA.SKU=B.SKU
       AND LA.LOT=B.LOT
       AND LA.STORERKEY=O.STORERKEY
   '

   EXEC sp_executesql @SQL,
       N'@c_Sparm1 NVARCHAR(250)',
       @c_Sparm1

   SELECT * FROM #Result

END
