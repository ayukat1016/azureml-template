FROM python:3.9-slim-bullseye as builder

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential python3-llvmlite

ENV LLVM_CONFIG /usr/bin/llvm-config-9

COPY pyproject.toml poetry.lock ./

RUN pip install --upgrade pip && pip install poetry
RUN poetry config virtualenvs.create false && poetry install --no-root

