# handles request-specific decisions

from fastapi import HTTPException
from services.student_service import (
    create_student,
    get_students,
    get_student,
    update_student,
    delete_student
)

def create(student):
    return create_student(student)

def get_all():
    return get_students()

def get_one(student_id: int):
    student = get_student(student_id)

    if not student:
        raise HTTPException(404, "Student Not Found")
    
    return student

def update(student_id: int, student):
    result = update_student(student_id, student)

    if not result:
        raise HTTPException(404, "Student Not Found")
    
    return result

def delete(student_id: int):
    result = delete_student(student_id)

    if not result:
        raise HTTPException(404, "Student Not Found")
    
    return result