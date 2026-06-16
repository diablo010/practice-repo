# defines the data shape

from pydantic import BaseModel

class Student(BaseModel):
    id: int
    name: str
    age: int
    description: str | None = None
