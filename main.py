from fastapi import Body, Depends, FastAPI, HTTPException, Query
from datetime import datetime
from typing import Annotated, Any
from enum import Enum
from pydantic import BaseModel, EmailStr
from sqlmodel import SQLModel, Session, create_engine, select, Field

# class ModelName(str, Enum):
#     alexnet = "aaaalllleeexx"
#     resnet = "rrressssnnneeettt"
#     lenet = "lllleeeennneeettt"

# class Item(BaseModel):
#     name: str
#     description: str | None = Field(
#         default=None, title="The description of the item", max_length=300
#     )
#     price: float = Field(gt=0, description="The price must be higher than 0")
#     tax: float | None = None

# class UserIn(BaseModel):
#     username: str
#     password: str
#     email: EmailStr
#     full_name: str | None = None

# class UserOut(BaseModel):
#     username: str
#     email: EmailStr
#     full_name: str | None = None    

# class BaseUser(BaseModel):
#     username: str
#     email: EmailStr
#     full_name: str | None = None

# class UserIn(BaseUser):
#     password: str

class Hero(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    age: int | None = Field(default=None, index=True)
    secret_name: str

sqlite_file_name = "database.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"

connect_args = {"check_same_thread": False}     # allows to use same db to use different threads
engine = create_engine(sqlite_url, connect_args=connect_args)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session

SessionDep = Annotated[Session, Depends(get_session)]

app = FastAPI()

@app.on_event("startup")
def on_startup():
    create_db_and_tables()

# fake_items_db = [{"item_name": "Ooh"},
#                  {"item_name": "fahh"}]

@app.get("/")
async def root():
    return {"message": "Hello World"}

# @app.get("/items/{item_id}")
# async def read_item(item_id: int):
#     return {"item_id": "order matters"}

# @app.get("/items/{item_id}")
# async def read_item(item_id: int):
#     return {"item_id": item_id}

# @app.get("/models/{model_name}")
# async def get_model(model_name: ModelName):
#     if model_name is ModelName.alexnet:
#         return {"model_name": model_name, "msg": "Ooh la la"}
#     if model_name.value == "lllleeeennneeettt":
#         return {"model_name": model_name, "msg": "Dametocosita"}
    
#     return {"model_name": model_name, "msg": "Senoritaaaa"}

# @app.get("/items/")
# async def read_item(skip: int = 0, limit: int = 10):    # http://127.0.0.1:8000/items/?skip=0&limit=10 ; this will give same results as /items/
#     return fake_items_db[skip : skip + limit]
#     # return item

# @app.get("/items/{item_id}")
# async def read_item(item_id: str, q: str | None = None, short: bool = False):    # q is optional as None by default
#     item = {"item_id": item_id}
#     if q:
#         # return {"item_id": item_id, "q": q}
#         item.update({"q": q})
#     if not short:
#         item.update(
#             {"description": "This is an amazing item"}
#         )
#     # return {"item_id": item_id}
#     return item

# if short = False, not short = True, hence, desc
# and vice versa

# @app.get("/items/{item_id}")
# async def read_user_item(item_id: str, needy: str):
#     item = {"item_id": item_id, "needy": needy}
#     return item

# @app.post("/items/")
# async def create_item(item: Item):
#     return item

# @app.post("/items/")
# async def create_item(item: Item):
#     item_dict = item.model_dump()
#     if item.tax is not None:
#         price_with_tax = item.price + item.tax
#         item_dict.update({"price_with_tax": price_with_tax})

#     return item_dict

# @app.put("/items/{item_id}")
# async def update_item(item_id: int, item: Item):
#     return {"item_id": item_id, **item.model_dump()}

# @app.get("/items/")
# async def read_items(q: Annotated[str | None, Query(max_length=50)] = "fixedquery"):
#     results = {"items": [{"item_id": "Foo"}, {"item_id": "Bar"}]}
#     if q:
#         results.update({"q": q})
#     return results

# @app.get("/items/")
# async def read_items(q: Annotated[list[str] | None, Query()] = None):
#     query_items = {"q": q}
#     return query_items

# @app.get("/user/")
# async def read_user(user: UserIn):
#     return user

# # response_model parameter
# @app.get("/items/", response_model=list[Item])
# async def read_items() -> Any:
#     return [
#         Item(name="Portia", price=89),
#         Item(name="Sophie", price=34.23, tax=10)
#     ]

# @app.get("/items/", response_model=list[Item])
# async def read_items() -> Any:
#     return [
#         {"name": "Portia", "price": 89},
#         {"name": "Sophie", "price": 3.23, "tax": 10}
#     ]

# # Don't do this in production!
# @app.post("/user/", response_model=UserOut)
# async def create_user(user: UserIn) -> Any:
#     return user

# @app.post("/user/")
# async def create_user(user: UserIn) -> BaseUser:
#     return user

# @app.put("/items/{item_id}")
# async def update_item(item_id: int, item: Annotated[Item, Body(embed=True)]):
#     results = {"item_id": item_id, "item": item}
#     return results

# # Response Status Code
# @app.post("/items/", status_code=201)
# async def create_item(name: str):
#     return {"name": name}

# # Dependencies
# async def common_parameters(q: str | None = None, skip: int = 0, limit: int = 20):
#     return {"q": q, "skip": skip, "limit": limit}

# @app.get("/items/")
# async def read_items(commons: Annotated[dict, Depends(common_parameters)]):
#     return commons

# @app.get("/users/")
# async def read_users(commons: Annotated[dict, Depends(common_parameters)]):
#     return commons

# SQL (Relational) Databases
@app.get("/heroes/")
def read_heroes(
    session: SessionDep,
    offset: int = 0,
    limit: Annotated[int, Query(le=100)] = 100,
) -> list[Hero]:
    heroes = session.exec(select(Hero).offset(offset).limit(limit)).all()
    return heroes

@app.get("/heroes/{hero_id}")
def read_hero_with_id(hero_id: int, session: SessionDep) -> Hero:
    hero = session.get(Hero, hero_id)
    if not hero:
        raise HTTPException(status_code=404, detail="Hero Not Found")
    return hero

@app.post("/heroes/", status_code=201)
async def create_hero(hero: Hero, session: SessionDep) -> Hero:
    session.add(hero)
    session.commit()
    session.refresh(hero)
    return hero

@app.delete("/heroes/{hero_id}")
async def delete_hero(hero_id: int, session: SessionDep):
    hero = session.get(Hero, hero_id)
    if not hero:
        raise HTTPException(status_code=404, detail="Hero Not Found")
    session.delete(hero)
    session.commit()
    return {"ok": True}