from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime, date
from typing import Optional

class QueueBase(BaseModel):
    doctor_id: UUID
    clinic_id: UUID
    date: date
    current_serving_number: int = 0
    total_registered: int = 0
    total_done: int = 0
    total_cancelled: int = 0

class QueueCreate(QueueBase):
    pass

class QueueUpdate(BaseModel):
    doctor_id: Optional[UUID] = None
    clinic_id: Optional[UUID] = None
    date: Optional[date] = None
    current_serving_number: Optional[int] = None
    total_registered: Optional[int] = None
    total_done: Optional[int] = None
    total_cancelled: Optional[int] = None

class QueueResponse(QueueBase):
    id: UUID
    updated_at: datetime

    class Config:
        from_attributes = True
