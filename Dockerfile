ARG PYTHON_VERSION=3.8

FROM python:${PYTHON_VERSION}-buster
RUN apt-get update && apt-get install -y \
    --no-install-recommends apt-utils --yes \
    python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3

ENV PATH="/scripts:${PATH}"
ENV PROJECT_ROOT="/app/tviology"
ENV PROJECT_APP_DIR=$PROJECT_ROOT."/tviology"

COPY ./requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r ./requirements.txt

RUN mkdir -p $PROJECT_ROOT
COPY . $PROJECT_ROOT
WORKDIR $PROJECT_ROOT
COPY ./scripts /scripts

RUN chmod +x /scripts/*

RUN mkdir -p /vol/web/media
RUN mkdir -p /vol/web/static
RUN mkdir -p /vol/web/

RUN adduser --disabled-password --gecos '' user
RUN adduser user sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown -R user /home/user
RUN chmod -R 755 /home/user
RUN chown -R user:user /vol
RUN chmod -R 755 /vol/web
USER user

ENV HOME /home/user
ENV POETRY_ROOT $HOME/.poetry
ENV PATH $POETRY_ROOT/bin:$PATH

CMD ["entrypoint.sh"]