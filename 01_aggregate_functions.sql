-- 1
SELECT
       (CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity' END) as activity,
           ROUND(AVG(investment_rounds))
           
FROM fund
GROUP BY activity
ORDER BY ROUND(AVG(investment_rounds)) ASC;


-- 2
SELECT
        fund.country_code,
        MIN(fund.invested_companies),
        MAX(fund.invested_companies),
        AVG(fund.invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM CAST(fund.founded_at AS timestamp)) BETWEEN 2010 and 2012
GROUP BY fund.country_code
HAVING MIN(fund.invested_companies) != 0
ORDER BY AVG(fund.invested_companies) DESC
LIMIT 10;


-- 3
SELECT name, COUNT(DISTINCT instituition)
FROM company INNER JOIN people ON company.id = people.company_id
             INNER JOIN education ON people.id = education.person_id
GROUP BY name
ORDER BY COUNT(DISTINCT instituition) DESC
LIMIT 5;


-- 4
SELECT DISTINCT people.id, instituition
FROM people INNER JOIN education ON people.id = education.person_id
            INNER JOIN company ON people.company_id = company.id
WHERE company.id IN (SELECT DISTINCT company.id
            FROM company INNER JOIN funding_round ON company.id = funding_round.company_id
            WHERE status = 'closed' AND is_first_round = is_last_round AND is_first_round = 1);


-- 5
SELECT AVG(counter)
FROM (SELECT DISTINCT people.id, COUNT(instituition) as counter
FROM people INNER JOIN education ON people.id = education.person_id
            INNER JOIN company ON people.company_id = company.id
WHERE company.id IN (SELECT DISTINCT company.id
            FROM company INNER JOIN funding_round ON company.id = funding_round.company_id
            WHERE status = 'closed' AND is_first_round = is_last_round AND is_first_round = 1)
GROUP BY people.id) as wd;


-- 6
SELECT fund.name as name_of_fund,
       company.name as name_of_company,
       raised_amount as amount
FROM investment INNER JOIN company ON investment.company_id = company.id
                INNER JOIN fund ON investment.fund_id = fund.id
                INNER JOIN funding_round ON investment.funding_round_id = funding_round.id
WHERE company.milestones > 6 AND EXTRACT(YEAR FROM CAST(funded_at AS timestamp)) BETWEEN 2012 AND 2013;


-- 7
SELECT ac.name,
       a.price_amount,
       ca.name,
       c.funding_total,
       ROUND(a.price_amount / c.funding_total)
FROM acquisition AS a LEFT JOIN company AS ac ON a.acquiring_company_id=ac.id
LEFT JOIN company AS ca ON a.acquired_company_id=ca.id
LEFT JOIN company AS c ON c.id = a.acquired_company_id
WHERE a.price_amount <> 0 AND c.funding_total <> 0
ORDER BY a.price_amount DESC, ca.name
LIMIT 10;


-- 8
WITH
t1 AS (SELECT country_code, AVG(funding_total) as lol1
      FROM company
      WHERE EXTRACT(YEAR FROM CAST(founded_at as timestamp)) = 2011
      GROUP BY country_code),
t2 AS (SELECT country_code, AVG(funding_total) as lol2
      FROM company
      WHERE EXTRACT(YEAR FROM CAST(founded_at as timestamp)) = 2012
      GROUP BY country_code),
t3 AS (SELECT country_code, AVG(funding_total) as lol3
      FROM company
      WHERE EXTRACT(YEAR FROM CAST(founded_at as timestamp)) = 2013
      GROUP BY country_code)

SELECT country_code, lol1, lol2, lol3
FROM t1 INNER JOIN t2 USING(country_code) INNER JOIN t3 USING(country_code)
ORDER BY lol1 DESC;
