from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime, date
from typing import Optional
from decimal import Decimal

class MedicalRecordBase(BaseModel):
    appointment_id: UUID
    patient_id: UUID
    doctor_id: UUID
    diagnosis: str
    notes: Optional[str] = None
    blood_pressure: Optional[str] = Field(None, max_length=20)
    temperature: Optional[Decimal] = Field(None, ge=30.0, le=45.0)
    weight_kg: Optional[Decimal] = Field(None, gt=0)
    follow_up_date: Optional[date] = None

class MedicalRecordCreate(MedicalRecordBase):
    pass

class MedicalRecordUpdate(BaseModel):
    appointment_id: Optional[UUID] = None
    patient_id: Optional[UUID] = None
    doctor_id: Optional[UUID] = None
    diagnosis: Optional[str] = None
    notes: Optional[str] = None
    blood_pressure: Optional[str] = Field(None, max_length=20)
    temperature: Optional[Decimal] = Field(None, ge=30.0, le=45.0)
    weight_kg: Optional[Decimal] = Field(None, gt=0)
    follow_up_date: Optional[date] = None

class MedicalRecordResponse(MedicalRecordBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
