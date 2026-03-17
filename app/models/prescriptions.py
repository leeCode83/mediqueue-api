from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime
from typing import Optional

class PrescriptionBase(BaseModel):
    medical_record_id: UUID
    medicine_name: str = Field(..., max_length=255)
    dosage: str = Field(..., max_length=100)
    frequency: str = Field(..., max_length=100)
    duration_days: int = Field(..., gt=0)
    notes: Optional[str] = None

class PrescriptionCreate(PrescriptionBase):
    pass

class PrescriptionUpdate(BaseModel):
    medical_record_id: Optional[UUID] = None
    medicine_name: Optional[str] = Field(None, max_length=255)
    dosage: Optional[str] = Field(None, max_length=100)
    frequency: Optional[str] = Field(None, max_length=100)
    duration_days: Optional[int] = Field(None, gt=0)
    notes: Optional[str] = None

class PrescriptionResponse(PrescriptionBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
