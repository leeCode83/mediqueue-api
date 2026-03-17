from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime
from typing import Optional, Literal

class NotificationBase(BaseModel):
    user_id: UUID
    title: str = Field(..., max_length=255)
    body: str
    type: Literal['appointment_status', 'queue_update', 'report_ready', 'general']
    reference_id: Optional[UUID] = None
    is_read: bool = False

class NotificationCreate(NotificationBase):
    pass

class NotificationUpdate(BaseModel):
    user_id: Optional[UUID] = None
    title: Optional[str] = Field(None, max_length=255)
    body: Optional[str] = None
    type: Optional[Literal['appointment_status', 'queue_update', 'report_ready', 'general']] = None
    reference_id: Optional[UUID] = None
    is_read: Optional[bool] = None

class NotificationResponse(NotificationBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
