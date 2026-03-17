from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime, date
from typing import Optional, Any

class ReportBase(BaseModel):
    clinic_id: UUID
    date: date
    total_appointments: int = 0
    total_done: int = 0
    total_cancelled: int = 0
    total_new_patients: int = 0
    top_diagnoses: Optional[Any] = None # JSONB

class ReportCreate(ReportBase):
    pass

class ReportUpdate(BaseModel):
    clinic_id: Optional[UUID] = None
    date: Optional[date] = None
    total_appointments: Optional[int] = None
    total_done: Optional[int] = None
    total_cancelled: Optional[int] = None
    total_new_patients: Optional[int] = None
    top_diagnoses: Optional[Any] = None

class ReportResponse(ReportBase):
    id: UUID
    generated_at: datetime

    class Config:
        from_attributes = True
