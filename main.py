from fastapi import FastAPI
from datetime import datetime
from typing import Any
from enum import Enum

class ModelName(str, Enum):
    alexnet = "aaaalllleeexx"
    resnet = "rrressssnnneeettt"
    lenet = "lllleeeennneeettt"

app = FastAPI()

fake_items_db = [{"item_name": "Ooh"},
                 {"item_name": "fahh"}]

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

@app.get("/items/{item_id}")
async def read_user_item(item_id: str, needy: str):
    item = {"item_id": item_id, "needy": needy}
    return item