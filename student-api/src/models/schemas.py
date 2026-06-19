# defines the data shape

from pydantic import BaseModel, EmailStr, Field
from sqlmodel import SQLModel, Field, create_engine 

# database table
class BaseStudent(SQLModel, table=True):
    
    id: int | None = Field(default=None, primary_key=True)
    name: str
    age: int = Field(gt=17, lt=22, title="Age must be between 18 and 21")
    email: str
    description: str | None = None
    username: str
    password: str

class StudentCreate(SQLModel):

    name: str
    age: int = Field(gt=17, lt=22, title="Age must be between 18 and 21")
    email: str
    description: str | None = None
    username: str
    password: str

# output model
class StudentOut(SQLModel):    # separate class, no inheritance; SQLModel is used in studentout
    id: int
    name: str



# Request Model  -> StudentIn
# Response Model -> StudentOut

