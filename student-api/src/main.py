from fastapi import FastAPI
from routes.student_routes import router
from contextlib import asynccontextmanager
from fastapi import FastAPI
from database import create_db_and_tables

@asynccontextmanager
async def lifespan(app: FastAPI):

    create_db_and_tables()

    yield

app = FastAPI(lifespan=lifespan)

app.include_router(router)

# on_event is deprecated; lifespan used