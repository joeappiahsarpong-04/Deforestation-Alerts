SELECT TOP (10000) [tile_id]
      ,[downLOAD]
      ,[ObjectId]
      ,[Shape_Area]
      ,[Shape_Length]
 FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]

--Total Records In Dataset

SELECT SUM(shape_area) AS Total_Area
FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)];

--Total recorded area

Select Sum(distinct[shape_area]) AS Total_Area
From [DEFORESTATION].[dbo].[deforestation_alerts_(RADD)];

--The Average Area Per Record

Select Avg([Shape_area])AS Average_Area_Per_Record
From [DEFORESTATION].[dbo].[deforestation_alerts_(RADD)];

--Tile With Hghest Shape Area

Select [tile_id], [Shape_Area] As Highest_Shape_Area
From [DEFORESTATION].[dbo].[deforestation_alerts_(RADD)]
where [shape_area] =(
Select Max([Shape_area])
From [DEFORESTATION].[dbo].[deforestation_alerts_(RADD)]);

-- top 10 tiles in the data

SELECT TOP 10
    tile_id,
    SUM(shape_area) AS Total_Area
FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]
GROUP BY tile_id
ORDER BY Total_Area DESC;

 --Percentage Of Each Tile

 Select [tile_id],Sum(shape_area) * 100.0 / (select sum (shape_area) FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)])
 AS Percentage
 FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]
 Group by [tile_id]

 --ANY MISSING VALUES?

 Select Count (*) AS Missing_Download
 FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]
 where [download] IS NULL
 Select [objectid], Count(*) AS Duplicates
 FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]
 Group by objectid Having COunt(*) > 1

 -- How many tiles are larger than the average

SELECT COUNT(DISTINCT tile_id) AS Tiles_Larger_Than_Average
FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]
WHERE shape_area > (
    SELECT AVG(shape_area)
    FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]
);

--Tile with longest perimeter

SELECT TOP 1
    [tile_id],
    [download],
    [shape_area],
    [shape_length]
FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]
ORDER BY [shape_length] DESC;

--Area-to-perimeter  ratio of each tile (where higher means more Impact

SELECT
    tile_id,
    shape_area,
    shape_length,
    ROUND(
        shape_area / NULLIF(shape_length, 0),
        4
    ) AS Area_To_Perimeter_Ratio
FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]
ORDER BY Area_To_Perimeter_Ratio DESC;

--Total area and average area of its latitude band

SELECT
    t.[tile_id],
    t.[shape_area] AS Tile_Area,
    b.Latitude_Band,
    b.Total_Band_Area,
    b.Average_Band_Area,
    b.Number_of_Tiles_In_Band,

    -- Compare each tile with its band's average
    ROUND(
        t.[shape_area] - b.Average_Band_Area, 2
    ) AS Difference_From_Band_Average,

    -- Percentage difference from the band average
    ROUND(
        ((t.[shape_area] - b.Average_Band_Area)
        / NULLIF(b.Average_Band_Area, 0)) * 100, 2
    ) AS Percentage_Difference

FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)] AS t

INNER JOIN (
    SELECT
        LEFT([tile_id], 3) AS Latitude_Band,
        COUNT(*) AS Number_of_Tiles_In_Band,
        SUM([shape_area]) AS Total_Band_Area,
        AVG([shape_area]) AS Average_Band_Area

    FROM [DEFORESTATION].[dbo].[Deforestation_alerts_(RADD)]

    GROUP BY LEFT([tile_id], 3)
) AS b

ON LEFT(t.[tile_id], 3) = b.Latitude_Band

ORDER BY
    b.Latitude_Band ASC,
    t.[shape_area] DESC;