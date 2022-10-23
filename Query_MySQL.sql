/*COME SCRIVERE UNA QUERY
di Nicola Iantomasi 

Eseguire le query sulla propria installazione personale
di test dove si è creato il database
 */


/*************************************
Capitolo 1: Select, From e Where
*************************************/
USE Banca;

/*Estrarre tutti i dati delle carte di credito*/
SELECT *
FROM   CarteCredito;


/*Estrarre tutti i dati dei clienti*/
SELECT *
FROM   Clienti;


/*Selezionare:
- il codice fiscale
- la tipologia
- il numero
delle carte di credito con:
- valuta uguale a euro
- saldo strettamente maggiore di 30*/
SELECT CodiceFiscale,
       Tipologia,
       NumeroCarta
FROM   CarteCredito
WHERE  Valuta = 'EUR'
   AND Saldo > 30;


/*Selezionare nome e cognome dei clienti con età compresa 
tra i 40 e i 50 anni e residenti in Puglia o in Sicilia.*/
SELECT Nome,
       Cognome
FROM   Clienti
WHERE  (Eta >= 40 
          AND Eta<=50) 
   AND (Residenza = 'Puglia'
	      OR Residenza = 'Sicilia');


/**********************************
Capitolo 2: Join tra tabelle
**********************************/
/*Riportare per ogni carta di credito il suo numero, il suo saldo,
il nome e il cognome del relativo cliente. */
SELECT Cc.NumeroCarta,
       Cc.Saldo,   
       Cl.Nome,  
       Cl.Cognome
FROM   CarteCredito AS Cc
INNER JOIN Clienti AS Cl
   ON Cc.CodiceFiscale =  Cl.CodiceFiscale;


/*Riportare per ogni conto corrente il suo numero, il suo saldo, 
il codice fiscale e la residenza dei clienti.*/
SELECT Cc.NumeroConto,
       Cc.Saldo, 
       Cl.CodiceFiscale,
       Cl.Residenza
FROM   ContiCorrenti AS Cc
INNER JOIN ClientiContiCorrenti AS Associazione
  ON Cc. NumeroConto = Associazione.NumeroConto
INNER JOIN Clienti AS Cl
ON Associazione.CodiceFiscale = Cl.CodiceFiscale;


/**********************************
Capitolo 3: Group by e Having
***********************************/
/* Quanti conti correnti sono presenti?
Qual è la somma dei saldi dei conti correnti?
Qual è la media dei saldi delle carte di credito?  */
SELECT COUNT(*) AS NumeroConti
FROM   ContiCorrenti;

SELECT SUM(Saldo) AS SommaSaldoConti 
FROM   ContiCorrenti;

SELECT AVG(Saldo) AS MediaSaldoConti
FROM   CarteCredito;


/*Calcolare la somma dei saldi dei conti correnti aperti dal
primo gennaio 2019 e con valuta Euro */
SELECT SUM(Saldo)
FROM   ContiCorrenti
WHERE  DataApertura >= '2019-01-01'     
  AND Valuta = 'EUR';


/*Riportare il numero di conti correnti per ogni valuta. */
SELECT   Valuta,
	     COUNT(*) AS NumeroConti
FROM     ContiCorrenti
GROUP BY Valuta;


/*Riportare la somma dei saldi delle carte di 
credito divise per Tipologia e Valuta.*/
SELECT   Tipologia,
         Valuta,
         SUM(Saldo) AS SommaSaldo
FROM     CarteCredito
GROUP BY Tipologia,
         Valuta;


/*Riportare la somma dei saldi delle carte di credito
divise per Tipologia e valuta, se tale somma è superiore a 50.*/
SELECT   Tipologia,
         Valuta,
         SUM(Saldo) AS SommaSaldo
FROM     CarteCredito
GROUP BY Tipologia,
         Valuta 
HAVING   SUM(Saldo) > 50;


/*Riportare il numero di conti correnti aperti dopo il primo  
gennaio 2019, divisi per valuta, se la media dei saldi è superiore a 100.*/
SELECT   Valuta,
	     COUNT(*) AS NumeroConti
FROM     ContiCorrenti
WHERE    DataApertura >= '20190101'
GROUP BY Valuta
HAVING   AVG(saldo) > 100;

 
/****************************************
Capitolo 4: Creiamo un nuovo database 
****************************************/
CREATE DATABASE Cinematografia;
 
USE Cinematografia;

CREATE TABLE Attori (
	IdAttore INT AUTO_INCREMENT 
             PRIMARY KEY NOT  NULL,
    Nome     VARCHAR(50) NOT NULL,
    Cognome  VARCHAR(50) NOT NULL,
    DataNascita DATE NULL);

CREATE TABLE Registi (
    IdRegista INT AUTO_INCREMENT 
              PRIMARY KEY  NOT  NULL,
    Nome      VARCHAR(50) NOT NULL,
    Cognome   VARCHAR(50) NOT NULL,
    DataNascita DATE NULL);

CREATE TABLE Film (
    IdFilm INT AUTO_INCREMENT 
           PRIMARY KEY  NOT  NULL,
    Titolo  VARCHAR(50) NOT NULL,
    AnnoProduzione INT NOT NULL,
    DataNascita DATE NULL);

ALTER TABLE Film  
ADD IdRegista INT NOT NULL;

ALTER TABLE Film  
ADD FOREIGN KEY (IdRegista)
REFERENCES Registi(IdRegista);

CREATE TABLE FilmAttori (
    IdFilm INT NOT NULL,
	IdAttore INT NOT NULL);

ALTER TABLE FilmAttori  
ADD PRIMARY KEY (IdFilm, IdAttore);  
 
ALTER TABLE FilmAttori  
ADD FOREIGN KEY (IdFilm)
REFERENCES Film(IdFilm);  

ALTER TABLE FilmAttori  
ADD FOREIGN KEY (IdAttore)
REFERENCES Attori(IdAttore);


/****************************************
Capitolo 5: Aggiornare un Database
****************************************/
USE Banca;

/*Cancellare i clienti con residenza uguale a Piemonte*/
DELETE
FROM  Clienti
WHERE Regione = 'Piemonte';


/*Inserire nella tabella Clienti una riga con questi dati:
- NTMNCL70R17L113W
- Nicola
- Iantomasi
- 52
- Lombardia
- Impiegato */
INSERT INTO Clienti (
   CodiceFiscale, 
   Nome,
   Cognome,
   Eta,
   Residenza,
   Impiego)
SELECT 'NTMNCL70R17L113W' AS NumeroCliente,
	   'Nicola' AS Nome,
	   'Iantomasi' AS Cognome,
       52 AS Eta,
       'Lombardia' AS Residenza,
       'Impiegato' AS Impiego;


/* Modificare nella tabella dei clienti la residenza del 
cliente con codice fiscale AWNNLZ36R05E168T in Molise.*/
UPDATE  Clienti
SET     Residenza = 'Lombardia'
WHERE   CodiceFiscale = 'AWNNLZ36R05E168T';


/****************************************
Capitolo 6: SubQuery e CTE
****************************************/
/*Calcolare la media della somma dei saldi 
dei conti al variare della valuta. */
WITH SaldiPerValuta AS (  
      SELECT   Valuta,                                             
			   SUM(Saldo) AS SaldoTotalePerValuta  
      FROM     ContiCorrenti  
      GROUP BY Valuta) 
SELECT  AVG(SaldoTotalePerValuta) AS SaldoMedioTraValute  
FROM    SaldiPerValuta;  


SELECT  AVG(SaldoTotalePerValuta) AS SaldoMedioTraValute  
FROM  (
	  SELECT Valuta,            
	          SUM(Saldo) AS SaldoTotalePerValuta  
	  FROM     ContiCorrenti  
	  GROUP BY Valuta
	  )  AS SaldiPerValuta;  


/****************************************
Capitolo 7: Viste e Stored Procedure
****************************************/
/*Salvare nel Database il codice per raggruppare i dati 
dei conti correnti per valuta e calcolare il saldo aggregato.*/
CREATE VIEW SaldiPerValuta AS  
   SELECT   Valuta,
            SUM(Saldo) AS SaldoTotalePerValuta  
   FROM     ContiCorrenti  
   GROUP BY Valuta;  


/*Salvare il codice che incrementa del 10% 
il saldo di ogni conto corrente.*/  
DELIMITER //  
CREATE PROCEDURE IncrementaSaldoConti()  
BEGIN  
   UPDATE ContiCorrenti 
   SET    Saldo = Saldo * 1.1;  
END //  
DELIMITER ;  


/****************************************
Capitolo 8: Le Window Function
****************************************/
/*Riportare per ogni valuta il numero di conto 
con la data di apertura più recente.*/

WITH CTE AS (
   SELECT  Valuta,
          MAX(DataApertura) AS AperturaPiuRecente
  FROM    ContiCorrenti
  GROUP BY Valuta)
SELECT CTE.Valuta,
       Cc.NumeroConto,
       CTE.AperturaPiuRecente
FROM ContiCorrenti AS Cc
INNER JOIN CTE 
  ON Cc.Valuta = CTE.Valuta
  AND CC.DataApertura =  CTE.AperturaPiuRecente; 


WITH CTE AS ( 
   SELECT *,
          RANK() OVER(PARTITION BY Valuta
                 ORDER BY DataApertura DESC) 
                                   AS Ordine
   FROM ContiCorrenti)
SELECT Valuta,
	   NumeroConto,
	   DataApertura AS AperturaPiuRecente
FROM   CTE
WHERE  Ordine = 1;


/****************************************
Capitolo 9: Funzioni SQL
****************************************/
/*Estrarre il settimo e ottavo carattere dalla colonna
CodiceFiscale della tabella Clienti scriveremo */
SELECT CodiceFiscale,
	   SUBSTRING(CodiceFiscale, 7, 2) AS AnnoNascita
FROM   Clienti;


/*Utilizzo REPLACE */
SELECT REPLACE('Testo', 't', 'c');


/*Estrarre il numero di conti aperti al variare dell’anno */
SELECT   YEAR(DataApertura) AS Anno,
		 COUNT(*) AS NumeroConti
FROM     ContiCorrenti
GROUP BY YEAR(DataApertura);


/*Utilizzo DATEDIFF */
SELECT DATEDIFF('2022-07-23','2022-07-21');


/****************************************
Capitolo 10: Filtri particolari
****************************************/
/*Estrarre le carte di credito dei clienti
con codice fiscale nell’elenco
SRDLZQ40M58A184Y, CDPKXR28E62A973B e RVRKTO80T64G614O */
SELECT *
FROM   CarteCredito
WHERE  CodiceFiscale = 'SRDLZQ40M58A184Y'
   OR CodiceFiscale = 'CDPKXR28E62A973B'
   OR CodiceFiscale = 'RVRKTO80T64G614O';

SELECT *
FROM   CarteCredito
WHERE  CodiceFiscale IN ('SRDLZQ40M58A184Y',
						 'CDPKXR28E62A973B',
                         'RVRKTO80T64G614O');


/*Estrarre le carte di credito dei clienti
con residenza in Puglia */
SELECT *
FROM   CarteCredito
WHERE  CodiceFiscale IN (
     		 SELECT CodiceFiscale
	    	 FROM     Clienti
             WHERE  Residenza = 'Puglia' 
             );


/*Utilizzo LIKE */
SELECT *
FROM   Clienti
WHERE Nome LIKE 'a%';  
#WHERE Nome LIKE '%a%';
#WHERE Nome LIKE '%a';


/*Estrarre tutte le righe della tabella 
ContiCorrenti dove la DataChiusura è NULL */
SELECT *
FROM   ContiCorrenti
WHERE  DataChiusura IS NULL;


/*Estrarre tutte le righe della tabella 
ContiCorrenti dove la DataChiusura non è NULL*/
SELECT *
FROM   ContiCorrenti
WHERE  DataChiusura IS NOT NULL;


/*Estrarre i clienti che non hanno una carta di credito*/
SELECT Cl.*
FROM   Clienti AS Cl
LEFT JOIN CarteCredito AS Cc
   ON  Cl.CodiceFiscale = CC.CodiceFiscale
WHERE CC.CodiceFiscale IS NULL;

SELECT Cl.*
FROM   Clienti AS Cl
WHERE  NOT EXISTS (SELECT *
                   FROM   CarteCredito AS Cc
                   WHERE  Cl.CodiceFiscale = CC.CodiceFiscale);

                   
/*******************************
Capitolo 11: Esercizi
*******************************/

/*1) Selezionare tutte le informazioni sui conti che rispettano 
almeno una delle seguenti condizioni 
- la valuta è il dollaro
- la valuta è l'euro e l'importo è maggiore di 1000 */
SELECT *
FROM   ContiCorrenti  
WHERE  Valuta = 'USD'  
  OR   (Valuta = 'EUR' 
		  AND Importo > 1000);  

/*2) Selezionare la colonna NumeroConto per i conti 
correnti aperti nell'ultimo trimestre del 2018. */
SELECT  NumeroConto  
FROM    ContiCorrenti  
WHERE   DataApertura >= '2018-10-01'
   AND  DataApertura < '2019-01-01';  


/*3) Selezionare il numero e il saldo dei conti correnti con valuta euro, 
aperti a ottobre 2018 o ottobre 2019, con saldo compreso tra 1000 e 2000 euro.
Fare attenzione alle parentesi*/
SELECT NumeroConto, 
	   Saldo 
FROM   ContiCorrenti  
WHERE  Valuta = 'EUR'    
   AND  ( (DataApertura >= '20181001' 
              AND DataApertura < '20181101')   
		   OR            
          (DataApertura >= '20191001'
              AND DataApertura < '20191101')
		) 
   AND Saldo >= 1000  
   AND Saldo <=2000;    


/*4) Riportare per ogni carta di credito, il numero della carta, la tipologia, 
il circuito, il codice fiscale del cliente associato e il suo impiego.
 Se un cliente non ha carte associate, riportare comunque i suoi dati.*/
SELECT cc.NumeroCarta,  
	   cc.Tipologia,   
       cl.CodiceFiscale,  
       cl.Impiego
FROM   CarteCredito AS cc 
RIGHT JOIN Clienti AS cl 
	ON cc.CodiceFiscale = cl.CodiceFiscale;  
  

/*5) Riportare per ogni conto corrente il numero del conto,  
il saldo, il nome e il cognome del cliente associato. */
SELECT cc.NumeroConto,
       cc.Saldo,
	   cl.Nome,
	   cl.Cognome 
FROM   ContiCorrenti AS cc
INNER JOIN ClientiContiCorrenti AS Associazione     
    ON cc.NumeroConto = Associazione.NumeroConto       
INNER JOIN Clienti AS cl      
    ON cl.CodiceFiscale = Associazione.CodiceFiscale;     


/*6) Contare i clienti con età maggiore di 30 anni */
SELECT  COUNT(*) AS NumeroClienti  
FROM    Clienti 
WHERE   Eta > 30;

    
/*7) Contare, tra quelli residenti in Puglia, Sicilia, 
Lombardia, il numero di clienti per ogni impiego. */
SELECT   Impiego,
	     COUNT(*) AS NumeroClienti  
FROM     Clienti   
WHERE    Residenza = 'Puglia'   
	  OR Residenza = 'Sicilia'   
      OR Residenza = 'Lombardia'   
GROUP BY Impiego;  


/*8) Calcolare il numero dei conti correnti divisi per Valuta, 
solo se la relativa somma dei saldi è maggiore di 100. */
SELECT   Valuta, 
		 COUNT(*) AS NumeroConti 
FROM     ContiCorrenti 
GROUP BY Valuta 
HAVING   SUM(Saldo)>100;     


/*9) Individua le entità e le relazioni
del database Banca utilizzato nei primi tre capitoli */
  
/*Le entità del database Banca sono:  
- carte di credito;  
- clienti;  
- conti correnti.    

Le relazioni sono:   
- clienti-carte di credito è una relazione uno a molti ;  
- clienti-conti correnti è una relazione molti a molti. */


/*10) Aggiungi tutti i vincoli necessari alle 
tabelle del database Banca */
ALTER TABLE CarteCredito  
ADD PRIMARY KEY (NumeroCarta);  

ALTER TABLE Clienti  
ADD PRIMARY KEY (CodiceFiscale);    

ALTER TABLE ClientiContiCorrenti  
ADD PRIMARY KEY (CodiceFiscale, NumeroConto);   

ALTER TABLE ContiCorrenti  
ADD PRIMARY KEY (NumeroConto);    

ALTER TABLE CarteCredito  
ADD FOREIGN KEY (CodiceFiscale)  
REFERENCES Clienti (CodiceFiscale);    

ALTER TABLE ClientiContiCorrenti  
ADD FOREIGN KEY (CodiceFiscale)  
REFERENCES Clienti (CodiceFiscale); 

ALTER TABLE ClientiContiCorrenti  
ADD FOREIGN KEY (NumeroConto)  
REFERENCES ContiCorrenti (NumeroConto);      


/*11) Inserisci nella tabella ContiCorrenti questa nuova riga
41,
32.53,
'EUR',
'20190101',
NULL
*/  
INSERT INTO ContiCorrenti(
                     NumeroConto,
                     Saldo,  
                     Valuta,  
                     DataApertura,  
                     DataChiusura)  
SELECT 41 AS NumeroConto,
       32.53 AS Saldo,      
       'EUR' AS Valuta, 
       '2019-01-01' AS DataApertura,
       NULL AS DataChiusura;   
   
   
/*12) Elimina l'associazione tra il conto 32 e 
il codice fiscale AWNNLZ36R05E168T */ 
DELETE
FROM   ClientiContiCorrenti 
WHERE  NumeroConto = 32         
   AND CodiceFiscale = 'AWNNLZ36R05E168T';  

