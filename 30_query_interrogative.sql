-- =============================================================================
-- ARCHITETTURA DATABASE FOOD DELIVERY - 30 QUERY INTERROGATIVE (SQL / MySQL)
-- =============================================================================
-- Questo file raccoglie 30 interrogazioni di esempio suddivise per area funzionale,
-- pronte per l'esecuzione sul database 'food_delivery_db'.
-- =============================================================================

USE food_delivery_db;

-- =============================================================================
-- AREA 1: GESTIONE CLIENTI & WALLET
-- =============================================================================

-- Query 1: Clienti con saldo positivo nel wallet
-- Domanda: Quali clienti hanno un credito residuo maggiore di 0€ sul loro conto?
SELECT username, nome, cognome, saldo 
FROM Cliente 
WHERE saldo > 0;

-- Query 2: Clienti target per fascia d'età (nati tra il 1998 e il 2003)
-- Domanda: Quali utenti appartengono alla fascia d'età compresa tra 1998 e 2003?
SELECT username, nome, cognome, data_nascita 
FROM Cliente 
WHERE data_nascita BETWEEN '1998-01-01' AND '2003-12-31';

-- Query 3: Clienti in possesso di Carta Fedeltà
-- Domanda: Quali clienti hanno una carta fedeltà associata al loro profilo?
SELECT username, nome, cognome, carta_fedelta 
FROM Cliente 
WHERE carta_fedelta IS NOT NULL;

-- Query 4: Clienti che hanno effettuato almeno un ordine
-- Domanda: Chi sono gli utenti attivi che hanno inserito almeno un ordine nel sistema?
SELECT username, nome, cognome 
FROM Cliente 
WHERE username IN (SELECT cliente FROM Ordine);

-- Query 5: Clienti inattivi (senza alcun ordine effettuato)
-- Domanda: Quali utenti registrati non hanno mai effettuato ordini sulla piattaforma?
SELECT username, nome, cognome 
FROM Cliente 
WHERE username NOT IN (SELECT cliente FROM Ordine);


-- =============================================================================
-- AREA 2: RISTORANTI, MENU & PIATTI
-- =============================================================================

-- Query 6: Ristoranti di una specifica tipologia e CAP (es. Pizzerie a Trapani)
-- Domanda: Quali pizzerie si trovano nella zona con CAP 91100?
SELECT nome, via, numero_civico 
FROM Ristorante 
WHERE tipologia = 'pizzeria' AND cap = '91100';

-- Query 7: Piatti senza un determinato ingrediente/allergene (es. senza funghi da "Mon Amour")
-- Domanda: Quali piatti del ristorante "Mon Amour" non contengono funghi tra gli ingredienti?
SELECT P.nome 
FROM Piatto P 
JOIN Ristorante R ON P.ristorante = R.id 
WHERE R.nome = 'Mon Amour' 
  AND P.nome NOT IN (
    SELECT C.nome_piatto 
    FROM Contiene C 
    WHERE C.ristorante = R.id AND C.ingrediente = 'funghi'
  );

-- Query 8: Numero di piatti disponibili nei menu per ciascun ristorante
-- Domanda: Quante pietanze propone in totale ogni ristorante presente in piattaforma?
SELECT ristorante, COUNT(*) AS totale_piatti 
FROM Piatto 
GROUP BY ristorante;

-- Query 9: Elenco dei piatti con relativi ingredienti contenuti
-- Domanda: Qual è la ricetta/composizione dettagliata di ciascun piatto offerto dai ristoranti?
SELECT nome_piatto, ristorante, GROUP_CONCAT(ingrediente SEPARATOR ', ') AS ingredienti 
FROM Contiene 
GROUP BY nome_piatto, ristorante;

-- Query 10: Prezzo medio dei piatti offerti per tipologia di cucina
-- Domanda: Qual è il prezzo medio delle pietanze ripartite per tipologia di ristorante?
SELECT R.tipologia, AVG(P.prezzo) AS prezzo_medio 
FROM Piatto P 
JOIN Ristorante R ON P.ristorante = R.id 
GROUP BY R.tipologia;


-- =============================================================================
-- AREA 3: PROMOZIONI & SCONTI
-- =============================================================================

-- Query 11: Piatti in promozione nella città di Palermo (CAP 90121 - 90151)
-- Domanda: Quali piatti sono attualmente scontati nei ristoranti situati a Palermo?
SELECT P.nome_piatto, P.sconto, P.periodo, R.nome AS nome_ristorante 
FROM Promuove P 
JOIN Ristorante R ON P.ristorante = R.id 
WHERE R.cap BETWEEN '90121' AND '90151';

-- Query 12: Promozioni attive con uno sconto superiore o uguale al 20%
-- Domanda: Quali sono le offerte settimanali che offrono almeno il 20% di sconto?
SELECT ristorante, nome_piatto, sconto, periodo 
FROM Promuove 
WHERE sconto >= 20.00;

-- Query 13: Ristoranti che non hanno applicato alcuna promozione sui propri piatti
-- Domanda: Quali ristoranti non stanno promuovendo alcuna pietanza nel periodo corrente?
SELECT id, nome 
FROM Ristorante 
WHERE id NOT IN (SELECT ristorante FROM Promuove);


-- =============================================================================
-- AREA 4: ORDINI, FATTURAZIONE & INCASSI
-- =============================================================================

-- Query 14: Numero totale di ordini gestiti da ciascun ristorante
-- Domanda: Quanti ordini ha ricevuto ed elaborato ciascun ristorante?
SELECT ristorante, COUNT(*) AS num_ordini 
FROM Ordine 
GROUP BY ristorante;

-- Query 15: Ordini effettuati da un cliente specifico (es. Mario Rossi) nel Q4 2025
-- Domanda: Quanti ordini ha completato il cliente Mario Rossi tra ottobre e dicembre 2025?
SELECT COUNT(*) AS num_ordini 
FROM Ordine o 
JOIN Cliente c ON c.username = o.cliente 
WHERE c.nome = 'Mario' AND c.cognome = 'Rossi' 
  AND o.data_ordinazione BETWEEN '2025-10-01' AND '2025-12-31';

-- Query 16: Dettaglio completo degli ordini ordinati per data decrescente
-- Domanda: Qual è la cronologia dettagliata di tutti gli ordini (con indicazione di cliente, ristorante e rider)?
SELECT O.id AS ordine, O.data_ordinazione, O.orario_ordinazione,
       C.username AS cliente, R.nome AS nome_ristorante, D.cognome AS cognome_rider
FROM Ordine O 
JOIN Cliente C ON O.cliente = C.username 
JOIN Ristorante R ON O.ristorante = R.id 
JOIN Rider D ON O.rider = D.matricola 
ORDER BY O.data_ordinazione DESC;

-- Query 17: Incasso totale complessivo per metodo di pagamento
-- Domanda: Qual è la somma totale degli importi incassati per ciascuna modalità di pagamento (carta, contanti, wallet)?
SELECT metodo_pagamento, SUM(importo_complessivo) AS totale_incassato 
FROM Ricevuta 
GROUP BY metodo_pagamento;

-- Query 18: Mancia media ricevuta dai rider per ordine
-- Domanda: Qual è il valore medio delle mance lasciate dai clienti sulle ricevute?
SELECT AVG(mancia) AS mancia_media 
FROM Ricevuta 
WHERE mancia > 0;

-- Query 19: Ordini con utilizzo di codice sconto
-- Domanda: Quali ricevute attestano l'applicazione di un coupon/codice promozionale?
SELECT id, ordine, importo_complessivo, codice_sconto 
FROM Ricevuta 
WHERE codice_sconto IS NOT NULL;

-- Query 20: Fatturato totale per singolo ristorante
-- Domanda: Quanto ha fatturato ogni ristorante sommando gli importi delle ricevute degli ordini?
SELECT O.ristorante, SUM(R.importo_complessivo) AS fatturato_totale 
FROM Ordine O 
JOIN Ricevuta R ON O.id = R.ordine 
GROUP BY O.ristorante;


-- =============================================================================
-- AREA 5: RIDER & LOGISTICA
-- =============================================================================

-- Query 21: Rider con salario superiore a 1000€ residenti a Palermo
-- Domanda: Quali rider residenti a Palermo (CAP 90121-90151) percepiscono uno stipendio oltre i 1000€?
SELECT nome, cognome, salario, matricola 
FROM Rider 
WHERE salario > 1000 AND cap BETWEEN '90121' AND '90151';

-- Query 22: Numero di consegne effettuate da ciascun rider
-- Domanda: Quanti ordini ha preso in carico e consegnato ciascun rider?
SELECT rider, COUNT(*) AS consegne_effettuate 
FROM Ordine 
WHERE rider IS NOT NULL 
GROUP BY rider;

-- Query 23: Rider disponibili nel fine settimana (sabato/domenica)
-- Domanda: Quali rider hanno indicato disponibilità nei giorni festivi/weekend?
SELECT matricola, nome, cognome, giorni_lavoro 
FROM Rider 
WHERE giorni_lavoro LIKE '%Sabato%' OR giorni_lavoro LIKE '%Domenica%';


-- =============================================================================
-- AREA 6: RECENSIONI & VALUTAZIONI
-- =============================================================================

-- Query 24: Ristoranti con media voto servizio >= 4.0
-- Domanda: Quali ristoranti mantengono una valutazione media del servizio pari o superiore a 4 stelle?
SELECT ristorante, AVG(voto_servizio) AS voto_medio 
FROM Ordine 
GROUP BY ristorante 
HAVING AVG(voto_servizio) >= 4;

-- Query 25: Recensioni e commenti ricevuti da uno specifico ristorante (es. id = 1)
-- Domanda: Quali recensioni testuali e valutazioni sono state rilasciate dagli utenti per un determinato ristorante?
SELECT ordine, voto_ristorante, testo 
FROM Recensione 
WHERE ristorante = 1;

-- Query 26: Ristoranti con la media voti più alta sulla piattaforma (Top Rated)
-- Domanda: Qual è la classifica dei ristoranti con il punteggio medio più elevato?
SELECT id, nome, tipologia, media 
FROM Ristorante 
ORDER BY media DESC;


-- =============================================================================
-- AREA 7: ASSISTENZA CLIENTI, TICKET & OPERATORI
-- =============================================================================

-- Query 27: Ticket di assistenza gestiti da operatori umani
-- Domanda: Quali ticket sono stati presi in carico ed elaborati da un operatore del supporto?
SELECT T.id AS ticket_id, T.cliente, A.operatore 
FROM Ticket T 
JOIN Assistenza A ON T.id = A.ticket;

-- Query 28: Storico messaggi di una specifica chat di assistenza (es. Ticket ID 10)
-- Domanda: Qual è la sequenza cronologica delle risposte scambiate all'interno del ticket #10?
SELECT data, mittente, testo 
FROM Messaggio 
WHERE ticket = 10 
ORDER BY data ASC;

-- Query 29: Numero di ticket aperti per ciascun cliente
-- Domanda: Quante segnalazioni di supporto ha inviato ogni singolo utente?
SELECT cliente, COUNT(*) AS num_ticket 
FROM Ticket 
GROUP BY cliente;

-- Query 30: Operatori poliglotti che parlano la lingua inglese
-- Domanda: Quali operatori dell'assistenza conoscono e gestiscono la lingua inglese?
SELECT matricola, nome, cognome, lingue 
FROM Operatore 
WHERE lingue LIKE '%en%';
