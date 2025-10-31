DROP  TABLE IF EXISTS LoginIndustry CASCADE ;
DROP  TABLE IF EXISTS IndustryType CASCADE ;
DROP  TABLE IF EXISTS Plan CASCADE ;
DROP  TABLE IF EXISTS Benefit CASCADE ;
DROP  TABLE IF EXISTS BenefitPlan CASCADE ;
DROP  TABLE IF EXISTS Industry CASCADE ;
DROP  TABLE IF EXISTS Employee CASCADE ;
DROP  TABLE IF EXISTS ProductCategory CASCADE ;
DROP  TABLE IF EXISTS Post CASCADE ;
DROP  TABLE IF EXISTS Match CASCADE ;
DROP  TABLE IF EXISTS Login CASCADE ;
DROP  TABLE IF EXISTS LogPlan CASCADE ;
DROP  TABLE IF EXISTS LogIndustryType CASCADE ;
DROP  TABLE IF EXISTS LogBenefitPlan CASCADE ;
DROP  TABLE IF EXISTS LogBenefit CASCADE ;
DROP  TABLE IF EXISTS LogProductCategory CASCADE ;
DROP  TABLE IF EXISTS LogPermission CASCADE ;
DROP  TABLE IF EXISTS Admin CASCADE ;
DROP  TABLE IF EXISTS UserLogin CASCADE ;
-- Drop views
DROP VIEW IF EXISTS VW_PostList CASCADE ;
-- Drop functions
DROP FUNCTION IF EXISTS FN_GenerateHashSenha(VARCHAR, VARCHAR, VARCHAR) CASCADE ;
DROP FUNCTION IF EXISTS FN_validateLogin(VARCHAR, VARCHAR) CASCADE ;
DROP FUNCTION IF EXISTS FN_LoginIndustry(VARCHAR, VARCHAR) CASCADE ;
DROP FUNCTION IF EXISTS FN_TableIdGenerator(VARCHAR, VARCHAR) CASCADE ;
DROP FUNCTION IF EXISTS FN_DailyActiveUsers() CASCADE ;
DROP FUNCTION IF EXISTS FN_logBenefit() CASCADE ;
DROP FUNCTION IF EXISTS FN_logBenefitPlan() CASCADE ;
DROP FUNCTION IF EXISTS FN_logIndustryType() CASCADE ;
DROP FUNCTION IF EXISTS FN_logPlan() CASCADE ;
DROP FUNCTION IF EXISTS FN_logProductCategory() CASCADE ;

-- Drop procedures
DROP PROCEDURE IF EXISTS SP_UpdatePlan() CASCADE ;
DROP PROCEDURE IF EXISTS SP_UpdateIndustryType() CASCADE ;
DROP PROCEDURE IF EXISTS SP_UpdateBenefitPlan() CASCADE ;
DROP PROCEDURE IF EXISTS SP_UpdateBenefit() CASCADE ;
DROP PROCEDURE IF EXISTS SP_UpdateProductCategory() CASCADE ;
DROP PROCEDURE IF EXISTS SP_UpdateUserPassword(VARCHAR, VARCHAR) CASCADE ;
DROP PROCEDURE IF EXISTS SP_InsertUserLogin(VARCHAR) CASCADE ;
-- Drop Indexs
DROP INDEX IF EXISTS Index_LoginIndustry_cUserName_cActive CASCADE ;
DROP INDEX IF EXISTS Index_Industry_cCNPJ_cActive CASCADE ;
DROP INDEX IF EXISTS Index_Post_idIndustry_cActive CASCADE ;
DROP INDEX IF EXISTS Index_Post_idEmployee_cActive CASCADE ;
DROP INDEX IF EXISTS Index_Post_idProductCategory_cActive CASCADE ;
DROP INDEX IF EXISTS Index_DAU_UserLogin CASCADE ;
-- Drop Triggers
DROP TRIGGER IF EXISTS TG_DAU_LoginIndustry ON LoginIndustry CASCADE ;
DROP TRIGGER IF EXISTS TG_LogPlan ON Plan CASCADE ;
DROP TRIGGER IF EXISTS TG_LogIndustryCategory ON IndustryType CASCADE ;
DROP TRIGGER IF EXISTS TG_LogBenefitPlan ON BenefitPlan CASCADE ;
DROP TRIGGER IF EXISTS TG_LogBenefit ON Benefit CASCADE ;
DROP TRIGGER IF EXISTS TG_LogProductCategory ON ProductCategory CASCADE ;
-- Create tables


CREATE TABLE LoginIndustry
( idLoginIndustry INT          NOT NULL
, cUserName       VARCHAR(100) NOT NULL
, cPwdUUID        UUID         NOT NULL CONSTRAINT DF_LoginIndustry_cPwdUUID      DEFAULT (gen_random_uuid())
, cPwdHash        VARCHAR(100)     NULL
, cIsFirstLogin   CHAR(1)      NOT NULL CONSTRAINT DF_LoginIndustry_cIsFirstLogin DEFAULT ('1')
, dLastChange     DATE             NULL
, dLastLogin      DATE             NULL
, cActive         CHAR(1)      NOT NULL CONSTRAINT  DF_LoginIndustry_cActive     DEFAULT ('1')
, CONSTRAINT PK_LoginIndustry       PRIMARY KEY (idLoginIndustry)
, CONSTRAINT CK_LoginIndustry_cIsFirstLogin CHECK       (cIsFirstLogin IN ('0','1'))
, CONSTRAINT CK_LoginIndustry_cActive       CHECK       (cActive IN ('0','1'))
, CONSTRAINT CK_LoginIndustry_dLastChange   CHECK       (dLastChange   <= CURRENT_DATE)
, CONSTRAINT CK_LoginIndustry_dLastLogin    CHECK       (dLastLogin    <= CURRENT_DATE)
);

CREATE INDEX Index_LoginIndustry_cUserName_cActive
    ON LoginIndustry (cUserName, cActive);

CREATE TABLE IndustryType
( idIndustryType    INT          NOT NULL
, cIndustryTypeName VARCHAR(50)  NOT NULL
, cInfo             VARCHAR(100) NOT NULL
, cActive           CHAR(1)      NOT NULL CONSTRAINT DF_IndustryType_cActive DEFAULT ('1')
, CONSTRAINT PK_IndustryType PRIMARY KEY (idIndustryType)
, CONSTRAINT CK_IndustryType_cActive CHECK       (cActive IN ('0','1'))
);

CREATE TABLE Plan
( idPlan    INT           NOT NULL
, cPlanName VARCHAR(50)   NOT NULL
, nPrice    DECIMAL(10,2) NOT NULL
, cActive   CHAR(1)       NOT NULL CONSTRAINT DF_Plan_cActive DEFAULT ('1')
, CONSTRAINT PK_Plan         PRIMARY KEY (idPlan)
, CONSTRAINT CK_Plan_nPrice  CHECK       (nPrice >= 0)
, CONSTRAINT CK_Plan_cActive CHECK       (cActive IN ('0','1'))
);

CREATE TABLE Benefit
( idBenefit    INT          NOT NULL
, cBenefitName VARCHAR(50)  NOT NULL
, cDescription VARCHAR(200) NOT NULL
, cActive      CHAR(1)      NOT NULL CONSTRAINT DF_Benefit_cActive DEFAULT ('1')
, CONSTRAINT PK_Benefit PRIMARY KEY (idBenefit)
, CONSTRAINT CK_Benefit_cActive  CHECK       (cActive IN ('0','1'))
);

CREATE TABLE BenefitPlan
( idBenefit INT NOT NULL
, idPlan    INT NOT NULL
, cActive   CHAR(1) NOT NULL CONSTRAINT DF_BenefitPlan_cActive DEFAULT ('1')
, CONSTRAINT PK_BenefitPlan         PRIMARY KEY (idBenefit, idPlan)
, CONSTRAINT FK_BenefitPlan_Benefit FOREIGN KEY (idBenefit) REFERENCES Benefit (idBenefit)
, CONSTRAINT FK_BenefitPlan_Plan    FOREIGN KEY (idPlan)    REFERENCES Plan    (idPlan)
, CONSTRAINT CK_BenefitPlan_cActive CHECK       (cActive IN ('0','1'))
);

CREATE TABLE Industry
( idIndustry       INT            NOT NULL
, idIndustryType   INT           NOT NULL
, idLoginIndustry  INT           NOT NULL
, idPlan           INT           NOT NULL CONSTRAINT DF_Industry_idPlan DEFAULT 1
, cCNPJ            VARCHAR(14)   NOT NULL
, cIndustryName    VARCHAR(50)   NOT NULL
, cDescription     TEXT              NULL
, cContactMail     VARCHAR(100)      NULL
, cCEP             VARCHAR(8)        NULL
, cCity            VARCHAR(50)       NULL
, cState           VARCHAR(2)        NULL
, cImage           TEXT              NULL
, nLatitude        DECIMAL(10,7) NOT NULL
, nLongitude       DECIMAL(10,7) NOT NULL
, cActive          CHAR(1)       NOT NULL CONSTRAINT DF_Industry_cActive DEFAULT ('1')
, CONSTRAINT PK_Industry              PRIMARY KEY (idIndustry)
, CONSTRAINT FK_Industry_IndustryType FOREIGN KEY (idIndustryType)  REFERENCES IndustryType  (idIndustryType)
, CONSTRAINT FK_Industry_Login        FOREIGN KEY (idLoginIndustry) REFERENCES LoginIndustry (idLoginIndustry)
, CONSTRAINT FK_Industry_Plan         FOREIGN KEY (idPlan)          REFERENCES Plan          (idPlan)
, CONSTRAINT CK_Industry_cActive      CHECK       (cActive IN ('0','1'))
);

CREATE INDEX Index_Industry_cCNPJ_cActive
    ON Industry (cCNPJ, cActive);

CREATE TABLE Employee
( idEmployee    INT         NOT NULL
, idIndustry    INT         NOT NULL
, cEmployeeName VARCHAR(50) NOT NULL
, cActive       CHAR(1)     NOT NULL CONSTRAINT DF_Employee_cActive DEFAULT ('1')
, CONSTRAINT PK_Employee          PRIMARY KEY (idEmployee)
, CONSTRAINT FK_Employee_Industry FOREIGN KEY (idIndustry) REFERENCES Industry (idIndustry)
, CONSTRAINT CK_Employee_cActive  CHECK       (cActive IN ('0','1'))
);

CREATE TABLE ProductCategory
( idProductCategory INT          NOT NULL
, cCategoryName     VARCHAR(50)  NOT NULL
, cInfo             VARCHAR(100) NOT NULL
, cActive           CHAR(1)      NOT NULL CONSTRAINT DF_ProductCategory_cActive DEFAULT ('1')
, CONSTRAINT PK_ProductCategory           PRIMARY KEY (idProductCategory)
, CONSTRAINT CK_ProductCategory_cActive   CHECK       (cActive IN ('0','1'))
);


CREATE TABLE Post
(  idPost            INT           NOT NULL
, idProductCategory INT           NOT NULL
, idEmployee        INT           NOT NULL
, idIndustry        INT           NOT NULL
, cTitle            VARCHAR(100)  NOT NULL
, cDescription      TEXT          NOT NULL
, nQuantity         DECIMAL(10,2) NOT NULL
, cMeasureUnit      CHAR(1)       NOT NULL
, cImage            TEXT              NULL
, nPrice            DECIMAL(18,2) NOT NULL
, dPublication      DATE          NOT NULL CONSTRAINT DF_Post_dPublication DEFAULT (CURRENT_DATE)
, cClassification   CHAR(1)       NOT NULL
, cStatus           VARCHAR(1)    NOT NULL CONSTRAINT DF_Post_cStatus      DEFAULT ('1')
, cActive           CHAR(1)       NOT NULL CONSTRAINT DF_Post_cActive      DEFAULT ('1')
, CONSTRAINT PK_Post                 PRIMARY KEY (idPost)
, CONSTRAINT FK_Post_ProductCategory FOREIGN KEY (idProductCategory) REFERENCES ProductCategory (idProductCategory)
, CONSTRAINT FK_Post_Employee        FOREIGN KEY (idEmployee)        REFERENCES Employee        (idEmployee)
, CONSTRAINT FK_Post_Industry        FOREIGN KEY (idIndustry)        REFERENCES Industry        (idIndustry)
, CONSTRAINT CK_Post_nQuantity       CHECK       (nQuantity >= 0)
, CONSTRAINT CK_Post_cMeasureUnit    CHECK       (cMeasureUnit IN ('1','2','3','4')) -- 1-kg; 2-m; 3-L; 4-unit
, CONSTRAINT CK_Post_nPrice          CHECK       (nPrice >= 0)
, CONSTRAINT CK_Post_cClassification CHECK       (cClassification IN ('1','2','3')) -- 1-Perigoso; 2-Não perigoso não inerte; 3-Não perigoso inerte
, CONSTRAINT CK_Post_cActive         CHECK       (cActive IN ('0','1'))
, CONSTRAINT CK_Post_cStatus         CHECK       (cStatus IN ('1','2','3')) -- 1-Aguardando Aprovado; 2-Aprovado; 3-Reprovado
);

CREATE INDEX Index_Post_idIndustry_cActive
    ON Post (idIndustry, cActive);
CREATE INDEX Index_Post_idEmployee_cActive
    ON Post (idEmployee, cActive);
CREATE INDEX Index_Post_idProductCategory_cActive
    ON Post (idProductCategory, cActive);

--Tabela para administradores do sistema
CREATE TABLE Admin
( idAdmin         INT         NOT NULL
, cAdminUsername VARCHAR(50)  NOT NULL
, cSenha         VARCHAR(100) NOT NULL
, cActive        CHAR(1)      NOT NULL CONSTRAINT DF_Admin_cActive DEFAULT ('1')
, CONSTRAINT PK_Admin         PRIMARY KEY (idAdmin)
, CONSTRAINT CK_Admin_cActive CHECK       (cActive IN ('0','1'))
);


--Tabela para DAU
CREATE TABLE UserLogin
( idUserLogin  SERIAL           NOT NULL
    , cUsername    VARCHAR(100)  NOT NULL
    , dLogin_time  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT PK_UserLogin PRIMARY KEY (idUserLogin)
);

CREATE INDEX Index_DAU_UserLogin ON UserLogin (idUserLogin, dLogin_time);

CREATE OR REPLACE FUNCTION FN_DailyActiveUsers()
    RETURNS TRIGGER
AS $$
BEGIN
    INSERT INTO UserLogin ( cUsername
                          , dLogin_time
    )
    VALUES ( NEW.cUserName
           , CURRENT_TIMESTAMP
           );
    RETURN NEW;
END;
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_DAU_LoginIndustry
    AFTER UPDATE ON LoginIndustry
    FOR EACH ROW
    WHEN (OLD.dLastLogin IS DISTINCT FROM NEW.dLastLogin)
EXECUTE FUNCTION FN_DailyActiveUsers();


--LOGS--

CREATE TABLE LogPlan
( idLogPlan    SERIAL
, idPlan       INT         NOT NULL
, cAction      VARCHAR(50) NOT NULL
, cPlanNameOld VARCHAR(50)     NULL
, nPriceOld    DECIMAL(10,2)   NULL
, cActiveOld   CHAR(1)         NULL
, dAction      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT PK_LogPlan      PRIMARY KEY (idLogPlan)
, CONSTRAINT FK_LogPlan_Plan FOREIGN KEY (idPlan) REFERENCES Plan (idPlan)
);

CREATE OR REPLACE FUNCTION FN_logPlan()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO LogPlan (idPlan
                        , cAction
                        , cPlanNameOld
                        , nPriceOld
                        , cActiveOld
    )
    VALUES ( NEW.idPlan
           , TG_OP
           ,OLD.cPlanName
           , OLD.nPrice
           ,OLD.cActive
           );
    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER  TG_LogPlan
    AFTER INSERT OR UPDATE OR DELETE ON Plan
    FOR EACH ROW
EXECUTE FUNCTION FN_logPlan();



CREATE TABLE LogIndustryType
( idLogIndustryCategory SERIAL
, idIndustryType        INT         NOT NULL
, cAction               VARCHAR(50) NOT NULL
, cIndustryTypeNameOld  VARCHAR(50)     NULL
, cInfoOld              VARCHAR(100)    NULL
, cActiveOld            CHAR(1)         NULL
, dAction               TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT PK_LogIndustryCategory              PRIMARY KEY (idLogIndustryCategory)
, CONSTRAINT FK_LogIndustryCategory_IndustryType FOREIGN KEY (idIndustryType) REFERENCES IndustryType (idIndustryType)
);

CREATE OR REPLACE FUNCTION FN_logIndustryType()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO LogIndustryType ( idIndustryType
                                , cAction
                                , cIndustryTypeNameOld
                                , cInfoOld
                                , cActiveOld
    )
    VALUES ( NEW.idIndustryType
           , TG_OP
           , OLD.cIndustryTypeName
           , OLD.cInfo
           ,OLD.cActive
           );
    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_LogIndustryCategory
    AFTER INSERT OR UPDATE OR DELETE ON IndustryType
    FOR EACH ROW
EXECUTE FUNCTION FN_logIndustryType();


CREATE TABLE LogBenefitPlan
( idLogBenefitPlan   SERIAL
    , idBenefit          INT         NOT NULL
    , idPlan             INT         NOT NULL
    , cAction            VARCHAR(50) NOT NULL
    , cActiveOld         CHAR(1)         NULL
    , dAction            TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT PK_LogAdvantagePlan              PRIMARY KEY (idLogBenefitPlan)
    , CONSTRAINT FK_LogAdvantagePlan_Advantage    FOREIGN KEY (idBenefit) REFERENCES Benefit (idBenefit)
    , CONSTRAINT FK_LogAdvantagePlan_Plan         FOREIGN KEY (idPlan)    REFERENCES Plan (idPlan)
);

CREATE OR REPLACE FUNCTION FN_logBenefitPlan()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO LogBenefitPlan ( idBenefit
                               , idPlan
                               , cAction
                               , cActiveOld
    )
    VALUES ( NEW.idBenefit
           , NEW.idPlan
           , TG_OP
           ,OLD.cActive
           );
    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_LogBenefitPlan
    AFTER INSERT OR UPDATE OR DELETE ON BenefitPlan
    FOR EACH ROW
EXECUTE FUNCTION FN_logBenefitPlan();

CREATE TABLE LogBenefit
( idLogBenefit    SERIAL
    , idBenefit       INT         NOT NULL
    , cAction         VARCHAR(50) NOT NULL
    , cBenefitNameOld VARCHAR(50)     NULL
    , cDescriptionOld VARCHAR(200)    NULL
    , cActiveOld      CHAR(1)         NULL
    , dAction         TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT PK_LogAdvantage               PRIMARY KEY (idLogBenefit)
    , CONSTRAINT FK_LogAdvantage_Advantage     FOREIGN KEY (idBenefit) REFERENCES Benefit (idBenefit)
);

CREATE OR REPLACE FUNCTION FN_logBenefit()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO LogBenefit ( idBenefit
                           , cAction
                           , cBenefitNameOld
                           , cDescriptionOld
                           , cActiveOld
    )
    VALUES ( NEW.idBenefit
           , TG_OP
           , OLD.cBenefitName
           , OLD.cDescription
           ,OLD.cActive
           );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_LogBenefit
    AFTER INSERT OR UPDATE OR DELETE ON Benefit
    FOR EACH ROW
EXECUTE FUNCTION FN_logBenefit();


CREATE TABLE LogProductCategory
( idLogProductCategory SERIAL
    , idProductCategory    INT         NOT NULL
    , cAction              VARCHAR(50) NOT NULL
    , cCategoryNameOld     VARCHAR(50)     NULL
    , cInfoOld             VARCHAR(100)    NULL
    , cActiveOld           CHAR(1)         NULL
    , dAction              TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT PK_LogProductCategory                 PRIMARY KEY (idLogProductCategory)
    , CONSTRAINT FK_LogProductCategory_ProductCategory FOREIGN KEY (idProductCategory) REFERENCES ProductCategory (idProductCategory)
);

CREATE OR REPLACE FUNCTION FN_logProductCategory()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO LogProductCategory ( idProductCategory
                                   , cAction
                                   , cCategoryNameOld
                                   , cInfoOld
                                   , cActiveOld
    )
    VALUES ( NEW.idProductCategory
           , TG_OP
           ,OLD.cCategoryName
           , OLD.cInfo
           ,OLD.cActive
           );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TG_LogProductCategory
    AFTER INSERT OR UPDATE OR DELETE ON ProductCategory
    FOR EACH ROW
EXECUTE FUNCTION FN_logProductCategory();


CREATE OR REPLACE PROCEDURE SP_UpdatePlan()
AS
$$
BEGIN

    UPDATE Plan
    SET cPlanName   = Plan_temp.cPlanName
      , nPrice      = Plan_temp.nPrice
      , cActive     = Plan_temp.cActive
    FROM Plan_temp
    WHERE Plan.idPlan = Plan_temp.idPlan;

    UPDATE Plan
    SET cActive = '0'
    WHERE NOT EXISTS( SELECT 1
                      FROM Plan_temp
                      WHERE Plan_temp.idPlan = Plan.idPlan
    );

    INSERT INTO Plan ( idPlan
                     , cPlanName
                     , nPrice
    )
    SELECT Plan_temp.idPlan
         , Plan_temp.cPlanName
         , Plan_temp.nPrice
    FROM Plan_temp
    WHERE NOT EXISTS( SELECT 1
                      FROM Plan
                      WHERE Plan_temp.idPlan = Plan.idPlan
    );

    DROP TABLE IF EXISTS Plan_temp;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE SP_UpdateIndustryType()
AS
$$
BEGIN
    UPDATE IndustryType
    SET idIndustryType    = IndustryType_temp.idIndustryType
      , cIndustryTypeName = IndustryType_temp.cIndustryTypeName
      , cInfo             = IndustryType_temp.cInfo
      , cActive           = IndustryType_temp.cActive
    FROM IndustryType_temp
    WHERE IndustryType.idIndustryType = IndustryType_temp.idIndustryType;

    UPDATE IndustryType
    SET cActive = '0'
    WHERE NOT EXISTS( SELECT 1
                      FROM IndustryType_temp
                      WHERE IndustryType_temp.idIndustryType = IndustryType.idIndustryType
    );

    INSERT INTO IndustryType ( idIndustryType
                             , cIndustryTypeName
                             , cInfo
                             , cActive
    )
    SELECT IndustryType_temp.idIndustryType
         , IndustryType_temp.cIndustryTypeName
         , IndustryType_temp.cInfo
         , IndustryType_temp.cActive
    FROM IndustryType_temp
    WHERE NOT EXISTS( SELECT 1
                      FROM IndustryType
                      WHERE IndustryType_temp.idIndustryType = IndustryType.idIndustryType
    );

    DROP TABLE IF EXISTS IndustryType_temp;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE SP_UpdateBenefitPlan()
AS
$$
BEGIN
    UPDATE BenefitPlan
    SET idBenefit = BenefitPlan_temp.idBenefit
      , idPlan    = BenefitPlan_temp.idPlan
      , cActive   = BenefitPlan_temp.cActive
    FROM BenefitPlan_temp
    WHERE BenefitPlan.idBenefit = BenefitPlan_temp.idBenefit
      AND BenefitPlan.idPlan    = BenefitPlan_temp.idPlan;

    UPDATE BenefitPlan
    SET cActive = '0'
    WHERE NOT EXISTS( SELECT 1
                      FROM BenefitPlan_temp
                      WHERE BenefitPlan_temp.idbenefit = BenefitPlan.idbenefit
                        AND BenefitPlan_temp.idPlan    = BenefitPlan.idPlan
    );

    INSERT INTO BenefitPlan ( idBenefit
                            , idPlan
                            , cActive
    )
    SELECT BenefitPlan_temp.idBenefit
         , BenefitPlan_temp.idPlan
         , BenefitPlan_temp.cActive
    FROM BenefitPlan_temp
    WHERE NOT EXISTS( SELECT 1
                      FROM BenefitPlan
                      WHERE BenefitPlan_temp.idBenefit = BenefitPlan.idBenefit
                        AND BenefitPlan_temp.idPlan    = BenefitPlan.idPlan
    );

    DROP TABLE IF EXISTS BenefitPlan_temp;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE SP_UpdateBenefit()
AS
$$
BEGIN
    UPDATE Benefit
    SET idBenefit    = Benefit_temp.idBenefit
      , cBenefitName = Benefit_temp.cBenefitName
      , cDescription = Benefit_temp.cDescription
      , cActive      = Benefit_temp.cActive
    FROM Benefit_temp
    WHERE Benefit.idBenefit = Benefit_temp.idBenefit;

    UPDATE Benefit
    SET cActive = '0'
    WHERE NOT EXISTS ( SELECT 1
                       FROM Benefit_temp
                       WHERE Benefit_temp.idBenefit = Benefit.idBenefit
    );

    INSERT INTO Benefit ( idBenefit
                        , cBenefitName
                        , cDescription
                        , cActive
    )
    SELECT Benefit_temp.idBenefit
         , Benefit_temp.cBenefitName
         , Benefit_temp.cDescription
         , Benefit_temp.cActive
    FROM Benefit_temp
    WHERE NOT EXISTS( SELECT 1
                      FROM Benefit
                      WHERE Benefit_temp.idBenefit = Benefit.idBenefit
    );

    DROP TABLE IF EXISTS Benefit_temp;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE SP_UpdateProductCategory()
AS
$$
BEGIN
    UPDATE ProductCategory
    SET idProductCategory = ProductCategory_temp.idProductCategory
      , cCategoryName     = ProductCategory_temp.cCategoryName
      , cInfo             = ProductCategory_temp.cInfo
      , cActive           = ProductCategory_temp.cActive
    FROM ProductCategory_temp
    WHERE ProductCategory.idProductCategory = ProductCategory_temp.idProductCategory;

    UPDATE ProductCategory
    SET cActive = '0'
    WHERE NOT EXISTS ( SELECT 1
                       FROM ProductCategory_temp
                       WHERE ProductCategory_temp.idProductCategory = ProductCategory.idProductCategory
    );

    INSERT INTO ProductCategory ( idProductCategory
                                , cCategoryName
                                , cInfo
                                , cActive
    )
    SELECT ProductCategory_temp.idProductCategory
         , ProductCategory_temp.cCategoryName
         , ProductCategory_temp.cInfo
         , ProductCategory_temp.cActive
    FROM ProductCategory_temp
    WHERE NOT EXISTS( SELECT 1
                      FROM ProductCategory
                      WHERE ProductCategory_temp.idProductCategory = ProductCategory.idProductCategory
    );

    DROP TABLE IF EXISTS ProductCategory_temp;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION FN_GenerateHashSenha
( AcUserName     VARCHAR(100)
, AcPassword     VARCHAR(100)
, AcPasswordUUID VARCHAR(50)
)
    RETURNS VARCHAR(100)
AS
$$
BEGIN
    RETURN MD5(AcUserName || AcPassword || AcPasswordUUID);
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION FN_validateLogin
( AcUsername VARCHAR(100)
, AcPassword VARCHAR(100)
)
    RETURNS BOOLEAN AS $$
DECLARE
    cPasswordUUID VARCHAR(50);
BEGIN
    cPasswordUUID := ( SELECT cPwdUUID
                       FROM LoginIndustry
                       WHERE cUserName = AcUsername
    );

    IF cPasswordUUID IS NULL THEN
        RETURN FALSE;
    ELSE
        RETURN EXISTS ( SELECT 1
                        FROM LoginIndustry
                        WHERE cUserName = AcUsername
                          AND cPwdHash  = FN_GenerateHashSenha(AcUsername, AcPassword, cPasswordUUID)
        );
    END IF;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE SP_UpdateUserPassword
( AcUsername VARCHAR(100)
, AcPassword VARCHAR(100)
)
AS
$$
BEGIN

    UPDATE loginindustry
    SET cPwdHash      = FN_GenerateHashSenha(AcUsername, AcPassword, cPwdUUID::VARCHAR(50))
      , cIsFirstLogin = '0'
      , dLastChange   = CURRENT_DATE
    WHERE cUserName   = AcUsername;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION FN_LoginIndustry
( AcUsername VARCHAR(100)
, AcPassword VARCHAR(100)
)
    RETURNS BOOLEAN
AS
$$
DECLARE
    vIsValid BOOLEAN;
    vIdLogin INT;
BEGIN
    vIsValid := FN_validateLogin(AcUsername, AcPassword);
    vIdLogin  := ( SELECT idLoginIndustry
                   FROM LoginIndustry
                   WHERE cUserName = AcUsername
                     AND cActive   = '1'
    );

    IF vIsValid THEN
        UPDATE LoginIndustry
        SET dLastLogin = CURRENT_DATE
        WHERE cUserName = AcUsername;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE SP_InsertUserLogin
( AcUsername VARCHAR(100)
)
AS
$$
BEGIN
    INSERT INTO UserLogin ( cUserName
                          , dLogin_time
    )
    VALUES ( AcUsername
           , CURRENT_TIMESTAMP
           );
END;
$$
    LANGUAGE plpgsql;



CREATE OR REPLACE VIEW VW_PostList
AS
SELECT p.idpost
     , pc.ccategoryname
     , it.cindustrytypename
     , i.nlatitude
     , i.nlongitude
     , p.nquantity
     , p.cmeasureunit
     , i.idIndustry
  FROM post p
  JOIN productcategory pc ON pc.idproductcategory = p.idproductcategory
  JOIN industry        i  ON i.idindustry         = p.idindustry
  JOIN industrytype    it ON it.idindustrytype    = i.idindustrytype
 WHERE p.cActive = '1'
   AND pc.cActive = '1'
   AND i.cActive  = '1'
   AND it.cActive = '1';


CREATE OR REPLACE FUNCTION FN_TableIdGenerator
( AcNmTable  VARCHAR(100)
, AcNmColumn VARCHAR(100)
)
RETURNS INTEGER
AS
$$
DECLARE

    vNextId INTEGER;

    vSQL TEXT;
BEGIN

    vSQL := format(
            'SELECT COALESCE(MAX(%I), 0) + 1 FROM %I',
            AcNmColumn,
            AcNmTable
            );

    EXECUTE vSQL INTO vNextId;

    RETURN vNextId;
END
$$ LANGUAGE plpgsql;
