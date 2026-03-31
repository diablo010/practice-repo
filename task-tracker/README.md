# Task App API Design

## Problem Statement
To create and track daily tasks

## Scope
This system should allow user to:
- Add a task (eg. "eat breakfast")
- View all tasks or a single task
- Update task status
- Delete tasks

## Endpoints
POST '/tasks': Create a task
GET '/tasks': List all tasks
GET '/tasks/{id}': List specific task
PUT '/tasks/{id}': Update a task
DELETE '/tasks/{id}': Delete a task

## Data Model
id - unique identifier
description - str
status - str
created_at - datetime
updated_at - datetime