from fastapi import APIRouter
from models.student import BaseStudent, StudentIn, StudentOut
from controllers import student_controller
from typing import List

router = APIRouter()

@router.post("/students", response_model=StudentOut)
def create(student: StudentIn):
    return student_controller.create(student)

@router.get("/students", response_model=List[StudentOut])
def get_all():
    return student_controller.get_all()

# error: get_all() was returning list; res_model returning single object

@router.get("/students/{student_id}", response_model=StudentOut)
def get_one(student_id: int):
    return student_controller.get_one(student_id)

@router.put("/students/{student_id}", response_model=StudentOut)
def update(student_id: int, student: StudentIn):
    return student_controller.update(student_id, student)

@router.delete("/students/{student_id}", response_model=StudentOut)
def delete(student_id: int):
    return student_controller.delete(student_id)

