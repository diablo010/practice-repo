# contains the CRUD logic

students = []

def create_student(student):
    students.append(student)
    return student

def get_students():
    return students

def get_student(student_id: int):
    for student in students:
        if student.id == student_id:
            return student
    return None

def update_student(student_id: int, updated_student):
    for i, student in enumerate(students):
        if student.id == student_id:
            students[i] = updated_student
            return updated_student
    return None

def delete_student(student_id: int):
    for i, student in enumerate(students):
        if student.id == student_id:
            students.pop(i)
    return None