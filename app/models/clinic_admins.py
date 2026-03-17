from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime
from typing import Optional

class ClinicAdminBase(BaseModel):
    full_name: str = Field(...,min_length=3, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    clinic_id: UUID

class ClinicAdminCreate(ClinicAdminBase):
    user_id: UUID

class ClinicAdminUpdate(BaseModel):
    full_name: Optional[str] = Field(None, min_length=3, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    clinic_id: Optional[UUID] = None

class ClinicAdminResponse(ClinicAdminBase):
    id: UUID
    user_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
