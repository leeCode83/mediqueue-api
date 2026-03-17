-- ============================================================
-- MediQueue — Database Schema
-- Supabase SQL Editor
-- Jalankan file ini secara keseluruhan sekaligus
-- auth.users sudah tersedia dari Supabase Auth, tidak perlu dibuat
-- ============================================================


-- ============================================================
-- 1. CLINICS
-- ============================================================
CREATE TABLE clinics (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    address     TEXT         NOT NULL,
    city        VARCHAR(100) NOT NULL,
    phone       VARCHAR(20)  NOT NULL,
    email       VARCHAR(255),
    is_active   BOOLEAN      NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);


-- ============================================================
-- 2. PLATFORM_ADMINS
-- ============================================================
CREATE TABLE platform_admins (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID         NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name   VARCHAR(255) NOT NULL,
    phone       VARCHAR(20),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);


-- ============================================================
-- 3. CLINIC_ADMINS
-- ============================================================
CREATE TABLE clinic_admins (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID         NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    clinic_id   UUID         NOT NULL REFERENCES clinics(id) ON DELETE RESTRICT,
    full_name   VARCHAR(255) NOT NULL,
    phone       VARCHAR(20),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);


-- ============================================================
-- 4. DOCTORS
-- ============================================================
CREATE TABLE doctors (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID         NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name        VARCHAR(255) NOT NULL,
    specialization   VARCHAR(100) NOT NULL,
    str_number       VARCHAR(100) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    bio              TEXT,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);


-- ============================================================
-- 5. PATIENTS
-- ============================================================
CREATE TABLE patients (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID         NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name       VARCHAR(255) NOT NULL,
    nik             VARCHAR(16)  UNIQUE,
    date_of_birth   DATE         NOT NULL,
    gender          VARCHAR(10)  NOT NULL CHECK (gender IN ('male', 'female')),
    blood_type      VARCHAR(5)   CHECK (blood_type IN ('A', 'B', 'AB', 'O')),
    allergies       TEXT,
    phone           VARCHAR(20),
    address         TEXT,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);


-- ============================================================
-- 6. SCHEDULES
-- ============================================================
CREATE TABLE schedules (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id     UUID        NOT NULL REFERENCES doctors(id)  ON DELETE CASCADE,
    clinic_id     UUID        NOT NULL REFERENCES clinics(id)  ON DELETE CASCADE,
    day_of_week   SMALLINT    NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time    TIME        NOT NULL,
    end_time      TIME        NOT NULL,
    max_slots     SMALLINT    NOT NULL CHECK (max_slots > 0),
    is_active     BOOLEAN     NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT schedules_no_duplicate UNIQUE (doctor_id, clinic_id, day_of_week, start_time),
    CONSTRAINT schedules_time_valid   CHECK  (end_time > start_time)
);


-- ============================================================
-- 7. APPOINTMENTS
-- ============================================================
CREATE TABLE appointments (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id           UUID         NOT NULL REFERENCES patients(id)   ON DELETE RESTRICT,
    doctor_id            UUID         NOT NULL REFERENCES doctors(id)    ON DELETE RESTRICT,
    clinic_id            UUID         NOT NULL REFERENCES clinics(id)    ON DELETE RESTRICT,
    schedule_id          UUID         NOT NULL REFERENCES schedules(id)  ON DELETE RESTRICT,
    appointment_date     DATE         NOT NULL,
    queue_number         SMALLINT     NOT NULL,
    status               VARCHAR(20)  NOT NULL DEFAULT 'pending'
                             CHECK (status IN ('pending', 'confirmed', 'in_progress', 'done', 'cancelled')),
    complaint            TEXT         NOT NULL,
    urgency_level        VARCHAR(10)  CHECK (urgency_level IN ('low', 'medium', 'high')),
    urgency_reasoning    TEXT,
    cancelled_by         UUID         REFERENCES auth.users(id) ON DELETE SET NULL,
    cancellation_reason  TEXT,
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT appointments_queue_unique UNIQUE (doctor_id, appointment_date, queue_number)
);


-- ============================================================
-- 8. QUEUES
-- ============================================================
CREATE TABLE queues (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id               UUID        NOT NULL REFERENCES doctors(id)  ON DELETE CASCADE,
    clinic_id               UUID        NOT NULL REFERENCES clinics(id)  ON DELETE CASCADE,
    date                    DATE        NOT NULL,
    current_serving_number  SMALLINT    NOT NULL DEFAULT 0,
    total_registered        SMALLINT    NOT NULL DEFAULT 0,
    total_done              SMALLINT    NOT NULL DEFAULT 0,
    total_cancelled         SMALLINT    NOT NULL DEFAULT 0,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT queues_unique_per_day UNIQUE (doctor_id, date)
);


-- ============================================================
-- 9. MEDICAL_RECORDS
-- ============================================================
CREATE TABLE medical_records (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id   UUID          NOT NULL UNIQUE REFERENCES appointments(id) ON DELETE RESTRICT,
    patient_id       UUID          NOT NULL REFERENCES patients(id)            ON DELETE RESTRICT,
    doctor_id        UUID          NOT NULL REFERENCES doctors(id)             ON DELETE RESTRICT,
    diagnosis        TEXT          NOT NULL,
    notes            TEXT,
    blood_pressure   VARCHAR(20),
    temperature      DECIMAL(4, 1) CHECK (temperature BETWEEN 30.0 AND 45.0),
    weight_kg        DECIMAL(5, 2) CHECK (weight_kg > 0),
    follow_up_date   DATE,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT now()
);


-- ============================================================
-- 10. PRESCRIPTIONS
-- ============================================================
CREATE TABLE prescriptions (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medical_record_id UUID         NOT NULL REFERENCES medical_records(id) ON DELETE CASCADE,
    medicine_name     VARCHAR(255) NOT NULL,
    dosage            VARCHAR(100) NOT NULL,
    frequency         VARCHAR(100) NOT NULL,
    duration_days     SMALLINT     NOT NULL CHECK (duration_days > 0),
    notes             TEXT,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now()
);


-- ============================================================
-- 11. FILES
-- ============================================================
CREATE TABLE files (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uploader_id      UUID         NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
    reference_type   VARCHAR(50)  NOT NULL
                         CHECK (reference_type IN ('medical_record', 'patient_profile', 'clinic_document')),
    reference_id     UUID         NOT NULL,
    storage_bucket   VARCHAR(100) NOT NULL,
    storage_path     TEXT         NOT NULL UNIQUE,
    file_name        VARCHAR(255) NOT NULL,
    mime_type        VARCHAR(100) NOT NULL,
    size_bytes       INTEGER      NOT NULL CHECK (size_bytes > 0),
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);


-- ============================================================
-- 12. NOTIFICATIONS
-- ============================================================
CREATE TABLE notifications (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID         NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title         VARCHAR(255) NOT NULL,
    body          TEXT         NOT NULL,
    type          VARCHAR(50)  NOT NULL
                      CHECK (type IN ('appointment_status', 'queue_update', 'report_ready', 'general')),
    reference_id  UUID,
    is_read       BOOLEAN      NOT NULL DEFAULT false,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);


-- ============================================================
-- 13. REPORTS
-- ============================================================
CREATE TABLE reports (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clinic_id            UUID        NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
    date                 DATE        NOT NULL,
    total_appointments   INTEGER     NOT NULL DEFAULT 0,
    total_done           INTEGER     NOT NULL DEFAULT 0,
    total_cancelled      INTEGER     NOT NULL DEFAULT 0,
    total_new_patients   INTEGER     NOT NULL DEFAULT 0,
    top_diagnoses        JSONB,
    generated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT reports_unique_per_day UNIQUE (clinic_id, date)
);


-- ============================================================
-- INDEXES
-- Untuk mempercepat query yang sering dipakai
-- ============================================================

-- Appointments: filter by patient, doctor, clinic, date, status
CREATE INDEX idx_appointments_patient_id       ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor_id        ON appointments(doctor_id);
CREATE INDEX idx_appointments_clinic_id        ON appointments(clinic_id);
CREATE INDEX idx_appointments_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status           ON appointments(status);

-- Medical records: sering di-query by patient
CREATE INDEX idx_medical_records_patient_id ON medical_records(patient_id);
CREATE INDEX idx_medical_records_doctor_id  ON medical_records(doctor_id);

-- Prescriptions: sering di-query by medical_record
CREATE INDEX idx_prescriptions_medical_record_id ON prescriptions(medical_record_id);

-- Notifications: sering di-filter by user + is_read
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- Queues: sering di-query by doctor + date
CREATE INDEX idx_queues_doctor_date ON queues(doctor_id, date);

-- Files: sering di-query by reference
CREATE INDEX idx_files_reference ON files(reference_type, reference_id);

-- Schedules: sering di-filter by clinic atau doctor
CREATE INDEX idx_schedules_doctor_id ON schedules(doctor_id);
CREATE INDEX idx_schedules_clinic_id ON schedules(clinic_id);

-- Reports: sering di-query by clinic + date range
CREATE INDEX idx_reports_clinic_date ON reports(clinic_id, date);