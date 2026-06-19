# handles request-specific decisions

from fastapi import HTTPException
from services.student_service import (
    create_student,
    get_students,
    get_student,
    update_student,
    delete_student
)

def create(student, session):
    return create_student(student, session)

def get_all(session):
    return get_students(session)

def get_one(student_id: int, session):
    student = get_student(student_id, session)

    if not student:
        raise HTTPException(404, "Student Not Found")
    
    return student

def update(student_id: int, student, session):
    result = update_student(student_id, student, session)

    if not result:
        raise HTTPException(404, "Student Not Found")
    
    return result

def delete(student_id: int, session):
    result = delete_student(student_id, session)

    if not result:
        raise HTTPException(404, "Student Not Found")
    
    return result