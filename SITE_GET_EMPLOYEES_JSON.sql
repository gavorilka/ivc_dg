CREATE OR ALTER PROCEDURE SITE_GET_EMPLOYEES_JSON
    RETURNS (
    TAG_NAME varchar(100),
    VAL varchar(4000)
)
AS
    DECLARE ID bigint;
    DECLARE FULL_NAME varchar(255);
    DECLARE SEX varchar(25);
    DECLARE IS_GRADUATE varchar(25);
    DECLARE RANG varchar(50);
    DECLARE CATEGORY varchar(50);
    DECLARE POSITION_NAME varchar(4000);

    --образование
    DECLARE EDU_NAME varchar(500);
    DECLARE EDU_SPECIALITY varchar(100);
    DECLARE EDU_DIRECTION varchar(100);
    DECLARE EDU_LEVEL varchar(50);
    DECLARE EDU_PED_TYPE varchar(50);
    DECLARE EDU_DATE date;

    --Переподготовка
    DECLARE RET_NAME varchar(500);
    DECLARE RET_SPECIALITY varchar(150);
    DECLARE RET_DIRECTION varchar(250);
    DECLARE RET_DATE date;

    --Повышение квалификации
    DECLARE REF_COMPANY varchar(500);
    DECLARE REF_TITLE varchar(500);
    DECLARE REF_HOURS integer;
    DECLARE REF_DATE date;

    --Опыт
    DECLARE EXP_TYPE varchar(250);
    DECLARE EXP_YEARS integer;
    DECLARE EXP_MONTHS integer;
    DECLARE EXP_DAYS integer;
BEGIN
    -- Открываем массив сотрудников
    TAG_NAME = 'employees::json&colon;array';
    VAL = 1;
    SUSPEND;

    -- Основной запрос для получения данных о сотрудниках
    FOR
        SELECT
            L14.obj_id AS ID
            ,V59.val || ' ' || V60.val || ' ' || COALESCE(V61.val, '') AS FULL_NAME
            ,R239.val AS SEX
            ,R279.val AS IS_GRADUATE
            ,R280.val AS RANG
            ,R281.val AS CATEGORY
            ,LIST(DISTINCT v66.val,', ') AS POSITION_NAME
        FROM
            LINKS L14
            JOIN VALS V59 ON V59.OBJ_ID = L14.OBJ_ID AND V59.PARAM_ID = 59 --Фамилия
            JOIN VALS V60 ON V60.OBJ_ID = L14.OBJ_ID AND V60.PARAM_ID = 60 --Имя
            LEFT JOIN VALS V61 ON V61.OBJ_ID = L14.OBJ_ID AND V61.PARAM_ID = 61 --Отчество

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
            LEFT JOIN VALD V74 ON V74.OBJ_ID = L15.OBJ_ID AND V74.PARAM_ID = 74 AND V74.IS_DEL = 0 -- Дата уволнения

            JOIN LINKS LP13 ON LP13.OBJ_ID = L15.OBJ_ID AND LP13.PARENT_TYPE_ID = 13 AND LP13.DATE_DEL IS NULL
            JOIN VALS V66 ON V66.OBJ_ID = LP13.PARENT_ID AND V66.PARAM_ID = 66 AND V66.IS_DEL = 0  -- Должность из текстового поля

        WHERE
            L14.PARENT_TYPE_ID = 2
            AND L14.OBJ_TYPE_ID = 14
            AND L14.DATE_DEL is null
            AND V74.VAL is null
        GROUP BY
            ID
            ,FULL_NAME
            ,SEX
            ,IS_GRADUATE
            ,RANG
            ,CATEGORY
        HAVING
            LIST(DISTINCT V66.val,', ') LIKE '%Учитель%'
            OR LIST(DISTINCT V66.val,', ') LIKE '%Педагог%'
            OR LIST(DISTINCT V66.val,', ') LIKE '%Воспитатель%'
        ORDER BY FULL_NAME, POSITION_NAME
    INTO
        :ID
        ,:FULL_NAME
        ,:SEX
        ,:IS_GRADUATE
        ,:RANG
        ,:CATEGORY
        ,:POSITION_NAME
    DO
    BEGIN
        -- Открываем новый элемент в массиве
        TAG_NAME = 'employees:person';
        VAL = NULL;
        SUSPEND;

        -- Вставляем данные сотрудника
        TAG_NAME = 'employees:person:id';
        VAL = :ID;
        SUSPEND;

        TAG_NAME = 'employees:person:fullName';
        VAL = :FULL_NAME;
        SUSPEND;

        TAG_NAME = 'employees:person:sex';
        VAL = :SEX;
        SUSPEND;

        TAG_NAME = 'employees:person:graduate';
        VAL = :IS_GRADUATE;
        SUSPEND;

        TAG_NAME = 'employees:person:rang';
        VAL = :RANG;
        SUSPEND;

        TAG_NAME = 'employees:person:category';
        VAL = :CATEGORY;
        SUSPEND;

        TAG_NAME = 'employees:person:positionsName';
        VAL = :POSITION_NAME;
        SUSPEND;

        -- Если есть вложенные JSON-массивы, например, EDU
        TAG_NAME = 'employees:person:edu::json&colon;array';
        VAL = 1;
        SUSPEND;

        FOR
            SELECT
                V285.VAL AS EDU_NAME
                ,V292.VAL AS EDU_SPECIALITY
                ,V291.VAL AS EDU_DIRECTION
                ,R284.VAL AS EDU_LEVEL
                ,R293.VAL AS EDU_PED_TYPE
                ,V290.VAL AS EDU_DATE
            FROM
                LINKS L33
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
                AND L33.PARENT_ID = :ID
                AND L33.DATE_DEL IS NULL
        INTO
            EDU_NAME
            ,EDU_SPECIALITY
            ,EDU_DIRECTION
            ,EDU_LEVEL
            ,EDU_PED_TYPE
            ,EDU_DATE
        DO
        BEGIN
            TAG_NAME = 'employees:person:edu:obj';
            VAL = NULL;
            SUSPEND;

            TAG_NAME = 'employees:person:edu:obj:name';
            VAL = COALESCE(EDU_NAME, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:edu:obj:speciality';
            VAL = COALESCE(EDU_SPECIALITY, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:edu:obj:direction';
            VAL = COALESCE(EDU_DIRECTION, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:edu:obj:level';
            VAL = COALESCE(EDU_LEVEL, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:edu:obj:pedType';
            VAL = COALESCE(EDU_PED_TYPE, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:edu:obj:date';
            VAL = COALESCE(EDU_DATE, NULL);
            SUSPEND;
        END

        TAG_NAME = 'employees:person:retraining::json&colon;array';
        VAL = 1;
        SUSPEND;

        FOR
            SELECT
                V296.VAL AS RET_NAME
                ,V302.VAL AS RET_SPECIALITY
                ,V301.VAL AS RET_DIRECTION
                ,V300.VAL AS RET_DATE
            FROM
                LINKS L35
                LEFT JOIN VALS V296 ON V296.OBJ_ID = L35.OBJ_ID AND V296.PARAM_ID = 296 AND V296.IS_DEL = 0 -- Название ОУ Переподготовки
                LEFT JOIN VALS V302 ON V302.OBJ_ID = L35.OBJ_ID AND V302.PARAM_ID = 302 AND V302.IS_DEL = 0 -- Специальность переподготовки
                LEFT JOIN VALS V301 ON V301.OBJ_ID = L35.OBJ_ID AND V301.PARAM_ID = 301 AND V301.IS_DEL = 0 -- Направленность подготовки
                LEFT JOIN VALD V300 ON V300.OBJ_ID = L35.OBJ_ID AND V300.PARAM_ID = 300 AND V300.IS_DEL = 0 -- Дата подготовки
            WHERE L35.OBJ_TYPE_ID = 35
                AND L35.PARENT_ID = :ID
                AND L35.DATE_DEL IS NULL
        INTO
            RET_NAME
            ,RET_SPECIALITY
            ,RET_DIRECTION
            ,RET_DATE
        DO
        BEGIN
            TAG_NAME = 'employees:person:retraining:obj';
            VAL = NULL;
            SUSPEND;

            TAG_NAME = 'employees:person:retraining:obj:name';
            VAL = COALESCE(RET_NAME, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:retraining:obj:speciality';
            VAL = COALESCE(RET_SPECIALITY, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:retraining:obj:direction';
            VAL = COALESCE(RET_DIRECTION, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:retraining:obj:date';
            VAL = COALESCE(RET_DATE, NULL);
            SUSPEND;
        END

        TAG_NAME = 'employees:person:refresherCourses::json&colon;array';
        VAL = 1;
        SUSPEND;

        FOR
            SELECT
                V2335.VAL AS REF_COMPANY
                ,V305.VAL AS REF_TITLE
                ,V306.VAL AS REF_HOURS
                ,V310.VAL AS REF_DATE
            FROM
                LINKS L36
                LEFT JOIN VALS V2335 ON V2335.OBJ_ID = L36.OBJ_ID AND V2335.PARAM_ID = 2335 AND V2335.IS_DEL = 0 -- Название ОУ КПК
                LEFT JOIN VALS V305 ON V305.OBJ_ID = L36.OBJ_ID AND V305.PARAM_ID = 305 AND V305.IS_DEL = 0 -- Название КПК
                LEFT JOIN VALI V306 ON V306.OBJ_ID = L36.OBJ_ID AND V306.PARAM_ID = 306 AND V306.IS_DEL = 0 -- Количество часов
                LEFT JOIN VALD V310 ON V310.OBJ_ID = L36.OBJ_ID AND V310.PARAM_ID = 310 AND V310.IS_DEL = 0 -- Дата
            WHERE L36.OBJ_TYPE_ID = 36
                AND L36.DATE_DEL IS NULL
                AND L36.PARENT_ID = :ID
                AND V310.VAL >= DATEADD(YEAR, -3, CURRENT_DATE)
        INTO
            REF_COMPANY
            ,REF_TITLE
            ,REF_HOURS
            ,REF_DATE
        DO
        BEGIN
            TAG_NAME = 'employees:person:refresherCourses:obj';
            VAL = NULL;
            SUSPEND;

            TAG_NAME = 'employees:person:refresherCourses:obj:company';
            VAL = COALESCE(REF_COMPANY, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:refresherCourses:obj:title';
            VAL = COALESCE(REF_TITLE, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:refresherCourses:obj:hours';
            VAL = COALESCE(REF_HOURS, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:refresherCourses:obj:date';
            VAL = COALESCE(REF_DATE, NULL);
            SUSPEND;
        END

        TAG_NAME = 'employees:person:experience::json&colon;array';
        VAL = 1;
        SUSPEND;
        FOR
            SELECT
                R.VAL AS EXP_TYPE
                ,E.TOTAL_YEARS + FLOOR((E.TOTAL_MONTHS + FLOOR(E.TOTAL_DAYS / 30)) / 12) AS EXP_YEARS
                ,MOD(E.TOTAL_MONTHS + FLOOR(E.TOTAL_DAYS / 30), 12) AS EXP_MONTHS
                ,MOD(E.TOTAL_DAYS, 30) AS EXP_DAYS
            FROM (
                 SELECT
                     L85.PARENT_ID,
                     V465.LISTVAL_ID AS LISTVAL_ID,
                     -- Получаем результаты из процедуры
                     SUM(G.YEARS) AS TOTAL_YEARS,
                     SUM(G.MONTHS) AS TOTAL_MONTHS,
                     SUM(G.DAYS) AS TOTAL_DAYS
                 FROM
                    LINKS L85
                    LEFT JOIN VALL V465 ON V465.OBJ_ID = L85.OBJ_ID AND V465.PARAM_ID = 465 AND V465.IS_DEL = 0 -- Ссылка на название
                    LEFT JOIN VALD V466 ON V466.OBJ_ID = L85.OBJ_ID AND V466.PARAM_ID = 466 AND V466.IS_DEL = 0 -- Дата начала
                    LEFT JOIN VALD V467 ON V467.OBJ_ID = L85.OBJ_ID AND V467.PARAM_ID = 467 AND V467.IS_DEL = 0 -- Дата конца
                    LEFT JOIN SITE_GET_YEARS_MONTHS_DAYS(V466.val, COALESCE(V467.val, CURRENT_DATE)) G ON 1=1
                 WHERE L85.OBJ_TYPE_ID = 85
                    AND L85.DATE_DEL IS NULL
                    AND L85.PARENT_ID = :ID
                 GROUP BY L85.PARENT_ID, V465.LISTVAL_ID
            ) AS E
                JOIN LISTVALS L ON L.LISTVAL_ID = E.LISTVAL_ID
                LEFT JOIN RES_GET(L.RES_ID, 'RU') R ON 1 = 1
        INTO
            EXP_TYPE
            ,EXP_YEARS
            ,EXP_MONTHS
            ,EXP_DAYS
        DO
        BEGIN
            TAG_NAME = 'employees:person:experience:obj';
            VAL = NULL;
            SUSPEND;

            TAG_NAME = 'employees:person:experience:obj:type';
            VAL = COALESCE(EXP_TYPE, NULL);
            SUSPEND;

            TAG_NAME = 'employees:person:experience:obj:years';
            VAL = EXP_YEARS;
            SUSPEND;

            TAG_NAME = 'employees:person:experience:obj:months';
            VAL = EXP_MONTHS;
            SUSPEND;

            TAG_NAME = 'employees:person:experience:obj:days';
            VAL = EXP_DAYS;
            SUSPEND;
        END

        TAG_NAME = 'employees:person:medals';
        VAL = NULL;
        WITH
            MED38 AS (
                --медаль "В память 300-летия Санкт-Петербурга" чек337
                SELECT
                    L38.PARENT_ID
                     ,LIST(R337.val || ' от ' || V339.val,', ') AS VAL
                FROM
                    LINKS L38
                    JOIN VALD V339 ON V339.OBJ_ID = L38.OBJ_ID AND V339.PARAM_ID = 339 AND V339.IS_DEL = 0 -- Дата присвоения
                    JOIN VALL V337 ON V337.OBJ_ID = L38.OBJ_ID AND V337.PARAM_ID = 337 AND V337.IS_DEL = 0
                    JOIN LISTVALS LV337 ON LV337.LISTVAL_ID = V337.LISTVAL_ID
                    LEFT JOIN RES_GET(LV337.RES_ID,  'RU') R337 ON 1 = 1
                WHERE
                    L38.OBJ_TYPE_ID = 38
                    AND L38.DATE_DEL IS NULL
                    AND L38.PARENT_ID = :ID
                GROUP BY L38.PARENT_ID
            ),
            MED39 AS (
                --знак "Почетный работник общего образования РФ" чек345
                SELECT
                    L39.PARENT_ID
                     --L39.obj_id,
                     ,LIST(R345.val || ' от ' || V347.val,', ') AS VAL
                FROM
                    LINKS L39
                    JOIN VALD V347 ON V347.OBJ_ID = L39.OBJ_ID AND V347.PARAM_ID = 347 AND V347.IS_DEL = 0 -- Дата присвоения
                    JOIN VALL V345 ON V345.OBJ_ID = L39.OBJ_ID AND V345.PARAM_ID = 345 AND V345.IS_DEL = 0
                    JOIN LISTVALS LV345 ON LV345.LISTVAL_ID = V345.LISTVAL_ID
                    LEFT JOIN RES_GET(LV345.RES_ID,  'RU') R345 ON 1 = 1
                WHERE
                    L39.OBJ_TYPE_ID = 39
                    AND L39.DATE_DEL IS NULL
                    AND L39.PARENT_ID = :ID
                GROUP BY L39.PARENT_ID
            ),
            MED40 AS (
                --Знак "За гуманизацию школы Санкт-Петербурга" чек341 может что-то быть в 342, но повреждено извлекается как просто число, а не ссылка из таблицы ссылок
                SELECT
                    L40.PARENT_ID
                     --L40.obj_id
                     ,LIST(COALESCE(R341.val,'') || ' от ' || V343.val,', ') AS VAL
                FROM
                    LINKS L40
                    JOIN VALD V343 ON V343.OBJ_ID = L40.OBJ_ID AND V343.PARAM_ID = 343 AND V343.IS_DEL = 0 -- Дата присвоения
                    LEFT JOIN VALL V341 ON V341.OBJ_ID = L40.OBJ_ID AND V341.PARAM_ID = 341 AND V341.IS_DEL = 0
                    JOIN LISTVALS LV341 ON LV341.LISTVAL_ID = V341.LISTVAL_ID
                    LEFT JOIN RES_GET(LV341.RES_ID,  'RU') R341 ON 1 = 1
                WHERE L40.OBJ_TYPE_ID = 40
                    AND L40.DATE_DEL IS NULL
                    AND L40.PARENT_ID = :ID
                GROUP BY L40.PARENT_ID
            ),
            ACHIEV41 AS (
                --Какие то достижения 349 год, 350 статус(победитель и т.д), 351 уровень(район) всё извлекать VALL и ренсить, кроме года он VALLD
                SELECT
                    L41.PARENT_ID
                     ,LIST(V349.val || ' год ' || COALESCE(R350.val,'') || ' ' || COALESCE(R351.val,''),', ') AS VAL
                FROM
                    LINKS L41
                    JOIN VALI V349 ON V349.OBJ_ID = L41.OBJ_ID AND V349.PARAM_ID = 349 AND V349.IS_DEL = 0  --Год Int
                    JOIN VALL V350 ON V350.OBJ_ID = L41.OBJ_ID AND V350.PARAM_ID = 350 AND V350.IS_DEL = 0
                    JOIN LISTVALS LV350 ON LV350.LISTVAL_ID = V350.LISTVAL_ID
                    LEFT JOIN RES_GET(LV350.RES_ID,  'RU') R350 ON 1 = 1
                    JOIN VALL V351 ON V351.OBJ_ID = L41.OBJ_ID AND V351.PARAM_ID = 351 AND V351.IS_DEL = 0
                    JOIN LISTVALS LV351 ON LV351.LISTVAL_ID = V351.LISTVAL_ID
                    LEFT JOIN RES_GET(LV351.RES_ID,  'RU') R351 ON 1 = 1
                WHERE L41.OBJ_TYPE_ID = 41
                    AND L41.DATE_DEL IS NULL
                    AND L41.PARENT_ID = :ID
                GROUP BY L41.PARENT_ID
            ),
            ACHIEV42 AS (
                --Лучший учитель в общем какие то достижения год в 352, название чек353 VALL
                SELECT
                    L42.PARENT_ID
                     ,LIST(R353.val || ' в ' || V352.val || ' году',', ') AS VAL
                FROM
                    LINKS L42
                    JOIN VALI V352 ON V352.OBJ_ID = L42.OBJ_ID AND V352.PARAM_ID = 352 AND V352.IS_DEL = 0 -- Год Int
                    JOIN VALL V353 ON V353.OBJ_ID = L42.OBJ_ID AND V353.PARAM_ID = 353 AND V353.IS_DEL = 0
                    JOIN LISTVALS LV353 ON LV353.LISTVAL_ID = V353.LISTVAL_ID
                    LEFT JOIN RES_GET(LV353.RES_ID,  'RU') R353 ON 1 = 1
                WHERE L42.OBJ_TYPE_ID = 42
                    AND L42.DATE_DEL IS NULL
                    AND L42.PARENT_ID = :ID
                GROUP BY L42.PARENT_ID
            )

        SELECT
            NULLIF(
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
        FROM
            MED38
            FULL OUTER JOIN MED39 ON 1 = 1
            FULL OUTER JOIN MED40 ON 1 = 1
            FULL OUTER JOIN ACHIEV41 ON 1 = 1
            FULL OUTER JOIN ACHIEV42 ON 1 = 1
        INTO
            VAL;
        SUSPEND;

        TAG_NAME = 'employees:person:teachDisciplines';
        VAL = NULL;
        SELECT
            LIST(COALESCE(V376.val, ''),', ') AS DISCIPLINES
        FROM
            LINKS L51
            LEFT JOIN VALS V376 ON V376.OBJ_ID = L51.OBJ_ID AND V376.PARAM_ID = 376 AND V376.IS_DEL = 0
        WHERE
            L51.OBJ_TYPE_ID = 51
            AND L51.DATE_DEL IS NULL
            AND L51.PARENT_ID = :ID
        GROUP BY
            L51.PARENT_ID
        INTO
            VAL;
        SUSPEND;
    END
END