from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime
from typing import Optional

class PlatformAdminBase(BaseModel):
    full_name: str = Field(..., max_length=255)
    phone: Optional[str] = Field(None, max_length=20)

class PlatformAdminCreate(PlatformAdminBase):
    user_id: UUID

class PlatformAdminUpdate(BaseModel):
    full_name: Optional[str] = Field(None, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)

class PlatformAdminResponse(PlatformAdminBase):
    id: UUID
    user_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
