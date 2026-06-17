# defines the data shape

from pydantic import BaseModel, EmailStr, Field

class BaseStudent(BaseModel):
    id: int
    name: str
    username: str
    age: int = Field(gt=17, lt=22, title="Age must be between 18 and 21")
    email: EmailStr
    description: str | None = None

class StudentIn(BaseStudent):
    password: str

class StudentOut(BaseModel):    # separate class, no inheritance; BaseModel is inherited in studentout
    id: int
    name: str



# Request Model  -> StudentIn
# Response Model -> StudentOut

