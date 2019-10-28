--筛选出通勤车早上第一个trip的OD点对

--筛选出车辆早高峰的D点信息
SELECT CAR_NUM , Cap_Date , XXYY --筛选出D点的信息
FROM
( --该临时表是--该临时表是所有可能的Destination信息及其出现时间排序
select CAR_NUM , Cap_Date , XXYY , 
    row_number() over (PARTITION BY CAR_NUM ORDER BY CAP_DATE ASC) AS row_number
FROM
(  --该临时表是所有可能的Destination信息
select CAR_NUM , Cap_Date , XXYY 
FROM
( -- 该临时表为各通勤车上午被检测的时间地点以及下一个被检测的时间
select CAR_NUM , Cap_Date , XXYY , 
    ((CAP_DATE_NEXT - CAP_DATE) * 24) as DeltaTime  --相邻被检测时间差,单位是小时
FROM
(--该临时表为0601各通勤车上午的被卡口检测情况以及上个被检测时间
select CAR_NUM , CAP_DATE , XXYY , 
    LEAD(CAP_DATE ,1 , NULL) OVER (PARTITION BY CAR_NUM ORDER BY CAP_DATE ASC) AS CAP_DATE_NEXT
FROM
(--该临时表为0601各通勤车上午的被卡口检测情况
select CAR_NUM , Cap_Date , XXYY 
FROM HZ0601V
WHERE (CAR_NUM IN (select CAR_NUM FROM COMMUTER_CAR))
    AND (To_Char(Cap_Date,'yyyy/mm/dd hh24:mi:ss') Between '2016/06/01 05:00:00' And '2016/06/01 12:00:00')
order by CAR_NUM ASC , CAP_DATE ASC
) CC_INFO
) CC_INFO2
) CC_INFO3
where DeltaTime is NULL or DeltaTime > 1   --筛选出DELTATIME是NULL或是大于1小时的, 这是D的两个可能情况
) CC_Des
) CC_Des2
where row_number = 1


--筛选出车辆早高峰的O点信息
SELECT CAR_NUM , CAP_DATE , XXYY
FROM
( --通勤车辆上午的卡口被检测信息
select CAR_NUM , CAP_DATE , XXYY , row_number() OVER (PARTITION BY CAR_NUM ORDER BY CAP_DATE ASC) AS row_number
FROM
HZ0601V
WHERE (CAR_NUM IN (select CAR_NUM FROM COMMUTER_CAR))
    AND (To_Char(Cap_Date,'yyyy/mm/dd hh24:mi:ss') Between '2016/06/01 05:00:00' And '2016/06/01 12:00:00')
) CC_INFO
WHERE row_number = 1