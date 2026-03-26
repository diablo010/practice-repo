from typing import Any

from fastapi import FastAPI, HTTPException, Response
from datetime import datetime

app = FastAPI()

@app.get("/")
async def root():
    return "Welcome to Task Tracker"

sample_tasks: Any = [
    {
        "id": 1,
        "description": "Waking Up",
        "status": "todo",
        "createdAt": datetime.now(),
        "updatedAt": datetime.now()
    },
    {
        "id": 3,
        "description": "Sleeping",
        "status": "Done",
        "createdAt": datetime.now(),
        "updatedAt": datetime.now()
    }
]

@app.get("/tasks")
async def read_tasks():
    return {"tasks_predefined": sample_tasks}    # tasks_predefined is necessary, it represents list

@app.get("/tasks/{id}")
async def read_task_with_id(id: int):
    for task in sample_tasks:
        if task.get("id") == id:
            return {"task": task}
    raise HTTPException(status_code=404)

@app.post("/tasks", status_code=201)    # request has been successfully fulfilled and has resulted in one or more new resources being created
async def add_new_task(body: dict[str, Any]):   #   str(key), Any(variable)

    new_task: Any = {
        "id": body.get("id"),
        "description": body.get("description"),
        "status": body.get("status"),
        "createdAt": datetime.now(),
        "updatedAt": datetime.now()
    }

    sample_tasks.append(new_task)
    return {"Tasks": new_task}

@app.put("/tasks/{id}")
async def update_task(id: int, body: dict[str, Any]):

    for index, task in enumerate(sample_tasks):
        if task.get("id") == id:

            updated: Any = {
                "id": id,
                "description": task.get("description"),
                "status": body.get("status"),
                "createdAt": task.get("createdAt"),     #   to get existing data from database as it is
                "updatedAt": datetime.now()
            }

            sample_tasks[index] = updated
            return {"task": updated}
        raise HTTPException(status_code=404)
    
@app.delete("/tasks/{id}")
async def delete_task(id: int):
    for index, task in enumerate(sample_tasks):
        if task.get("id") == id:
            sample_tasks.pop(index)
            return Response(status_code=204)        # 204: server has successfully fulfilled the request, there is no available content for this request
        raise HTTPException(status_code=404)