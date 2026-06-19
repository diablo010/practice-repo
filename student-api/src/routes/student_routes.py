from fastapi import APIRouter
from models.schemas import BaseStudent, StudentCreate, StudentOut
from controllers import student_controller
from database import SessionDep
from typing import List

router = APIRouter()

@router.post("/students", response_model=StudentOut)
def create(student: StudentCreate, session: SessionDep):
    return student_controller.create(student, session)

@router.get("/students", response_model=List[StudentOut])
def get_all(session: SessionDep):
    return student_controller.get_all(session)

# error: get_all() was returning list; res_model returning single object

@router.get("/students/{student_id}", response_model=StudentOut)
def get_one(student_id: int, session: SessionDep):
    return student_controller.get_one(student_id, session)

@router.put("/students/{student_id}", response_model=StudentOut)
def update(student_id: int, student: StudentCreate, session: SessionDep):
    return student_controller.update(student_id, student, session)

@router.delete("/students/{student_id}", response_model=StudentOut)
def delete(student_id: int, session: SessionDep):
    return student_controller.delete(student_id, session)

