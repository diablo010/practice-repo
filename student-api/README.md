# Student API

## Problem Statement

To manage student records through a REST API.

## Scope

This system should allow users to:

* Add a new student
* View all students
* View a specific student by ID
* Update student information
* Delete a student record

## Endpoints

### Create Student

* **POST** `/students`
- Create a new student record.

### List All Students

* **GET** `/students`
- Retrieve all student records.

### Get Student by ID

* **GET** `/students/{id}`
- Retrieve details of a specific student.

### Update Student

* **PUT** `/students/{id}`
- Update an existing student's information.

### Delete Student

* **DELETE** `/students/{id}`
- Remove a student record.

## Data Model

| Field      | Type     | Description                       |
| ---------- | -------- | --------------------------------- |
| id         | int      | Unique identifier for the student |
| name       | string   | Student name                      |
| age        | int      | Student age                       |
| description| string   | Student description               |

## Features

* Input validation using Pydantic models
* Proper HTTP status codes
* Error handling for missing students
* Interactive API documentation through Swagger UI
* In-memory storage (no database integration)

## Tech Stack

* FastAPI
* Pydantic

## API Documentation

After starting the server, access:

```text
http://127.0.0.1:8000/docs
```

to interact with the API using Swagger UI.
