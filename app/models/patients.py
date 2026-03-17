from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime, date
from typing import Optional, Literal

class PatientBase(BaseModel):
    full_name: str = Field(..., max_length=255)
    nik: Optional[str] = Field(None, max_length=16)
    date_of_birth: date
    gender: Literal['male', 'female']
    blood_type: Optional[Literal['A', 'B', 'AB', 'O']] = None
    allergies: Optional[str] = None
    phone: Optional[str] = Field(None, max_length=20)
    address: Optional[str] = None

class PatientCreate(PatientBase):
    user_id: UUID

class PatientUpdate(BaseModel):
    full_name: Optional[str] = Field(None, max_length=255)
    nik: Optional[str] = Field(None, max_length=16)
    date_of_birth: Optional[date] = None
    gender: Optional[Literal['male', 'female']] = None
    blood_type: Optional[Literal['A', 'B', 'AB', 'O']] = None
    allergies: Optional[str] = None
    phone: Optional[str] = Field(None, max_length=20)
    address: Optional[str] = None

class PatientResponse(PatientBase):
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
