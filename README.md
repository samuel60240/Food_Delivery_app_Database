# 🍕 Architettura Database Food Delivery

> **Progetto Universitario per il corso di Basi di Dati**  
> **Repository:**   
> **Autori:** Begalov Nikita, Carollo Vincenzo Aurelio, Falzone Samuel, Villa Marco  
> **Data Rilascio:** 18 Gennaio 2026  
> **Licenza:** MIT  

---

## 📌 Indice dei Contenuti
- [📖 Panoramica del Sistema](#-panoramica-del-sistema)
- [🎯 Requisiti del Dominio Applicativo](#-requisiti-del-dominio-applicativo)
- [🏗️ Architettura e Scelte Progettuali](#%EF%B8%8F-architettura-e-scelte-progettuali)
- [📂 Struttura del Repository](#-struttura-del-repository)
- [🗄️ Schema Relazionale e Dettaglio Tabelle](#%EF%B8%8F-schema-relazionale-e-dettaglio-tabelle)
- [⚙️ Guida all'Installazione ed Esecuzione](#%EF%B8%8F-guida-allinstallazione-ed-esecuzione)
- [📊 Analisi dei Volumi e delle Prestazioni](#-analisi-dei-volumi-e-delle-prestazioni)
- [🧪 Suite di Collaudo (30 Query SQL)](#-suite-di-collaudo-30-query-sql)
- [👥 Team di Sviluppo & Licenza](#-team-di-sviluppo--licenza)

---

## 📖 Panoramica del Sistema

> **Nota Architetturale:**  
> Il sistema è stato progettato e normalizzato in **Terza Forma Normale (3FN)** per garantire l'integrità dei dati, eliminare le ridondanze e supportare un'elevata frequenza d'accesso in lettura e scrittura [1, 2].

La piattaforma gestisce l'intero ciclo di vita del servizio di ristorazione a domicilio su scala metropolitana, permettendo la sinergia in tempo reale tra quattro macro-attori principali [1, 2]:



- **👤 Clienti**: gestione account, indirizzi, wallet con saldo integrato, carte fedeltà, carrello ordini e valutazioni [1, 2].
- **🍕 Ristoranti**: gestione del catalogo menu, ingredienti, allergeni, disponibilità delle pietanze e sconti settimanali [1, 2].
- **🛵 Rider**: assegnazione dinamica delle consegne in base a zona (CAP), fasce orarie e giorni lavorativi [1, 2].
- **🎧 Operatori dell'Assistenza**: gestione delle segnalazioni e supporto in tempo reale tramite chat integrata reificata [1, 2].

---

## 🎯 Requisiti del Dominio Applicativo

### 🟢 Modulo Cliente e Ordinazioni
- **Autenticazione**: registrazione sicura con gestione di anagrafica, indirizzo principale e credenziali [1].
- **Wallet Integrato**: borsellino elettronico con saldo ricaricabile e storico transazioni [1].
- **Filtri di Ricerca Avanzata**: selezione di ristoranti e piatti per tipologia di cucina, indirizzo (CAP), fascia di prezzo e promozioni attive [1, 2].

### 🟡 Modulo Ristorazione e Promozioni
- **Catalogo Dinamico**: gestione personalizzata dei menu e dei singoli piatti [1].
- **Mappatura Ingredienti**: dettaglio della composizione di ogni pietanza per il tracciamento degli allergeni [1].
- **Promozioni Settimanali**: applicazione di percentuali di sconto temporanee su piatti specifici [1].

### 🔴 Modulo Logistica e Fatturazione
- **Tracciamento Ordine**: monitoraggio degli orari di ordinazione e di consegna effettiva [1, 2].
- **Fatturazione e Fisco**: generazione automatica di ricevute fiscali 1:1 con distinzione tra imponibile, IVA, costo di consegna, sconti e mance [1, 2].

### 🔵 Modulo Feedback e Assistenza
- **Rating Indipendente**: valutazione distinta su scala 1-5 per la qualità del cibo del ristorante e l'efficienza del rider [1, 2].
- **Ticketing System**: apertura di ticket di supporto da parte del cliente con gestione dei messaggi di chat in ordine cronologico [1, 2].

---

## 🏗️ Architettura e Scelte Progettuali

> **Importante:**  
> Tutte le scelte logiche e di ristrutturazione sono state modellate per ottimizzare i costi d'accesso sulle operazioni con carico stimato di **810.000 transazioni al giorno** [1, 2].

1. **⚡ Partizionamento Verticale Ordine / Ricevuta (1:1)**
   - *Criticità:* La tabella  subisce oltre 810.000 inserimenti/giorno [1, 2]. Mantenere le informazioni di pagamento nello stesso record aumenterebbe il carico d'I/O sulle query gestionali.
   - *Soluzione:* Separazione in una tabella logistica  e una tabella contabile , riducendo la dimensione dei blocchi di memoria interessati dalle query operative [1, 2].

2. **🚀 Dissoluzione della Generalizzazione **
   - *Criticità:* L'entità padre  (con figlie  e ) richiederebbe clausole  sistematiche per accedere alle informazioni operative dei dipendenti [1].
   - *Soluzione:* Accorpamento degli attributi anagrafici direttamente nelle entità figlie  e , eliminando le  e migliorando i tempi di risposta [1].

3. **💬 Reificazione della Chat dei Ticket ()**
   - *Criticità:* La gestione di una chat all'interno dell'entità  impedirebbe la memorizzazione strutturata dei singoli messaggi e dei timestamp [1].
   - *Soluzione:* Creazione dell'entità  con chiave primaria composta  per garantire la cronologia precisa degli scambi [1].

4. **🌐 Gestione dell'Attributo Multivalore **
   - *Soluzione:* Memorizzazione delle lingue conosciute dagli operatori come formato strutturato (JSON/String) nella tabella , evitando tabelle ponte superflue per attributi puramente consultativi [1].

---

## 📂 Struttura del Repository



---

## 🗄️ Schema Relazionale e Dettaglio Tabelle

Il database si compone di **16 tabelle relazionali** completamente vincolate da chiavi primarie, uniche ed estere () [1, 2].

| # | Tabella | Ruolo e Descrizione | Chiave Primaria (PK) | Chiavi Estere (FK) |
| :-: | :--- | :--- | :--- | :--- |
| **1** |  | Profili utente e wallet residuo |  | - |
| **2** |  | Anagrafica esercizi commerciali | uid=1000(sandbox) gid=1000(sandbox) groups=1000(sandbox) | - |
| **3** |  | Personale addetto alle consegne |  | - |
| **4** |  | Personale dell'assistenza clienti |  | - |
| **5** |  | Registro ordini e logistica | uid=1000(sandbox) gid=1000(sandbox) groups=1000(sandbox) | , ,  |
| **6** |  | Dettaglio fiscale e contabile (1:1) | uid=1000(sandbox) gid=1000(sandbox) groups=1000(sandbox) |  |
| **7** |  | Segnalazioni di supporto clienti | uid=1000(sandbox) gid=1000(sandbox) groups=1000(sandbox) |  |
| **8** |  | Chat del ticket di assistenza |  |  |
| **9** |  | Cataloghi dei ristoranti |  |  |
| **10** |  | Singole pietanze dei menu |  |  |
| **11** |  | Elenco ingredienti ed allergeni |  | - |
| **12** |  | Associazione N:M Ticket-Operatore |  | ,  |
| **13** |  | Mappatura Piatto-Ingrediente |  | ,  |
| **14** |  | Mappatura Menu-Piatto |  | ,  |
| **15** |  | Promozioni e sconti sui piatti |  | ,  |
| **16** |  | Feedback del cliente al ristorante |  | ,  |

---

## ⚙️ Guida all'Installazione ed Esecuzione

### Requisiti Hardware & Software
- **DBMS**: MySQL Server 8.0+ oppure MariaDB 10.5+
- **Client SQL**: MySQL CLI, MySQL Workbench, DBeaver o phpMyAdmin

### 🚀 Esecuzione Rapida (Script Automatizzato)
Se ti trovi in ambiente Linux o macOS, puoi eseguire l'intero setup con un solo comando:



### 🛠️ Esecuzione Manuale tramite CLI MySQL

1. **Creazione dello Schema e delle Tabelle**:
   

2. **Popolamento dei Dati di Prova (Opzionale)**:
   

3. **Esecuzione delle Query di Collaudo**:
   

---

## 📊 Analisi dei Volumi e delle Prestazioni

Stima delle operazioni giornaliere basate su un bacino metropolitano [1, 2]:

| Operazione di Dominio | Tipo | Frequenza Stimata | Tabella Coinvolta |
| :--- | :-: | :-: | :--- |
| **Inserimento Nuovo Ordine** |  | ~810.000 / giorno | ,  |
| **Ricerca Ristoranti per CAP** |  | ~2.500.000 / giorno |  |
| **Apertura Ticket Assistenza** |  | ~140.000 / giorno | ,  |
| **Invio Recensione Ristorante** |  | ~81.000 / giorno |  |
| **Registrazione Nuovo Cliente** |  | ~1.500 / giorno |  |
| **Aggiornamento Promozioni** |  | ~2.000 / settimana |  |

---

## 🧪 Suite di Collaudo (30 Query SQL)

Il file [](./30_query_interrogative.sql) contiene 30 query pronte per il collaudo del database, organizzate nei seguenti moduli funzionali [1, 2]:

> **Consiglio per il Collaudo:**  
> Le query coprono le clausole principali SQL:  complesse, Subquery con /, funzioni aggregate , , , clausole  con filtro , e ricerche parziali con  e  [1].

1. 👤 **Gestione Clienti & Wallet** *(Query 1-5)*: ricerca saldi positivi, filtri per fascia d'età e analisi clienti inattivi.
2. 🍕 **Ristoranti, Menu & Piatti** *(Query 6-10)*: filtri allergeni, ricerca pizzerie per CAP, conteggio pietanze e prezzi medi.
3. 🏷️ **Promozioni & Sconti** *(Query 11-13)*: piatti scontati a Palermo, promozioni con sconto ≥ 20% e ristoranti senza offerte.
4. 🧾 **Ordini, Fatturazione & Incassi** *(Query 14-20)*: fatturato per ristorante, incassi divisi per metodo di pagamento e mance medie.
5. 🛵 **Rider & Logistica** *(Query 21-23)*: rider a Palermo con salario > 1000€, numero consegne e disponibilità nei weekend.
6. ⭐ **Recensioni & Valutazioni** *(Query 24-26)*: ristoranti con voto medio servizio ≥ 4.0 e classifica Top Rated.
7. 🎧 **Assistenza Clienti & Ticket** *(Query 27-30)*: storico chat messaggi, ticket in gestione ed operatori poliglotti.

---

## 👥 Team di Sviluppo & Licenza

Progetto universitario realizzato per il corso di **Basi di Dati** [1]:

- 👨‍💻 **Begalov Nikita**
- 👨‍💻 **Carollo Vincenzo Aurelio**
- 👨‍💻 **Falzone Samuel**
- 👨‍💻 **Villa Marco**

Progetto rilasciato sotto licenza **MIT License**.
