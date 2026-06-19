# contains the CRUD logic

from sqlmodel import select
from models.schemas import BaseStudent, StudentOut


def create_student(student, session):
    
    db_student = BaseStudent(
        name=student.name,
        age=student.age,
        email=student.email,
        description=student.description,
        username=student.username,
        password=student.password
    )

    session.add(db_student)
    session.commit()
    session.refresh(db_student)

    return db_student

def get_students(session):
    return session.exec(select(BaseStudent)).all()

def get_student(student_id: int, session):
    statement = select(BaseStudent).where(
        BaseStudent.id == student_id
    )

    return session.exec(statement).first()

def update_student(student_id: int, updated_student, session):

    student = session.get(BaseStudent, student_id)

    if not student:
        return None

    student.name = updated_student.name
    student.age = updated_student.age
    student.email = updated_student.email
    student.description = updated_student.description
    student.username = updated_student.username
    student.password = updated_student.password

    session.add(student)
    session.commit()
    session.refresh(student)

    return student

def delete_student(student_id: int, session):
    student = session.get(BaseStudent, student_id)

    if not student:
        return None

    deleted_student = StudentOut(id=student.id, name=student.name)
    
    session.delete(student)
    session.commit()
    
    return deleted_student
