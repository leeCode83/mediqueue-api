from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime
from typing import Optional, Literal

class FileBase(BaseModel):
    uploader_id: Optional[UUID] = None
    reference_type: Literal['medical_record', 'patient_profile', 'clinic_document']
    reference_id: UUID
    storage_bucket: str = Field(..., max_length=100)
    storage_path: str
    file_name: str = Field(..., max_length=255)
    mime_type: str = Field(..., max_length=100)
    size_bytes: int = Field(..., gt=0)

class FileCreate(FileBase):
    pass

class FileUpdate(BaseModel):
    uploader_id: Optional[UUID] = None
    reference_type: Optional[Literal['medical_record', 'patient_profile', 'clinic_document']] = None
    reference_id: Optional[UUID] = None
    storage_bucket: Optional[str] = Field(None, max_length=100)
    storage_path: Optional[str] = None
    file_name: Optional[str] = Field(None, max_length=255)
    mime_type: Optional[str] = Field(None, max_length=100)
    size_bytes: Optional[int] = Field(None, gt=0)

class FileResponse(FileBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
