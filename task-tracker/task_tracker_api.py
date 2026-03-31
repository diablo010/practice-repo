from typing import Annotated, Any

from fastapi import Depends, FastAPI, HTTPException, Query, Response
from datetime import UTC, datetime, timezone

from sqlmodel import Field, Session, SQLModel, create_engine, select

# class TaskBase(SQLModel):
#     description: str
#     status: str

# class TaskCreate(TaskBase):
#     pass

# class Task(TaskBase, table=True):  # tells that this is table model to db
#     id: int | None = Field(default=None, primary_key=True)  # signals that python code may not explicitly assign id to task in database, so it sets auto-increment
#     # description: str = Field(index=True)    # database index for faster lookups
#     # status: str = Field(index=True)
#     created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), index=True)
#     updated_at: datetime  = Field(default_factory=lambda: datetime.now(timezone.utc), index=True)

# sqlite_file_name = "database.db"
# sqlite_url = f"sqlite:///{sqlite_file_name}"

# connect_args = {"check_same_thread": False}
# engine = create_engine(sqlite_url, connect_args=connect_args)

# def create_db_and_tables():
#     SQLModel.metadata.create_all(engine)

# def get_session():
#     with Session(engine) as session:    #   session stores objects in memory
#         yield session   #   engine to communicate with db

# SessionDep = Annotated[Session, Depends(get_session)]

app = FastAPI()

# @app.on_event("startup")
# def on_startup():
#     create_db_and_tables()

# @app.post("/tasks/")    # only desc and status to be sent; id is auto-generated, and other attributes too
# def create_task(task: TaskCreate, session: SessionDep) -> Task:
#     db_task = Task(**task.model_dump())
#     session.add(db_task)
#     session.commit()
#     session.refresh(db_task)
#     return db_task

# # Read all tasks
# @app.get("/tasks/")
# def read_tasks(
#     session: SessionDep,
#     offset: int = 0,
#     limit: Annotated[int, Query(le=100)] = 100,
# ) -> list[Task]:
#     tasks = session.exec(select(Task).offset(offset).limit(limit)).all()
#     return tasks

# # Read specific task
# @app.get("/tasks/{id}")
# def read_task(id: int, session: SessionDep) -> Task:
#     task = session.get(Task, id)
#     if not task:
#         raise HTTPException(status_code=404, detail="Task Not Found!")
#     return task


@app.get("/")
async def root():
    return "Welcome to Task Tracker"

sample_tasks: Any = [
    {
        "id": 1,
        "description": "Waking Up",
        "status": "todo",
        "created_at": datetime.now(),
        "updated_at": datetime.now()
    },
    {
        "id": 3,
        "description": "Sleeping",
        "status": "Done",
        "created_at": datetime.now(),
        "updated_at": datetime.now()
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
        "created_at": datetime.now(),
        "updated_at": datetime.now()
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
                "created_at": task.get("created_at"),     #   to get existing data from database as it is
                "updated_at": datetime.now()
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



