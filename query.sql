create or alter procedure SITE_GET_EMPLOYEES
returns (
    ID bigint,
    FULL_NAME varchar(255),
    SEX varchar(25),
    IS_GRADUATE varchar(25),
    RANG varchar(50),
    CATEGORY varchar(50),
    POSITION_NAME varchar(4000),
    EDU varchar(4000),
    RETRAINING varchar(4000),
    REFRESHER_COURSES varchar(4000),
    EXPERIENCE varchar(4000),
    MEDALS varchar(4000),
    TEACH_DISCIPLINES varchar(4000))
as
BEGIN
    FOR
        SELECT L14.obj_id AS ID
               ,V59.val || ' ' || V60.val || ' ' || COALESCE(V61.val, '') AS FULL_NAME
               --,V73.val AS START_DATE
               ,R239.val AS SEX
               ,R279.val AS IS_GRADUATE
               ,R280.val AS RANG
               ,R281.val AS CATEGORY
               ,LIST(v66.val,', ') AS POSITION_NAME
               --,v66.val AS POSITION_NAME
               --,v589.val
               ,E.EDU AS EDU
               ,RET.RETRAINING AS RETRAINING
               ,REF.REFRESHER_COURSES AS REFRESHER_COURSES
               ,EXP.EXPERIENCE as EXPERIENCE
               ,NULLIF(
                    TRIM(BOTH ', '
                        FROM
                        COALESCE(
                            CASE WHEN MED38.VAL IS NOT NULL AND MED38.VAL <> '' THEN MED38.VAL ELSE '' END ||
                            CASE WHEN MED39.VAL IS NOT NULL AND MED39.VAL <> '' THEN ', ' || MED39.VAL ELSE '' END ||
                            CASE WHEN MED40.VAL IS NOT NULL AND MED40.VAL <> '' THEN ', ' || MED40.VAL ELSE '' END ||
                            CASE WHEN ACHIEV41.VAL IS NOT NULL AND ACHIEV41.VAL <> '' THEN ', ' || ACHIEV41.VAL ELSE '' END ||
                            CASE WHEN ACHIEV42.VAL IS NOT NULL AND ACHIEV42.VAL <> '' THEN ', ' || ACHIEV42.VAL ELSE '' END,
                            ''
                        )
                    ),
                    ''
                ) AS MEDALS
               ,TEACH.DISCIPLINES AS TEACH_DISCIPLINES
--               ,CASE
--                    WHEN V240.blob_id IS NOT NULL THEN
--                        '{"id": "' || V240.blob_id || '", "name": "' || REPLACE(COALESCE(V240.val, ''), '"', '\"') || '"}'
--                    ELSE
--                        NULL
--                END AS PIC
        FROM LINKS L14
            JOIN VALS V59 ON V59.OBJ_ID = L14.OBJ_ID AND V59.PARAM_ID = 59 --Фамилия
            JOIN VALS V60 ON V60.OBJ_ID = L14.OBJ_ID AND V60.PARAM_ID = 60 --Имя
            LEFT JOIN VALS V61 ON V61.OBJ_ID = L14.OBJ_ID AND V61.PARAM_ID = 61 --Отчество
--            LEFT JOIN VALB V240 ON V240.OBJ_ID = L14.OBJ_ID AND V240.PARAM_ID = 240 AND V240.IS_DEL = 0 --Картинка

            JOIN VALL V239 ON V239.OBJ_ID = L14.OBJ_ID AND V239.PARAM_ID = 239 AND V239.IS_DEL = 0 --ссылка на пол
            JOIN LISTVALS LV239 ON LV239.LISTVAL_ID = V239.LISTVAL_ID
            LEFT JOIN RES_GET(LV239.RES_ID,  'RU') R239 ON 1 = 1
            
            JOIN VALL V279 ON V279.OBJ_ID = L14.OBJ_ID AND V279.PARAM_ID = 279 AND V279.IS_DEL = 0 --ссылка на степень
            JOIN LISTVALS LV279 ON LV279.LISTVAL_ID = V279.LISTVAL_ID
            LEFT JOIN RES_GET(LV279.RES_ID,  'RU') R279 ON 1 = 1
            
            JOIN VALL V280 ON V280.OBJ_ID = L14.OBJ_ID AND V280.PARAM_ID = 280 AND V280.IS_DEL = 0 --ссылка на звание
            JOIN LISTVALS LV280 ON LV280.LISTVAL_ID = V280.LISTVAL_ID
            LEFT JOIN RES_GET(LV280.RES_ID,  'RU') R280 ON 1 = 1

            JOIN VALL V281 ON V281.OBJ_ID = L14.OBJ_ID AND V281.PARAM_ID = 281 AND V281.IS_DEL = 0 --ссылка на категорию
            JOIN LISTVALS LV281 ON LV281.LISTVAL_ID = V281.LISTVAL_ID
            LEFT JOIN RES_GET(LV281.RES_ID,  'RU') R281 ON 1 = 1

            JOIN LINKS L15 ON L15.PARENT_ID = L14.OBJ_ID AND L15.OBJ_TYPE_ID = 15 AND L15.DATE_DEL IS NULL
--            JOIN VALD V73 ON V73.OBJ_ID = L15.OBJ_ID AND V73.PARAM_ID = 73 AND V73.IS_DEL = 0 --Дата начала работы
            LEFT JOIN VALD V74 ON V74.OBJ_ID = L15.OBJ_ID AND V74.PARAM_ID = 74 AND V74.IS_DEL = 0 -- Дата уволнения

            JOIN LINKS LP13 ON LP13.OBJ_ID = L15.OBJ_ID AND LP13.PARENT_TYPE_ID = 13 AND LP13.DATE_DEL IS NULL
            JOIN VALS V66 ON V66.OBJ_ID = LP13.PARENT_ID AND V66.PARAM_ID = 66 AND V66.IS_DEL = 0  -- Должность из текстового поля
--            JOIN VALS V589 ON V589.OBJ_ID = LP13.PARENT_ID AND V589.PARAM_ID = 589 AND V589.IS_DEL = 0  -- Тоже должность от куда хз

            LEFT JOIN(
                SELECT L33.PARENT_ID,
                    '[' || LIST('{"name": "' || REPLACE(COALESCE(V285.val, ''), '"', '\"') || '", "speciality": "' || COALESCE(V292.val, '') || '", "direction": "' || COALESCE(V291.val, '') || '", "level": "' || COALESCE(R284.VAL, '')|| '", "pedType": "' || COALESCE(R293.VAL, '') || '", "date": "' || COALESCE(V290.val, '') || '"}', ', ') || ']' AS EDU
                FROM LINKS L33
                    LEFT JOIN VALS V285 ON V285.OBJ_ID = L33.OBJ_ID AND V285.PARAM_ID = 285 AND V285.IS_DEL = 0 -- Название ОУ
                    LEFT JOIN VALS V292 ON V292.OBJ_ID = L33.OBJ_ID AND V292.PARAM_ID = 292 AND V292.IS_DEL = 0 -- Квалификаци, должность по диплому
                    LEFT JOIN VALS V291 ON V291.OBJ_ID = L33.OBJ_ID AND V291.PARAM_ID = 291 AND V291.IS_DEL = 0 -- Направление подготовки
                    LEFT JOIN VALD V290 ON V290.OBJ_ID = L33.OBJ_ID AND V290.PARAM_ID = 290 AND V290.IS_DEL = 0 --Дата вручения
                    LEFT JOIN VALL V284 ON V284.OBJ_ID = L33.OBJ_ID AND V284.PARAM_ID = 284 AND V284.IS_DEL = 0 --Ссылка на тип уровня
                    LEFT JOIN LISTVALS LV284 ON LV284.LISTVAL_ID = V284.LISTVAL_ID
                    LEFT JOIN RES_GET(LV284.RES_ID,  'RU') R284 ON 1 = 1 --Получаем текст типа уровня
                    LEFT JOIN VALL V293 ON V293.OBJ_ID = L33.OBJ_ID AND V293.PARAM_ID = 293 AND V293.IS_DEL = 0 --Ссылка на тип направленности
                    LEFT JOIN LISTVALS LV293 ON LV293.LISTVAL_ID = V293.LISTVAL_ID
                    LEFT JOIN RES_GET(LV293.RES_ID,  'RU') R293 ON 1 = 1 --Получаем текст типа направленности
                WHERE L33.OBJ_TYPE_ID = 33
                    AND L33.DATE_DEL IS NULL
                GROUP BY L33.PARENT_ID
            ) E ON E.PARENT_ID = L14.OBJ_ID

            LEFT JOIN (
                SELECT L35.PARENT_ID,
                    '[' || LIST('{"name": "' || REPLACE(COALESCE(V296.val, ''), '"', '\"') || '", "speciality": "' || REPLACE(COALESCE(V302.val, ''), '"', '\"') || '", "direction": "' || REPLACE(COALESCE(V301.val, ''), '"', '\"') || '", "date": "' || COALESCE(V300.val, '') || '"}', ', ') || ']' AS RETRAINING
                FROM LINKS L35
                    LEFT JOIN VALS V296 ON V296.OBJ_ID = L35.OBJ_ID AND V296.PARAM_ID = 296 AND V296.IS_DEL = 0 -- Название ОУ Переподготовки
                    LEFT JOIN VALS V302 ON V302.OBJ_ID = L35.OBJ_ID AND V302.PARAM_ID = 302 AND V302.IS_DEL = 0 -- Специальность переподготовки
                    LEFT JOIN VALS V301 ON V301.OBJ_ID = L35.OBJ_ID AND V301.PARAM_ID = 301 AND V301.IS_DEL = 0 -- Направленность подготовки
                    LEFT JOIN VALD V300 ON V300.OBJ_ID = L35.OBJ_ID AND V300.PARAM_ID = 300 AND V300.IS_DEL = 0 -- Дата подготовки
                WHERE L35.OBJ_TYPE_ID = 35
                  AND L35.DATE_DEL IS NULL
                GROUP BY L35.PARENT_ID
            ) RET ON RET.PARENT_ID = L14.OBJ_ID

            LEFT JOIN (
                SELECT L36.PARENT_ID, 
                    '[' || LIST('{"company": "' || REPLACE(COALESCE(V2335.val, ''), '"', '\"') || '", "title": "' || REPLACE(COALESCE(V305.val, ''), '"', '\"') || '", "hours": "' || COALESCE(V306.val, '') || '", "date": "' || COALESCE(V310.val, '') || '"}', ', ') || ']' AS REFRESHER_COURSES
                FROM LINKS L36
--                    LEFT JOIN VALS V304 ON V304.OBJ_ID = L36.OBJ_ID AND V304.PARAM_ID = 304 AND V304.IS_DEL = 0 -- Полное название ОУ КПК
                    LEFT JOIN VALS V2335 ON V2335.OBJ_ID = L36.OBJ_ID AND V2335.PARAM_ID = 2335 AND V2335.IS_DEL = 0 -- Название ОУ КПК
                    LEFT JOIN VALS V305 ON V305.OBJ_ID = L36.OBJ_ID AND V305.PARAM_ID = 305 AND V305.IS_DEL = 0 -- Название КПК
                    LEFT JOIN VALI V306 ON V306.OBJ_ID = L36.OBJ_ID AND V306.PARAM_ID = 306 AND V306.IS_DEL = 0 -- Количество часов
                    LEFT JOIN VALD V310 ON V310.OBJ_ID = L36.OBJ_ID AND V310.PARAM_ID = 310 AND V310.IS_DEL = 0 -- Дата
                WHERE L36.OBJ_TYPE_ID = 36
                  AND L36.DATE_DEL IS NULL
                GROUP BY L36.PARENT_ID
            ) REF ON REF.PARENT_ID = L14.OBJ_ID
            
            LEFT JOIN (
                SELECT 
                    E.PARENT_ID AS PARENT_ID,
                    '[' || LIST(
                        '{"type": "' || COALESCE(R.VAL, '') || 
                        '", "years": "' || E.TOTAL_YEARS ||
                        '", "months": "' || E.TOTAL_MONTHS ||
                        '", "days": "' || E.TOTAL_DAYS || '"}',
                        ', ') || ']' AS EXPERIENCE
                FROM (
                    SELECT 
                        L85.PARENT_ID,
                        V465.LISTVAL_ID AS LISTVAL_ID,
                        SUM(GCD.DAYS360_COUNT) / 360 AS TOTAL_YEARS,
                        MOD(SUM(GCD.DAYS360_COUNT), 360) / 30  AS TOTAL_MONTHS,
                        MOD(SUM(GCD.DAYS360_COUNT), 30) AS TOTAL_DAYS
                    FROM LINKS L85
                        LEFT JOIN VALL V465 ON V465.OBJ_ID = L85.OBJ_ID AND V465.PARAM_ID = 465 AND V465.IS_DEL = 0 -- ССылка на название
                        LEFT JOIN VALD V466 ON V466.OBJ_ID = L85.OBJ_ID AND V466.PARAM_ID = 466 AND V466.IS_DEL = 0 -- Дата начала
                        LEFT JOIN VALD V467 ON V467.OBJ_ID = L85.OBJ_ID AND V467.PARAM_ID = 467 AND V467.IS_DEL = 0 -- Дата конца
                        LEFT JOIN GET_DAYS360_COUNT(V466.val, COALESCE(V467.val, CURRENT_DATE)) GCD ON 1=1
                    WHERE L85.OBJ_TYPE_ID = 85
                      AND L85.DATE_DEL IS NULL
                    GROUP BY L85.PARENT_ID, V465.LISTVAL_ID
                ) AS E
                JOIN LISTVALS L ON L.LISTVAL_ID = E.LISTVAL_ID
                    LEFT JOIN RES_GET(L.RES_ID, 'RU') R ON 1 = 1
                GROUP BY E.PARENT_ID
            ) EXP ON EXP.PARENT_ID = L14.OBJ_ID

            LEFT JOIN (
                SELECT L51.PARENT_ID,
                    LIST(COALESCE(V376.val, ''),', ') AS DISCIPLINES
                FROM LINKS L51
                  LEFT JOIN VALS V376 ON V376.OBJ_ID = L51.OBJ_ID AND V376.PARAM_ID = 376 AND V376.IS_DEL = 0
                WHERE L51.OBJ_TYPE_ID = 51
                  AND L51.DATE_DEL IS NULL
                GROUP BY L51.PARENT_ID
            ) TEACH ON TEACH.PARENT_ID = L14.OBJ_ID

            LEFT JOIN (
                SELECT L38.PARENT_ID,
                    LIST(R337.val || ' от ' || V339.val,', ') AS VAL
                FROM LINKS L38 --медаль "В память 300-летия Санкт-Петербурга" чек337
                    JOIN VALD V339 ON V339.OBJ_ID = L38.OBJ_ID AND V339.PARAM_ID = 339 AND V339.IS_DEL = 0 -- Дата присвоения
                    JOIN VALL V337 ON V337.OBJ_ID = L38.OBJ_ID AND V337.PARAM_ID = 337 AND V337.IS_DEL = 0
                    JOIN LISTVALS LV337 ON LV337.LISTVAL_ID = V337.LISTVAL_ID
                    LEFT JOIN RES_GET(LV337.RES_ID,  'RU') R337 ON 1 = 1
                WHERE L38.OBJ_TYPE_ID = 38
                  AND L38.DATE_DEL IS NULL
                GROUP BY L38.PARENT_ID
            ) MED38 ON MED38.PARENT_ID = L14.OBJ_ID

            LEFT JOIN (
                SELECT L39.PARENT_ID,
                --L39.obj_id,
                    LIST(R345.val || ' от ' || V347.val,', ') AS VAL
                FROM LINKS L39 --знак "Почетный работник общего образования РФ" чек345
                    JOIN VALD V347 ON V347.OBJ_ID = L39.OBJ_ID AND V347.PARAM_ID = 347 AND V347.IS_DEL = 0 -- Дата присвоения
                    JOIN VALL V345 ON V345.OBJ_ID = L39.OBJ_ID AND V345.PARAM_ID = 345 AND V345.IS_DEL = 0
                    JOIN LISTVALS LV345 ON LV345.LISTVAL_ID = V345.LISTVAL_ID
                    LEFT JOIN RES_GET(LV345.RES_ID,  'RU') R345 ON 1 = 1
                WHERE L39.OBJ_TYPE_ID = 39
                  AND L39.DATE_DEL IS NULL
                GROUP BY L39.PARENT_ID
            ) MED39 ON MED39.PARENT_ID = L14.OBJ_ID

            LEFT JOIN (
                SELECT L40.PARENT_ID,
                    --L40.obj_id
                    LIST(COALESCE(R341.val,'') || ' от ' || V343.val,', ') AS VAL
                FROM LINKS L40 --Знак "За гуманизацию школы Санкт-Петербурга" чек341 может что-то быть в 342, но повреждено извлекается как просто число, а не ссылка из таблицы ссылок
                    JOIN VALD V343 ON V343.OBJ_ID = L40.OBJ_ID AND V343.PARAM_ID = 343 AND V343.IS_DEL = 0 -- Дата присвоения
                    LEFT JOIN VALL V341 ON V341.OBJ_ID = L40.OBJ_ID AND V341.PARAM_ID = 341 AND V341.IS_DEL = 0
                    JOIN LISTVALS LV341 ON LV341.LISTVAL_ID = V341.LISTVAL_ID
                    LEFT JOIN RES_GET(LV341.RES_ID,  'RU') R341 ON 1 = 1
                WHERE L40.OBJ_TYPE_ID = 40
                  AND L40.DATE_DEL IS NULL
                GROUP BY L40.PARENT_ID
            ) MED40 ON MED40.PARENT_ID = L14.OBJ_ID

            LEFT JOIN (
                SELECT L41.PARENT_ID,
                     LIST(V349.val || ' год ' || COALESCE(R350.val,'') || ' ' || COALESCE(R351.val,''),', ') AS VAL
                FROM LINKS L41 --Какие то достижения 349 год, 350 статус(победитель и т.д), 351 уровень(район) всё извлекать VALL и ренсить, кроме года он VALLD
                    JOIN VALI V349 ON V349.OBJ_ID = L41.OBJ_ID AND V349.PARAM_ID = 349 AND V349.IS_DEL = 0  --Год Int
                    JOIN VALL V350 ON V350.OBJ_ID = L41.OBJ_ID AND V350.PARAM_ID = 350 AND V350.IS_DEL = 0
                    JOIN LISTVALS LV350 ON LV350.LISTVAL_ID = V350.LISTVAL_ID
                    LEFT JOIN RES_GET(LV350.RES_ID,  'RU') R350 ON 1 = 1
                    JOIN VALL V351 ON V351.OBJ_ID = L41.OBJ_ID AND V351.PARAM_ID = 351 AND V351.IS_DEL = 0
                    JOIN LISTVALS LV351 ON LV351.LISTVAL_ID = V351.LISTVAL_ID
                    LEFT JOIN RES_GET(LV351.RES_ID,  'RU') R351 ON 1 = 1
                WHERE L41.OBJ_TYPE_ID = 41
                  AND L41.DATE_DEL IS NULL
                GROUP BY L41.PARENT_ID
            ) ACHIEV41 ON ACHIEV41.PARENT_ID = L14.OBJ_ID

            LEFT JOIN (
                SELECT L42.PARENT_ID,
                     LIST(R353.val || ' в ' || V352.val || ' году',', ') AS VAL
                FROM LINKS L42 --Лучший учитель в общем какие то достижения год в 352, название чек353 VALL
                    JOIN VALI V352 ON V352.OBJ_ID = L42.OBJ_ID AND V352.PARAM_ID = 352 AND V352.IS_DEL = 0 -- Год Int
                    JOIN VALL V353 ON V353.OBJ_ID = L42.OBJ_ID AND V353.PARAM_ID = 353 AND V353.IS_DEL = 0
                    JOIN LISTVALS LV353 ON LV353.LISTVAL_ID = V353.LISTVAL_ID
                    LEFT JOIN RES_GET(LV353.RES_ID,  'RU') R353 ON 1 = 1
                WHERE L42.OBJ_TYPE_ID = 42
                  AND L42.DATE_DEL IS NULL
                GROUP BY L42.PARENT_ID
            ) ACHIEV42 ON ACHIEV42.PARENT_ID = L14.OBJ_ID

            --JOIN LINKS L33 ON L33.PARENT_ID = L14.OBJ_ID AND L33.OBJ_TYPE_ID = 33 AND L33.DATE_DEL IS NULL
            --LEFT JOIN OBJECT_PARAMS(L35.obj_id) VL300 ON VL300.PARAM_ID = 300
            --38,39,40,41,42,43,44,395,51

--            JOIN LINKS L38 ON L38.PARENT_ID = L14.OBJ_ID AND L38.OBJ_TYPE_ID = 38 AND L38.DATE_DEL IS NULL --медаль "В память 300-летия Санкт-Петербурга" чек337
--            LEFT JOIN OBJECT_PARAMS(L38.obj_id) VL40 ON 1=1

--            JOIN LINKS L39 ON L39.PARENT_ID = L14.OBJ_ID AND L39.OBJ_TYPE_ID = 39 AND L39.DATE_DEL IS NULL --знак "Почетный работник общего образования РФ" чек345
--            LEFT JOIN OBJECT_PARAMS(L39.obj_id) VL39 ON 1=1

--            JOIN LINKS L40 ON L40.PARENT_ID = L14.OBJ_ID AND L40.OBJ_TYPE_ID = 40 AND L40.DATE_DEL IS NULL --Знак "За гуманизацию школы Санкт-Петербурга" чек341
--            LEFT JOIN OBJECT_PARAMS(L40.obj_id) VL40 ON 1=1

--            JOIN LINKS L41 ON L41.PARENT_ID = L14.OBJ_ID AND L41.OBJ_TYPE_ID = 41 AND L41.DATE_DEL IS NULL --Какие то достижения 349 год, 350 статус(победитель и т.д), 351 уровень(район) всё извлекать VALL и ренсить, кроме года он VALLD
--            LEFT JOIN OBJECT_PARAMS(L41.obj_id) VL41 ON 1=1

--            JOIN LINKS L42 ON L42.PARENT_ID = L14.OBJ_ID AND L42.OBJ_TYPE_ID = 42 AND L42.DATE_DEL IS NULL --Лучший учитель в общем какие то достижения год в 352, название чек353 VALL
--            LEFT JOIN OBJECT_PARAMS(L42.obj_id) VL42 ON 1=1

--            JOIN LINKS L43 ON L43.PARENT_ID = L14.OBJ_ID AND L43.OBJ_TYPE_ID = 43 AND L43.DATE_DEL IS NULL --Какие то электронные публикации есть только Вики
--            LEFT JOIN OBJECT_PARAMS(L43.obj_id) VL43 ON 1=1

--            JOIN LINKS L395 ON L395.PARENT_ID = L14.OBJ_ID AND L395.OBJ_TYPE_ID = 395 AND L395.DATE_DEL IS NULL --КПК по бжд
--            LEFT JOIN OBJECT_PARAMS(L395.obj_id) VL395 ON 1=1

        WHERE L14.PARENT_TYPE_ID = 2
            AND L14.OBJ_TYPE_ID = 14
            AND L14.DATE_DEL is null
            AND V74.VAL is null
        GROUP BY ID
            ,FULL_NAME
            ,SEX
            ,IS_GRADUATE
            ,RANG
            ,CATEGORY
            ,EDU
            ,RETRAINING
            ,REFRESHER_COURSES
            ,EXPERIENCE
            ,MEDALS
            ,TEACH_DISCIPLINES
--            ,PIC
        ORDER BY FULL_NAME, POSITION_NAME
    INTO :ID
        ,:FULL_NAME
--        ,:START_DATE
        ,:SEX
        ,:IS_GRADUATE
        ,:RANG
        ,:CATEGORY
        ,:POSITION_NAME
--        ,:JOB_TITLE
        ,:EDU
        ,:RETRAINING
        ,:REFRESHER_COURSES
        ,:EXPERIENCE
        ,:MEDALS
        ,:TEACH_DISCIPLINES
--        ,:PIC
    DO
    BEGIN
        SUSPEND;
    END
END