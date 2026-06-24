from typing import Annotated, Any

from fastapi import Depends, FastAPI, HTTPException, Query, Response
from datetime import UTC, datetime, timezone
from contextlib import asynccontextmanager

from sqlmodel import Field, Session, SQLModel, create_engine, select

class TaskBase(SQLModel):
    description: str
    status: str

class TaskCreate(TaskBase):
    pass

class Task(TaskBase, table=True):  # tells that this is table model to db
    id: int | None = Field(default=None, primary_key=True)  # signals that python code may not explicitly assign id to task in database, so it sets auto-increment
    description: str = Field(index=True)    # database index for faster lookups
    status: str = Field(index=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), index=True)
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), index=True)

class TaskUpdate(SQLModel):
    description: str | None = None
    status: str | None = None

sqlite_file_name = "database.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"

connect_args = {"check_same_thread": False}
engine = create_engine(sqlite_url, connect_args=connect_args)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:    #   session stores objects in memory
        yield session   #   engine to communicate with db

SessionDep = Annotated[Session, Depends(get_session)]

@asynccontextmanager
async def lifespan(app: FastAPI):

    create_db_and_tables()

    yield

app = FastAPI(lifespan=lifespan)

# Create a task
@app.post("/tasks/")    # only desc and status to be sent; id is auto-generated, and other attributes too
def create_task(task: TaskCreate, session: SessionDep) -> Task:

    db_task = Task.model_validate(task)
    session.add(db_task)
    session.commit()
    session.refresh(db_task)

    return db_task


# Read all tasks
@app.get("/tasks/")
def read_tasks(
    session: SessionDep,
    offset: int = 0,
    limit: Annotated[int, Query(le=100)] = 100,
) -> list[Task]:
    tasks = session.exec(select(Task).offset(offset).limit(limit)).all()
    return tasks

# Read specific task
@app.get("/tasks/{id}")
def read_task(id: int, session: SessionDep) -> Task:
    task = session.get(Task, id)
    if not task:
        raise HTTPException(status_code=404, detail="Task Not Found!")
    return task

# Update a task
@app.patch("/tasks/{id}")
def update_task(id: int, task: TaskUpdate, session: SessionDep):

    task_db = session.get(Task, id)

    if not task_db:
        raise HTTPException(status_code=404, detail="Task not found")

    task_db.sqlmodel_update(task.model_dump(exclude_unset=True))
    task_db.updated_at = datetime.now(timezone.utc)

    session.add(task_db)
    session.commit()
    session.refresh(task_db)

    return task_db

# Delete a task
@app.delete("/tasks/{id}")
async def delete_task(id: int, session: SessionDep):
    task = session.get(Task, id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    session.delete(task)
    session.commit()
    return {"ok": True}
