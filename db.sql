CREATE DATABASE IF NOT EXISTS food_delivery_db;
USE food_delivery_db;

-- 1. TABELLA: Cliente
CREATE TABLE IF NOT EXISTS Cliente (
    username VARCHAR(50) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    data_nascita DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    numero_civico VARCHAR(10),
    via VARCHAR(100),
    cap VARCHAR(5),
    saldo DECIMAL(10,2) DEFAULT 0.00,
    carta_fedelta VARCHAR(30),
    lingua VARCHAR(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. TABELLA: Ristorante
CREATE TABLE IF NOT EXISTS Ristorante (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    tipologia VARCHAR(50),
    via VARCHAR(100),
    numero_civico VARCHAR(10),
    cap VARCHAR(5),
    media DECIMAL(3,2) CHECK (media BETWEEN 1.00 AND 5.00)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. TABELLA: Rider
CREATE TABLE IF NOT EXISTS Rider (
    matricola VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    data_nascita DATE NOT NULL,
    luogo_nascita VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    giorni_lavoro VARCHAR(100),
    fasce_orarie VARCHAR(100),
    salario DECIMAL(10,2),
    via VARCHAR(100),
    numero_civico VARCHAR(10),
    cap VARCHAR(5),
    lingua VARCHAR(30),
    fotografia VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. TABELLA: Operatore
CREATE TABLE IF NOT EXISTS Operatore (
    matricola VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    data_nascita DATE NOT NULL,
    luogo_nascita VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    giorni_lavoro VARCHAR(100),
    fasce_orarie VARCHAR(100),
    salario DECIMAL(10,2),
    via VARCHAR(100),
    numero_civico VARCHAR(10),
    cap VARCHAR(5),
    lingue VARCHAR(500) COMMENT 'Stringa strutturata o JSON per memorizzare le lingue parlate'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. TABELLA: Ordine
CREATE TABLE IF NOT EXISTS Ordine (
    id INT PRIMARY KEY AUTO_INCREMENT,
    data_ordinazione DATE NOT NULL,
    orario_ordinazione TIME,
    orario_consegna TIME,
    via VARCHAR(100),
    numero_civico VARCHAR(10),
    cap VARCHAR(10),
    voto_servizio INT CHECK (voto_servizio BETWEEN 1 AND 5),
    cliente VARCHAR(50) NOT NULL,
    ristorante INT NOT NULL,
    rider VARCHAR(10),
    FOREIGN KEY (cliente) REFERENCES Cliente(username) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ristorante) REFERENCES Ristorante(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (rider) REFERENCES Rider(matricola) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. TABELLA: Ricevuta
CREATE TABLE IF NOT EXISTS Ricevuta (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ordine INT NOT NULL UNIQUE,
    metodo_pagamento VARCHAR(50) NOT NULL,
    importo_complessivo DECIMAL(10,2) NOT NULL,
    prezzo_consegna DECIMAL(10,2) NOT NULL,
    mancia DECIMAL(10,2) DEFAULT 0.00,
    iva DECIMAL(5,2) NOT NULL,
    codice_sconto VARCHAR(30),
    FOREIGN KEY (ordine) REFERENCES Ordine(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. TABELLA: Ticket
CREATE TABLE IF NOT EXISTS Ticket (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente VARCHAR(50) NOT NULL,
    FOREIGN KEY (cliente) REFERENCES Cliente(username) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. TABELLA: Messaggio (Reificazione della chat di assistenza)
CREATE TABLE IF NOT EXISTS Messaggio (
    ticket INT NOT NULL,
    data DATETIME NOT NULL,
    testo VARCHAR(1500) NOT NULL,
    mittente VARCHAR(50) NOT NULL,
    PRIMARY KEY (ticket, data),
    FOREIGN KEY (ticket) REFERENCES Ticket(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. TABELLA: Menu
CREATE TABLE IF NOT EXISTS Menu (
    nome VARCHAR(100) NOT NULL,
    ristorante INT NOT NULL,
    PRIMARY KEY (nome, ristorante),
    FOREIGN KEY (ristorante) REFERENCES Ristorante(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. TABELLA: Piatto
CREATE TABLE IF NOT EXISTS Piatto (
    nome VARCHAR(100) NOT NULL,
    ristorante INT NOT NULL,
    prezzo DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (nome, ristorante),
    FOREIGN KEY (ristorante) REFERENCES Ristorante(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. TABELLA: Ingrediente
CREATE TABLE IF NOT EXISTS Ingrediente (
    nome VARCHAR(100) PRIMARY KEY
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. TABELLA: Assistenza (Relazione Ticket-Operatore)
CREATE TABLE IF NOT EXISTS Assistenza (
    ticket INT NOT NULL,
    operatore VARCHAR(10) NOT NULL,
    PRIMARY KEY (ticket, operatore),
    FOREIGN KEY (ticket) REFERENCES Ticket(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (operatore) REFERENCES Operatore(matricola) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. TABELLA: Contiene (Composizione Piatto-Ingrediente)
CREATE TABLE IF NOT EXISTS Contiene (
    nome_piatto VARCHAR(100) NOT NULL,
    ristorante INT NOT NULL,
    ingrediente VARCHAR(100) NOT NULL,
    PRIMARY KEY (nome_piatto, ristorante, ingrediente),
    FOREIGN KEY (nome_piatto, ristorante) REFERENCES Piatto(nome, ristorante) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ingrediente) REFERENCES Ingrediente(nome) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 14. TABELLA: Comprende (Menu-Piatto)
CREATE TABLE IF NOT EXISTS Comprende (
    menu VARCHAR(100) NOT NULL,
    nome_piatto VARCHAR(100) NOT NULL,
    ristorante INT NOT NULL,
    PRIMARY KEY (menu, nome_piatto, ristorante),
    FOREIGN KEY (menu, ristorante) REFERENCES Menu(nome, ristorante) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nome_piatto, ristorante) REFERENCES Piatto(nome, ristorante) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15. TABELLA: Promuove (Promozioni Piatto)
-- Gestione delle promozioni settimanali sui piatti applicate dai ristoranti.
CREATE TABLE IF NOT EXISTS Promuove (
    ristorante INT NOT NULL,
    nome_piatto VARCHAR(100) NOT NULL,
    sconto DECIMAL(5,2) NOT NULL,
    periodo VARCHAR(50),
    PRIMARY KEY (ristorante, nome_piatto),
    FOREIGN KEY (nome_piatto, ristorante) REFERENCES Piatto(nome, ristorante) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ristorante) REFERENCES Ristorante(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 16. TABELLA: Recensione
-- Valutazione e giudizio lasciato dal cliente al ristorante in seguito a un ordine.
CREATE TABLE IF NOT EXISTS Recensione (
    ordine INT NOT NULL,
    ristorante INT NOT NULL,
    voto_ristorante INT CHECK (voto_ristorante BETWEEN 1 AND 5),
    testo TEXT,
    PRIMARY KEY (ordine, ristorante),
    FOREIGN KEY (ordine) REFERENCES Ordine(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ristorante) REFERENCES Ristorante(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
