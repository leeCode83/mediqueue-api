from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime, time
from typing import Optional

class ScheduleBase(BaseModel):
    doctor_id: UUID
    clinic_id: UUID
    day_of_week: int = Field(..., ge=0, le=6)
    start_time: time
    end_time: time
    max_slots: int = Field(..., gt=0)
    is_active: bool = True

class ScheduleCreate(ScheduleBase):
    pass

class ScheduleUpdate(BaseModel):
    doctor_id: Optional[UUID] = None
    clinic_id: Optional[UUID] = None
    day_of_week: Optional[int] = Field(None, ge=0, le=6)
    start_time: Optional[time] = None
    end_time: Optional[time] = None
    max_slots: Optional[int] = Field(None, gt=0)
    is_active: Optional[bool] = None

class ScheduleResponse(ScheduleBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
