-- =========================================
-- 1. TABEL CHART OF ACCOUNTS
-- =========================================

CREATE TABLE chart_of_accounts (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    account_code VARCHAR(20) NOT NULL UNIQUE,

    account_name VARCHAR(100) NOT NULL,

    normal_balance VARCHAR(6) NOT NULL
        CHECK (normal_balance IN ('DEBIT', 'CREDIT')),

    report_classification VARCHAR(20) NOT NULL
        CHECK (
            report_classification IN (
                'ASET',
                'LIABILITAS',
                'EKUITAS',
                'PENDAPATAN',
                'BEBAN'
            )
        )
);


-- =========================================
-- 2. TABEL JOURNAL HEADERS
-- =========================================

CREATE TABLE journal_headers (
    header_id BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    transaction_date DATE NOT NULL,

    reference_no VARCHAR(50) NOT NULL UNIQUE,

    description TEXT NOT NULL,

    posting_status VARCHAR(10) NOT NULL
        DEFAULT 'DRAFT'
        CHECK (posting_status IN ('DRAFT', 'POSTED'))
);


-- =========================================
-- 3. TABEL JOURNAL LINES
-- =========================================

CREATE TABLE journal_lines (
    line_id BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    header_id BIGINT NOT NULL,

    account_id BIGINT NOT NULL,

    debit NUMERIC(15, 2) NOT NULL DEFAULT 0
        CHECK (debit >= 0),

    credit NUMERIC(15, 2) NOT NULL DEFAULT 0
        CHECK (credit >= 0),

    -- Mencegah debit dan kredit sama-sama nol
    CONSTRAINT chk_journal_amount
        CHECK (debit > 0 OR credit > 0),

    -- Relasi ke tabel journal_headers
    CONSTRAINT fk_journal_header
        FOREIGN KEY (header_id)
        REFERENCES journal_headers(header_id)
        ON DELETE RESTRICT,

    -- Relasi ke tabel chart_of_accounts
    CONSTRAINT fk_journal_account
        FOREIGN KEY (account_id)
        REFERENCES chart_of_accounts(account_id)
        ON DELETE RESTRICT
);