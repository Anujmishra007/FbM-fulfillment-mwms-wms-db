SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
/************************************************************************/    
/* Store procedure: rdt_1742GetSuggLOC02                                */    
/* Copyright      : Maersk                                              */    
/*                                                                      */    
/* Purpose: Suggest a LOC for the Drop ID                               */   
/* Date         Rev  Author   Purposes                                  */    
/* 12-May-2025  1.0  SYSOPS  get suugested PND                          */    
/************************************************************************/    
  
CREATE OR ALTER PROC [RDT].[rdt_1742GetSuggLOC02]     
(    
    @nMobile          INT,      
    @nFunc            INT,      
    @cLangCode        NVARCHAR(3),      
    @nStep            INT,       
    @nInputKey        INT,       
    @cStorerKey       NVARCHAR(15),       
    @cFacility        NVARCHAR(5),      
    @cDropID          NVARCHAR(20),      
    @cSuggLOC         NVARCHAR(10)  OUTPUT,      
    @cPickAndDropLOC  NVARCHAR(10)  OUTPUT,      
    @cFitCasesInAisle NVARCHAR(1)   OUTPUT,       
    @nPABookingKey    INT            OUTPUT,      
    @nErrNo           INT            OUTPUT,      
    @cErrMsg          NVARCHAR(20)  OUTPUT      
)     
AS      
BEGIN      
    SET NOCOUNT ON;      
    SET QUOTED_IDENTIFIER OFF;      
    SET ANSI_NULLS OFF;      
    SET CONCAT_NULL_YIELDS_NULL OFF;      
    
    SET @cSuggLOC = '';      
    
    -- Check if ORDER is already mapped to a PND location    
    IF EXISTS (    
        SELECT 1     
        FROM (    
            SELECT ORDERKEY, DROPID, StorerKey     
            FROM dbo.PICKDETAIL PD     
            WHERE PD.StorerKey = @cStorerKey      
              AND PD.DROPID = @cDropID    
        ) PD1    
        JOIN dbo.PICKDETAIL PD2 WITH (NOLOCK)     
            ON PD2.ORDERKEY = PD1.ORDERKEY AND PD2.StorerKey = PD1.StorerKey    
        JOIN dbo.LOC L WITH (NOLOCK)     
            ON L.LOC = PD2.LOC     
           AND L.LocationType = 'PND'     
           AND L.Facility = @cFacility    
    )      
    BEGIN      
        -- Get the PND Loc for the ORDER       
        SELECT TOP 1 @cSuggLOC = LOC.LOC      
        FROM (    
            SELECT ORDERKEY, DROPID, StorerKey     
            FROM dbo.PICKDETAIL PD     
            WHERE PD.StorerKey = @cStorerKey      
              AND PD.DROPID = @cDropID      
        ) PD2     
        JOIN dbo.PICKDETAIL PD3 WITH (NOLOCK)      
            ON PD3.ORDERKEY = PD2.ORDERKEY AND PD3.StorerKey = PD2.StorerKey      
        JOIN dbo.LOC LOC WITH (NOLOCK)     
            ON LOC.LOC = PD3.LOC      
        WHERE LOC.LocationType = 'PND'       
          AND LOC.Facility = @cFacility      
        ORDER BY LOC.LOC;      
END    
        -- If none found, get any PND Loc for the storer    
        IF ISNULL(@cSuggLOC, '') = ''      
        BEGIN      
            SELECT TOP 1 @cSuggLOC = LOC.LOC      
            FROM dbo.LOC LOC WITH (NOLOCK)      
            WHERE LOC.LocationType = 'PND'       
              AND LOC.Facility = @cFacility   
            AND LOC NOT IN (SELECT LOC FROM PICKDETAIL (NOLOCK) WHERE STORERKEY=@cStorerKey    
            AND STATUS='5')     
            ORDER BY LOC.LOC;      
       
        END      
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1742GetSuggLOC02] TO NSQL
GO