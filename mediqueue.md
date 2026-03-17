Oke, ini brief lengkap untuk MediQueue!

---

## MediQueue — Project Brief

### Deskripsi Singkat

MediQueue adalah backend API untuk manajemen klinik kecil-menengah di Indonesia. Sistem ini menggantikan proses manual seperti antrian fisik dan rekam medis kertas menjadi digital. Target penggunanya adalah klinik pratama, puskesmas pembantu, dan dokter praktik mandiri yang ingin digitalisasi tanpa biaya besar.

Bentuknya **REST API** yang bisa diintegrasikan ke frontend apapun (web, mobile, atau WhatsApp bot). Tidak ada UI bawaan — ini murni backend service.

---

### End Users & Role

Ada **4 role** dalam sistem ini:

**1. Platform Admin**
Orang yang mengelola seluruh platform (superadmin). Bisa tambah klinik baru, manage user, dan lihat semua data lintas klinik.

**2. Clinic Admin**
Staf administrasi klinik. Bertanggung jawab registrasi pasien baru, kelola jadwal dokter, kelola antrian, dan generate laporan klinik.

**3. Doctor**
Dokter yang praktek di klinik. Bisa lihat antrian pasien yang assign ke mereka, input rekam medis, tulis resep, dan lihat histori pasien.

**4. Patient**
Pasien yang terdaftar. Bisa daftar antrian sendiri secara online, lihat posisi antrian, lihat histori kunjungan dan resep miliknya sendiri.

---

### Fitur & Flow per Role

#### Flow Utama: Pasien Berobat

```
Patient daftar akun
    → Pilih klinik + dokter + tanggal
    → AI Triage: input keluhan → dapat urgency level (Low/Medium/High)
    → Masuk antrian dengan nomor + estimasi waktu
    → Clinic Admin konfirmasi kedatangan (check-in)
    → Dokter panggil pasien → input rekam medis + resep
    → Appointment selesai → pasien bisa lihat rekam medis & resep
    → Trigger: notifikasi dikirim ke pasien di setiap perubahan status
```

#### Flow Jadwal Dokter

```
Clinic Admin buat schedule dokter (hari, jam, slot maksimal)
    → Patient booking → sistem cek konflik slot
    → Jika slot penuh → pasien masuk waitlist
    → Jika ada pembatalan → pasien waitlist otomatis naik (trigger)
```

#### Flow Laporan Otomatis

```
Setiap hari jam 23:59 → scheduler jalan
    → Hitung total pasien, diagnosa terbanyak, pendapatan
    → Simpan ke tabel reports
    → Kirim email summary ke Clinic Admin
```

---

### Tabel Database (12 Tabel)

**1. `users`**
Semua akun dalam sistem. Field utama: `id`, `email`, `password_hash`, `role` (enum: platform_admin, clinic_admin, doctor, patient), `clinic_id` (nullable untuk platform admin), `created_at`.

**2. `clinics`**
Data klinik yang terdaftar. Field: `id`, `name`, `address`, `phone`, `is_active`.

**3. `doctors`**
Profil dokter, one-to-one dengan `users`. Field: `id`, `user_id`, `specialization`, `str_number` (nomor izin praktek), `bio`.

**4. `patients`**
Profil pasien, one-to-one dengan `users`. Field: `id`, `user_id`, `nik`, `date_of_birth`, `blood_type`, `allergies`.

**5. `schedules`**
Jadwal praktek dokter. Field: `id`, `doctor_id`, `clinic_id`, `day_of_week`, `start_time`, `end_time`, `max_slots`, `is_active`.

**6. `appointments`**
Booking pasien ke dokter. Field: `id`, `patient_id`, `doctor_id`, `clinic_id`, `schedule_id`, `appointment_date`, `queue_number`, `status` (enum: pending, confirmed, in_progress, done, cancelled), `complaint`, `urgency_level` (enum: low, medium, high — hasil AI triage), `created_at`.

**7. `queues`**
State antrian real-time per klinik per hari. Field: `id`, `clinic_id`, `doctor_id`, `date`, `current_number`, `total_registered`.

**8. `medical_records`**
Rekam medis per kunjungan. Field: `id`, `appointment_id`, `patient_id`, `doctor_id`, `diagnosis`, `notes`, `follow_up_date`, `created_at`.

**9. `prescriptions`**
Resep yang dikeluarkan per rekam medis. Field: `id`, `medical_record_id`, `medicine_name`, `dosage`, `frequency`, `duration_days`, `notes`.

**10. `files`**
Metadata file yang diupload (foto, dokumen). Field: `id`, `uploader_id`, `reference_type` (enum: medical_record, profile, document), `reference_id`, `file_url`, `file_name`, `mime_type`, `size_bytes`.

**11. `notifications`**
Log notifikasi yang dikirim ke user. Field: `id`, `user_id`, `title`, `body`, `type`, `is_read`, `sent_at`.

**12. `reports`**
Hasil laporan harian otomatis per klinik. Field: `id`, `clinic_id`, `date`, `total_appointments`, `total_done`, `total_cancelled`, `top_diagnoses` (JSON array), `generated_at`.

---

### Relasi Antar Tabel (Interlacing Schema)

```
clinics ──< schedules >── doctors
clinics ──< appointments >── patients
appointments ──< medical_records ──< prescriptions
medical_records ──< files
appointments ──> queues
users ──< notifications
clinics ──< reports
```

---

### Tech Stack

**Runtime & Framework**
- **Python** + **FastAPI** — high performance, easy to use, and includes automatic OpenAPI documentation.
- **Pydantic** — data validation and settings management using Python type hints.

**Database**
- **PostgreSQL** via **Supabase** — since the requirements request RLS, RPC, Trigger, and Storage, Supabase covers all these out of the box.
- **SQLAlchemy** — a powerful and flexible SQL toolkit and Object-Relational Mapper (ORM) for Python.
- **Alembic** — a lightweight database migration tool for usage with SQLAlchemy.
- **Supabase Storage** — for uploading files (photos, documents).

**Auth**
- **JWT** (access token + refresh token) — stateless, suitable for APIs.
- RBAC enforced at the FastAPI dependency level + database level RLS (double enforcement).

**AI**
- **Google Gemini API** (free tier is enough for MVP) — for the AI Triage endpoint.
- Input: patient complaint text → Output: urgency level + brief reasoning.

**Automation / Scheduler**
- **APScheduler** or **FastAPI-utils** — for the daily reporting scheduler.
- **FastAPI-Mail** + Gmail SMTP (or Resend.com) — for sending report summary emails.

**Testing**
- **Pytest** — the standard testing framework for Python.
- **HTTPX** — for integration testing of API endpoints.
- Target: at least 70% coverage in the service layer.

**DevOps & Deployment**
- **Docker** + **docker-compose** — containerize the application.
- Deploy to **Railway** or **Render** (free for MVP, supports Docker).
- **GitHub Actions** — CI/CD: automatic lint + test on every push to main.

**Linting & Formatting**
- **Ruff** or **Flake8** + **Black**

---

### Arsitektur

MediQueue uses a **Layered Architecture** (not microservices — too overkill for this scope):

```
┌─────────────────────────────────────┐
│           Client (Any)              │  ← Web, Mobile, Postman, etc.
└────────────────┬────────────────────┘
                 │ HTTP Request
┌────────────────▼────────────────────┐
│         FastAPI Endpoints           │  ← Route definitions
├─────────────────────────────────────┤
│        Dependency Injection         │  ← Auth (JWT verify), RBAC check,
│                                     │    Request validator (Pydantic)
├─────────────────────────────────────┤
│           Service Layer            │  ← Business logic (unit tested)
├─────────────────────────────────────┤
│          Repository Layer           │  ← CRUD operations via SQLAlchemy
├─────────────────────────────────────┤
│        PostgreSQL (Supabase)        │  ← RLS, Trigger, RPC, Storage
└─────────────────────────────────────┘
         │                  │
    Gemini API         APScheduler
   (AI Triage)         (Scheduler)
```

Setiap domain (clinic, appointment, medical_record, dst.) punya folder sendiri yang berisi `router`, `controller`, `service`, dan `repository`-nya — struktur modular supaya mudah dikerjakan paralel oleh tim.

---

### Implementasi Requirement Kuliah

| Requirement | Implementasi di MediQueue |
|---|---|
| 10+ tabel interlacing | 12 tables with complex foreign keys, managed via SQLAlchemy |
| Pagination, sort, search | All list endpoints (appointments, patients, etc.) |
| RBAC | 4 roles, enforced via FastAPI dependencies + RLS |
| Storage | File uploads via Supabase Storage |
| RPC | `get_queue_status(clinic_id, date)` function in Postgres |
| Trigger | Auto-update `queues.current_number`, send notification when appointment status changes |
| RLS | Patient only accesses their data, Doctor only sees patients in their clinic |
| 50+ seed data | 3 clinics, 10 doctors, 50 patients, 100+ appointments (Python seed script) |
| Git workflow | Branch per feature, PR to main, GitHub Actions CI |
| State management | Appointment status machine (pending→confirmed→in_progress→done/cancelled) |
| Unit testing | Service layer tested with Pytest + mock repository |
| Form validation | Pydantic model validation on every request |

---

### Endpoint Overview (Summary)

```
POST   /auth/register
POST   /auth/login
POST   /auth/refresh

GET    /clinics
POST   /clinics                    [platform_admin]

GET    /doctors?clinic_id=&spec=
GET    /schedules?doctor_id=&date=

POST   /appointments               [patient] ← + AI triage runs here
GET    /appointments               [clinic_admin, doctor]
PATCH  /appointments/:id/status    [clinic_admin, doctor]

GET    /queues/:clinicId/today     [all roles]

POST   /medical-records            [doctor]
GET    /medical-records/:patientId [doctor, patient self]

POST   /prescriptions              [doctor]

POST   /files/upload               [multipart/form-data]

GET    /notifications              [patient]
PATCH  /notifications/:id/read

GET    /reports?clinic_id=&date=   [clinic_admin, platform_admin]
```

---

### Things to Consider

Several things that often become blindspots during development:

**Slot conflict** — when two patients book the same slot simultaneously (race condition). Must use a database transaction or `SELECT FOR UPDATE` in SQLAlchemy.

**RLS in Supabase** — ensure its policy is thoroughly tested because if misconfigured, patient data can be seen by others. This is security critical.

**AI Triage disclaimer** — Gemini's urgency result is not a medical diagnosis. Add an `ai_disclaimer` field in the response and note that this is only for queue priority, not a medical decision.

**Scheduler timezone** — APScheduler runs in the server's timezone. Ensure it's set to `Asia/Jakarta` so that daily reports don't run at the wrong time.

**File upload size limit** — set limits in FastAPI (e.g., max 5MB per file) and validate mime type in the backend, don't trust the client.

---
