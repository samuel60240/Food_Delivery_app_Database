
---

# 🍕 README.md

> **Progetto Universitario per il corso di Basi di Dati**  
> **Titolo:** Architettura Database Food Delivery  
> **Autori:** Begalov Nikita, Carollo Vincenzo Aurelio, Falzone Samuel, Villa Marco  
> **Data:** 18 Gennaio 2026  

---

## 📌 Indice
1. [Panoramica del Progetto](#panoramica-del-progetto)
2. [Requisiti e Dominio Applicativo](#requisiti-e-dominio-applicativo)
3. [Architettura e Scelte Progettuali](#architettura-e-scelte-progettuali)
4. [Struttura del Repository](#struttura-del-repository)
5. [Schema del Database (16 Tabelle)](#schema-del-database-16-tabelle)
6. [Guida all'Installazione ed Esecuzione](#guida-allinstallazione-ed-esecuzione)
7. [Query e Collaudo Funzionale](#query-e-collaudo-funzionale)
8. [Analisi dei Volumi e delle Prestazioni](#analisi-dei-volumi-e-delle-prestazioni)

---

## 📖 Panoramica del Progetto

Il progetto ha come obiettivo la progettazione e l'implementazione di un **database relazionale completo per una piattaforma di Food Delivery** su scala metropolitana.

La base di dati è progettata per gestire in modo efficiente le interazioni fra quattro attori principali:
- **Clienti**: effettuano ordini, pagamenti, usufruiscono di un wallet e rilasciano recensioni.
- **Ristoranti**: gestiscono i menu, la composizione dei piatti (ingredienti/allergeni) e le promozioni settimanali.
- **Rider**: accettano e consegnano gli ordini in base a disponibilità e fasce orarie.
- **Servizio Assistenza (Operatori / Ticket)**: supportano i clienti risolvendo segnalazioni tramite una chat integrata reificata.

Il sistema è dimensionato per sostenere un carico stimato fino a **810.000 ordini/giorno**.

---

## 📋 Requisiti e Dominio Applicativo

*(Inserisci qui i dettagli sui requisiti e sul dominio applicativo del progetto)*

---

## 🏗️ Architettura e Scelte Progettuali

Durante le fasi di **Progettazione Concettuale** e **Progettazione Logica**, sono state adottate soluzioni architetturali mirate a ottimizzare l'efficienza computazionale e la manutenibilità:

1. **Partizionamento Ordine / Ricevuta**:
   - L'entità Ordine è stata separata dalla Ricevuta (relazione 1:1) per isolare le informazioni di logistica e valutazione dai dati contabili e di pagamento. Ciò riduce la dimensione della tabella Ordine (oggetto di ~810.000 inserimenti/giorno).

2. **Eliminazione della Generalizzazione Personale**:
   - La superclasse Personale (con le sottoclassi Rider e Operatore) è stata dissolta accorpando gli attributi anagrafici direttamente nelle tabelle figlie. Questo evita JOIN onerose su query operative frequenti relative alle consegne e al supporto.

3. **Gestione degli Attributi Multivalore e Chat**:
   - **Reificazione della Chat**: Lo storico messaggi dei ticket è stato ristrutturato nella tabella `Messaggio` (chiave primaria composta `ticket`, `data`), permettendo di tracciare mittente e timestamp di ciascun messaggio.
   - **Attributo Lingue**: Memorizzato come stringa strutturata/JSON nella tabella `Operatore` per evitare l'introduzione di tabelle ponte superflue.

4. **Selezione delle Chiavi Primarie**:
   - Introduzione di un `id` artificiale per Ristorante per sostituire la tripla `(via, numero_civico, cap)` ed ereditare relazioni più snelle nelle tabelle correlate (`Piatto`, `Menu`, `Promuove`).
   - Adozione di una `Matricola` univoca per il personale dipendente (`Rider`, `Operatore`).

---

## 📁 Struttura del Repository

*(Inserisci qui la struttura delle cartelle e dei file del repository)*

---

## 🗄️ Schema del Database (16 Tabelle)

| Tabella | Descrizione | Chiave Primaria |
| :--- | :--- | :--- |
| **Cliente** | Utenti registrati che effettuano ordini | `username` |
| **Ristorante** | Esercizi commerciali registrati | `id` |
| **Rider** | Personale addetto alla consegna a domicilio | `matricola` |
| **Operatore** | Personale del servizio clienti / ticket | `matricola` |
| **Ordine** | Ordini effettuati dai clienti presso i ristoranti | `id` |
| **Ricevuta** | Documento contabile collegato 1:1 all'Ordine | `id` |
| **Ticket** | Segnalazioni di assistenza aperte dai clienti | `id` |
| **Messaggio** | Messaggi della chat relativa a un ticket | `(ticket, data)` |
| **Menu** | Elenco dei menu proposti da un ristorante | `(nome, ristorante)` |
| **Piatto** | Singola pietanza preparata da un ristorante | `(nome, ristorante)` |
| **Ingrediente** | Catalogo unico degli ingredienti/allergeni | `nome` |
| **Assistenza** | Associazione N:M tra Ticket e Operatore umano | `(ticket, operatore)` |
| **Contiene** | Associazione N:M tra Piatto ed Ingrediente | `(nome_piatto, ristorante, ingrediente)` |
| **Comprende** | Associazione N:M tra Menu e Piatto | `(menu, nome_piatto, ristorante)` |
| **Promuove** | Promozioni settimanali applicate sui piatti | `(ristorante, nome_piatto)` |
| **Recensione** | Valutazioni e recensioni lasciate dal cliente | `(ordine, ristorante)` |

---

## 💻 Guida all'Installazione ed Esecuzione

### Requisiti
- **MySQL Server 8.0+** o **MariaDB 10.5+**

### Esecuzione Rapida tramite CLI
```bash
# 1. Creazione delle tabelle DDL
mysql -u root -p < schema_database.sql

# 2. Inserimento dei dati di prova
mysql -u root -p < seed_database.sql

# 3. Collaudo delle query
mysql -u root -p < query_database.sql

## 🛠️ Script di Deployment Automatico (`setup_database.sh`)

Ho creato per te questo script Bash automatizzato che esegue in sequenza la creazione dello schema, il popolamento con i dati di prova e il collaudo delle 12 query:

```bash
#!/usr/bin/env bash
set -e

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-root}"

echo "================================================================="
echo "🚀 Avvio Inizializzazione Database Food Delivery"
echo "================================================================="

# 1. Creazione dello Schema DDL
echo "📌 [1/3] Creazione delle tabelle e vincoli d'integrità..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" < schema_database.sql

# 2. Inserimento Dati di Popolamento
echo "📌 [2/3] Inserimento dati di prova..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" < seed_database.sql

# 3. Esecuzione Query di Collaudo
echo "📌 [3/3] Esecuzione delle query di collaudo..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" < query_database.sql

echo "================================================================="
echo "🎉 Database Food Delivery pronto all'uso!"
echo "================================================================="
```
