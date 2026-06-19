from typing import Annotated

from fastapi import Depends
from sqlalchemy import inspect, text
from sqlmodel import SQLModel, Session, create_engine, select

db_url = f"sqlite:///database.db"

connect_args = {'check_same_thread': False}
engine = create_engine(db_url, connect_args=connect_args)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session

SessionDep = Annotated[Session, Depends(get_session)]


# engine           → database.py
# get_session()    → database.py
# SessionDep       → database.py

# @app.get/post     → routes

# session.add()
# session.commit()
# session.query()
#                  → service layer
