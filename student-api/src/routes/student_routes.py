from fastapi import APIRouter
from models.student import Student
from controllers import student_controller

router = APIRouter()

@router.post("/students")
def create(student: Student):
    return student_controller.create(student)

@router.get("/students")
def get_all():
    return student_controller.get_all()

@router.get("/students/{student_id}")
def get_one(student_id: int):
    return student_controller.get_one(student_id)

@router.put("/students/{student_id}")
def update(student_id: int, student: Student):
    return student_controller.upate(student_id, student)

@router.delete("/students/{student_id}")
def delete(student_id: int):
    return student_controller.delete(student_id)