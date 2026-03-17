from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime
from typing import Optional

class DoctorBase(BaseModel):
    full_name: str = Field(..., min_length=3, max_length=255)
    specialization: str = Field(..., max_length=100)
    str_number: str = Field(..., max_length=100)
    phone: Optional[str] = Field(None, max_length=20)
    bio: Optional[str] = None

class DoctorCreate(DoctorBase):
    user_id: UUID

class DoctorUpdate(BaseModel):
    full_name: Optional[str] = Field(None, max_length=255)
    specialization: Optional[str] = Field(None, max_length=100)
    str_number: Optional[str] = Field(None, max_length=100)
    phone: Optional[str] = Field(None, max_length=20)
    bio: Optional[str] = None

class DoctorResponse(DoctorBase):
    id: UUID
    user_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
