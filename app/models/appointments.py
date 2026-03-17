from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime, date
from typing import Optional, Literal

class AppointmentBase(BaseModel):
    patient_id: UUID
    doctor_id: UUID
    clinic_id: UUID
    schedule_id: UUID
    appointment_date: date
    queue_number: int
    status: Literal['pending', 'confirmed', 'in_progress', 'done', 'cancelled'] = 'pending'
    complaint: str
    urgency_level: Optional[Literal['low', 'medium', 'high']] = None
    urgency_reasoning: Optional[str] = None
    cancelled_by: Optional[UUID] = None
    cancellation_reason: Optional[str] = None

class AppointmentCreate(AppointmentBase):
    pass

class AppointmentUpdate(BaseModel):
    patient_id: Optional[UUID] = None
    doctor_id: Optional[UUID] = None
    clinic_id: Optional[UUID] = None
    schedule_id: Optional[UUID] = None
    appointment_date: Optional[date] = None
    queue_number: Optional[int] = None
    status: Optional[Literal['pending', 'confirmed', 'in_progress', 'done', 'cancelled']] = None
    complaint: Optional[str] = None
    urgency_level: Optional[Literal['low', 'medium', 'high']] = None
    urgency_reasoning: Optional[str] = None
    cancelled_by: Optional[UUID] = None
    cancellation_reason: Optional[str] = None

class AppointmentResponse(AppointmentBase):
    id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
